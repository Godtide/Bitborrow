(define-public (transfer-to-recipient! (recipient principal) (amount uint))
  (if (is-eq (mod amount 10) 0)
      (stx-transfer? amount tx-sender recipient)
      (err u400)))