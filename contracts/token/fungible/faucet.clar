(define-map claimed-before
  ((sender principal))
  ((claimed bool)))

(define-constant err-already-claimed u1)
(define-constant err-faucet-empty u2)
(define-constant stx-amount u1)

(define-public (claim-from-faucet)
    (let ((requester tx-sender)) ;; set a local variable requester = tx-sender
        (asserts! (is-none (map-get? claimed-before {sender: requester})) (err err-already-claimed))
        (unwrap! (as-contract (stx-transfer? stx-amount tx-sender requester)) (err err-faucet-empty))
        (map-set claimed-before {sender: requester} {claimed: true})
        (ok stx-amount)))