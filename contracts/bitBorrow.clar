;; error consts

(define-constant ERR-UNAUTHORIZED u1)
(define-constant ERR-YOU-POOR u2)

(define-constant ERR_STX_TRANSFER u0)



(define-fungible-token tidetoken)
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-constant contract-creator tx-sender)
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-10-ft-standard.ft-trait)



;; define plans available

(define-type-alias PlanList (List 1 2 3 Plans))
(define-data-var plans-list PlanList (list))

;; get plans available
(define-read-only (get-plans)
  (ok (var-get plans-list)))

;; define APR
(define-data-var apr int 10)

;; APR get percent

(define-public (percentage)
  (begin
    (var-set apr (/ (apr) 100))
    (ok (var-get apr))))





;; **Compound interest** can be calculated using the formula

;; *A*(*t*)=*P*(1+*r*)*t*

;; where

;; - *A*(*t*) is the account value,
;; - *t* is measured in years,
;; - *P* is the starting amount of the account, often called the principal, or more generally present value,
;; - *r* is the annual percentage rate (APR) expressed as a decimal, and assuming the interest is only compounded once a year
      



;;  get amount earned after interest calculation


(define-data-var interest int 0)

;;   calculate interest

( define-public (compound (principalvalue uint) (plans plan))
begin
  let ((pri (+ percentage) 1)
  var-set interest (* principalvalue pri plan)
 (ok var-get interest)))

  

;;   invest your stx for tide

( define-public (Invest(amount uint))
    ;; pay the contract
 (if
        (is-ok (stx-transfer? amount tx-sender (as-contract tx-sender))
       
        (begin
         ;; calculate interest
         let ( (cpinterest  (compound amount plan ))
        ;;    calculate total amount after interest
              (total ( + (amount) cpinterest))
           ;; mint  user
            (mint! tx-sender total)
      ;; amount invested locked away until time stipulated
            (contract-call? .wrapped-tide wrap-tide amount tx-sender)

             (asserts! (>= (get-balance-of tx-sender) amount) (err "locking funds unsuccesful")) 
            ) )
        (err ERR_STX_TRANSFER)))))



(define-public (buy (amount uint))
    (if
        (is-ok
          (stx-transfer? amount tx-sender (as-contract tx-sender)))

        ;;   tidetoken 1:1 stx
        (begin
            (mint! tx-sender amount)
        )
        (err ERR-YOU-POOR)))





;; define APY
(define-data-var apy int 20)

;; APY get percent

(define-public (percentageloan)
  (begin
    (var-set apy (/ (apy) 100))
    (ok (var-get apy))))




;;  get total amount payable per year

;; P = iA / [1 − (1+i)^-N]     === rately pay per N time

;;   I: Interest rate
;;   A: amount to be borrowed
;;   N: number of years
;;   p : amount repayable per year
;; Total loan payment = P x N

(define-data-var amountperyear int 0)



( define-public (amountRepayable(amountToBorrow uint)(plans plan))
  let( (i1 (+ percentageloan ) 1)
    (ni (^ i1) -plan)
    (ai(-ni)1)
    (iA (* percentageloan) amountToBorrow)
    (repayable (/ iA) ai)
    (ok event-pass-id)
 )
)


(define-public (borrow (amount uint) (plans plan))
    ;; choose plan 

  (let (balance (amountRepayable amount plan)
;;   check if user has enough stx balance 
    (asserts! (>= (stx-get-balance tx-sender) balance) (err "insufficient funds")) 
   
     (begin
          (stx-transfer? balance tx-sender (as-contract tx-sender)))
        ;; mint amount
            (mint! tx-sender balance)
             (contract-call? .wrapped-tide wrap-tide amount tx-sender)

             (asserts! (>= (contract-call? .wrapped-tide get-balance-of tx-sender) amount) (err "locking funds unsuccesful")) 
          
        )
       ))




(define-public (withdraw (amount uint))
    ;; check wrap-tide balance 
    (asserts! (>= (contract-call? .wrapped-tide get-balance-of tx-sender) amount) (err "You don't have locked funds")) 
  
     (begin
             (contract-call? .wrapped-tide unwrap-tide amount tx-sender)

             (asserts! (>= (get-balance-of tx-sender) amount) (err "withdrawal unsuccesful")) 
          
        )
       ))










;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;

(define-public (transfer (amount uint) (from principal) (to principal))
    (begin
        (asserts! (is-eq from tx-sender)
            (err ERR-UNAUTHORIZED))

        (ft-transfer? tidetoken amount from to)
    )
)

(define-read-only (get-name)
    (ok "tidetoken"))

(define-read-only (get-symbol)
    (ok "tide"))

(define-read-only (get-decimals)
    (ok u0))

(define-read-only (get-balance-of (user principal))
    (ok (ft-get-balance tidetoken user)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply tidetoken)))


;; mint function

(define-private (mint! (account principal) (amount uint))
  (if (<= amount u0)
      (err u0)
      (begin
        (var-set total-supply (+ (var-get total-supply) amount))
        (ft-mint? tidetoken amount account))))



(define-public (set-token-uri (value (string-utf8 256)))
    (if 
        (is-eq tx-sender contract-creator) 
            (ok (var-set token-uri (some value))) 
        (err ERR-UNAUTHORIZED)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))

;; send-many\

(define-public (send-it (amount uint) (to principal))
    (let ((transfer-ok (try! (transfer amount tx-sender to))))
    (ok transfer-ok)))

(define-private (send-tidetoken (recipient { to: principal, amount: uint }))
    (send-it
        (get amount recipient)
        (get to recipient)))

(define-private (check-err  (result (response bool uint))
                            (prior (response bool uint)))
    (match prior ok-value result
                err-value (err err-value)))

(define-public (send-many (recipients (list 200 { to: principal, amount: uint })))
    (fold check-err
        (map send-tidetoken recipients)
        (ok true)))