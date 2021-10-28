;;
;; rockets-ship-line.clar
;;

(define-constant line-ceo 'SP19Y6GRV9X778VFS1V8WT2H502WFK33XZXADJWZ)

(define-data-var employed-pilots (list 10 principal) (list))

;; This function will:
;;  * check that it is called by the line-ceo
;;  * check that the rocket is owned by the contract
;;  * authorize each employed pilot to the ship
(define-public (add-managed-rocket (ship uint))
 (begin
  ;; only the ceo may call this function
  (asserts! (is-eq tx-sender contract-caller line-ceo) (err u1))
  ;; start executing as the contract
   (as-contract (begin
    ;; make sure the contract owns the ship
    (asserts! (contract-call? .rockets-base is-my-ship ship) (err u2))
    ;; register all of our pilots on the ship
    (add-pilots-to ship)))))

;; add all the pilots to a ship using fold --
;;  the fold checks the return type of previous calls,
;;  skipping subsequent contract-calls if one fails.
(define-private (add-pilot-via-fold (pilot principal) (prior-result (response uint uint)))
  (let ((ship (try! prior-result)))
    (try! (contract-call? .rockets-base authorize-pilot ship pilot))
    (ok ship)))
(define-private (add-pilots-to (ship uint))
  (fold add-pilot-via-fold (var-get employed-pilots) (ok ship)))