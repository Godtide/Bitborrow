
// import { Clarinet, Tx, types } from 'https://deno.land/x/clarinet@v0.3.0/index.ts';
// import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

// Clarinet.test({
//     name: "Ensure that <...> - wrapped-tide",
//     async fn(chain, accounts) {
//         let block = chain.mineBlock([   
// // (define-public (wrap-tide (amount uint) (recipient principal))
// // (if
// //     (is-ok
// //         (contract-call? .tidetoken transfer (as-contract tx-sender) amount))
// //     (begin
// //         (ft-mint? wrapped-tide amount recipient)
// //     )
// //     (err ERR-YOU-POOR)))

// Tx.contractCall('wrappedtide', 'unwrap', [
//     types.uint(100),
//   ], accounts[0].address)
          
//         ]);
//         assertEquals(block.receipts.length, 0);
//         assertEquals(block.height, 3);

//         console.log("===", chain.callReadOnlyFn("wrappedtide", "get-balance-of", [], accounts[0].address));

//     },
// });
