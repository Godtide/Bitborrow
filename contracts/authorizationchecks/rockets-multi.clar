;;
;; rockets-multi.clar
;;

(define-private (call-fly (ship uint))
  (unwrap! (contract-call? .rockets-base fly-ship ship) false))
;; try to fly all the ships, returning a list of whether
;;  or not we were able to fly the supplied ships
(define-public (fly-all (ships (list 10 uint)))
  (ok (map call-fly ships)))