
import { Clarinet, Tx, types } from 'https://deno.land/x/clarinet@v0.3.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure that <...> - tidetoken ",
    async fn(chain, accounts) {
        let block = chain.mineBlock([


// ( define-public (compound (amount uint) (months uint))
// begin
//   let ( (var-set timelock (months))
//       (var-set principalvalue (amount))
//       (var-set percentage (/ var-get apr) u100)
//     var-set interest   ( * var-get principalvalue) ((+ var-get percentage) 1) ( var-get timelock)
//  (ok var-get interest)))

Tx.contractCall('bitBorrow', 'compound', [
    types.uint(6),
    types.uint(100),
  ], accounts[0].address)
        ]);
        
    console.log("get-interest", JSON.stringify(chain.callReadOnlyFn("bitBorrow", "get-interest", [], accounts[0].address), null, 2));
    assertEquals(block.receipts.length, 2);
        assertEquals(block.height, 2);
    
    
    block = chain.mineBlock( [            
//         calculate interest

// ( define-public (compound (amount uint) (months uint))
// begin
//   let ( (var-set timelock (months))
//       (var-set principalvalue (amount))
//       (var-set percentage (/ var-get apr) u100)
//     var-set interest   ( * var-get principalvalue) ((+ var-get percentage) 1) ( var-get timelock)
//  (ok var-get interest)))
        
//         Tx.contractCall('bitBorrow', 'borrow', [
//             types.uint(6),
//             types.uint(100),
//           ], accounts[0].address)
//                 ]);
//                 assertEquals(block.receipts.length, 0);
//                 assertEquals(block.height, 3);
        
//                 console.log("===", chain.callReadOnlyFn("stx-token", "get-total-supply", [], accounts[0].address));
        


Tx.contractCall('bitBorrow', 'invest', [
    types.uint(6),
    types.uint(100),
  ], accounts[0].address)
        ]),
        console.log("===", chain.callReadOnlyFn("tidetoken", "get-balance-of", [], accounts[0].address));
        console.log("===", chain.callReadOnlyFn("wrappedtide", "get-balance-of", [], accounts[0].address));

        
        assertEquals(block.receipts.length, 3);
        assertEquals(block.height, 3);




        block = chain.mineBlock([            
// (define-public (borrow (amount uint) (months uint))
// ;; choose plan 

// (let (balance (totalloanrepayable amount months)
// ;;   check if user has enough stx balance 
// (asserts! (>= (stx-get-balance tx-sender) balance) (err "insufficient funds")) 

//  (begin
//       (stx-transfer? balance tx-sender (as-contract tx-sender)))
//     ;; mint amount
//         (mint! tx-sender balance)
//          (contract-call? .wrapped-tide wrap-tide amount tx-sender)

//          (asserts! (>= (contract-call? .wrapped-tide get-balance-of tx-sender) amount) (err "locking funds unsuccesful")) 
      
//     )
//    ))

Tx.contractCall('bitBorrow', 'borrow', [
    types.uint(6),
    types.uint(100),
  ], accounts[0].address)
        ]),


        console.log("===", chain.callReadOnlyFn("tidetoken", "get-balance-of", [], accounts[0].address));
        console.log("===", chain.callReadOnlyFn("wrappedtide", "get-balance-of", [], accounts[0].address));

        
        assertEquals(block.receipts.length, 3);
        assertEquals(block.height, 4);

        block = chain.mineBlock([
            // ( define-public (buy (amount uint))
            // (if
            //     (is-ok
            //       (stx-transfer? amount tx-sender (as-contract tx-sender)))
        
            //     ;;   tidetoken 1:1 stx
            //     (begin
            //         (mint! tx-sender amount)
            //     )
            //     (err ERR-YOU-POOR)))
        

             Tx.contractCall('bitBorrow', 'buy', [
                types.uint(100),
              ],  types.principal('ST000000000000000000002AMW42H.wrappedTide'))
           
        ]);
        console.log("===", chain.callReadOnlyFn("tidetoken", "get-balance-of", [], types.principal('ST000000000000000000002AMW42H.wrappedTide')));
        assertEquals(block.receipts.length, 2);
        assertEquals(block.height, 5);



        block = chain.mineBlock([
// ( define-public (amountrepayablepermonth(amount uint)(months uint))
// let( (var-set timelock (months))
//      (var-set amountToBorrow (amount))
//       (var-set percentageloan (/ var-get apr) u100)
//        var-set repayablepermonth     (/(*  (var-get percentageloan) (var-get amountToBorrow))) (- (^(+ (var-get percentageloan) (1))(var-get timelock))(1))
//   (ok repayablepermonth)
// )
// )
             Tx.contractCall('bitBorrow', 'amountrepayablepermonth', [
                types.uint(100),
              ], accounts[0].address)
           
        ]);
       
        console.log("get-repayablepermonth", JSON.stringify(chain.callReadOnlyFn("bitBorrow", "get-repayablepermonth", [], accounts[0].address), null, 4));
        assertEquals(block.receipts.length, 2);
        assertEquals(block.height, 6);
     
    
        block = chain.mineBlock([
                 
// ( define-public (totalloanrepayable(amountToBorrow uint)(months uint))
// let(
//     (var-set timelock (months))
//      (var-set amountToBorrow (amount))
//          var-set totalloan (* (amountrepayablepermonth (var-get amountToBorrow) (var-get timelock)) (var-get timelock))
//   (ok totalloan)
// )            
                         Tx.contractCall('bitBorrow', 'totalloanrepayable', [
                            types.uint(100),
                          ], accounts[0].address)
                       
                    ]);
                  
        console.log("get-totalloan", JSON.stringify(chain.callReadOnlyFn("bitBorrow", "get-totalloan", [], accounts[0].address), null, 5));

        assertEquals(block.receipts.length, 2);
        assertEquals(block.height, 7);

    
    },
});
