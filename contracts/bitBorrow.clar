;; error consts

(define-constant ERR-UNAUTHORIZED u1)
(define-constant ERR-YOU-POOR u2)

(define-constant ERR_STX_TRANSFER u0)


(define-fungible-token tidetoken)
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-constant contract-creator tx-sender)
(impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.sip-10-ft-standard.ft-trait)



;; **Compound interest** can be calculated using the formula

;; *A*(*t*)=*P*(1+*r*)*t*

;; where

;; - *A*(*t*) is the account value,
;; - *t* is measured in years,
;; - *P* is the starting amount of the account, often called the principal, or more generally present value,
;; - *r* is the annual percentage rate (APR) expressed as a decimal, and assuming the interest is only compounded once a year
      



;;  get amount earned after interest calculation



;; define APR
(define-data-var apr u10)
(define-data-var timelock u0 )
(define-data-var principalvalue u0 )
(define-data-var percentage u0 )
(define-data-var interest u0 )
(define-data-var total u0 )


;;   calculate interest

( define-public (compound (amount uint) (months uint))
begin
  let ( (var-set timelock (months))
      (var-set principalvalue (amount))
      (var-set percentage (/ var-get apr) u100)
    var-set interest   ( * var-get principalvalue) ((+ var-get percentage) 1) ( var-get timelock)
 (ok var-get interest)))

  

;;   invest your stx for tide

( define-public (Invest(amount uint))
    ;; pay the contract
 (if
        (is-ok (stx-transfer? amount tx-sender (as-contract tx-sender))
       
        (begin
         ;; calculate total amount after interest
         let ( var-set total (+ amount) (compound amount plan ))
           ;; mint  user
            (mint! tx-sender var-get total)
      ;; amount invested locked away until time stipulated
            (contract-call? .wrapped-tide wrap-tide amount tx-sender)

             (asserts! (>= (get-balance-of tx-sender) amount) (err "locking funds unsuccesful")) 
            ) )
        (err ERR_STX_TRANSFER)))



( define-public (buy (amount uint))
    (if
        (is-ok
          (stx-transfer? amount tx-sender (as-contract tx-sender)))

        ;;   tidetoken 1:1 stx
        (begin
            (mint! tx-sender amount)
        )
        (err ERR-YOU-POOR)))





;; define APY
(define-data-var apy u20)
(define-data-var amountToBorrow u0 )
(define-data-var percentageloan u0 )
(define-data-var repayablepermonth u0 )
(define-data-var totalloan u0 )



;;  get total amount payable per year

;; P = iA / [1 − (1+i)^-N]     === rately pay per N time

;;   I: Interest rate
;;   A: amount to be borrowed
;;   N: number of years
;;   p : amount repayable per year
;; Total loan payment = P x N





( define-public (amountrepayablepermonth(amount uint)(months uint))
  let( (var-set timelock (months))
       (var-set amountToBorrow (amount))
        (var-set percentageloan (/ var-get apr) u100)
         var-set repayablepermonth     (/(*  (var-get percentageloan) (var-get amountToBorrow))) (- (^(+ (var-get percentageloan) (1))(var-get timelock))(1))
    (ok repayablepermonth)
 )
)
 
( define-public (totalloanrepayable(amountToBorrow uint)(months uint))
  let(
      (var-set timelock (months))
       (var-set amountToBorrow (amount))
           var-set totalloan (* (amountrepayablepermonth (var-get amountToBorrow) (var-get timelock)) (var-get timelock))
    (ok totalloan)
 )
 

 




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

;; bitBorrow getters
    
(define-read-only (get-interest)
    (ok (var-get interest)))

        
(define-read-only (get-repayablepermonth)
    (ok (var-get repayablepermonth)))

            
(define-read-only (get-totalloan)
    (ok (var-get totalloan)))



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