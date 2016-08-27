//
//  IAPHelper.swift
//  Little Family Tree
//
//  Created by Bryan  Farnworth on 8/18/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import StoreKit

@objc class IAPHelper: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    var productIDs: Array<String!> = ["LFTPremium"]
    var productsArray =  [SKProduct]()
    var transactionInProgress = false
    var listener:IAPHelperListener
    
    init(listener:IAPHelperListener) {
        self.listener = listener
        super.init()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        requestProductInfo()
    }
    
    func restorePurchases() {
        transactionInProgress = true
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
 
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            var productIdentifiers = Set<String>()
            for id in productIDs {
                productIdentifiers.insert(id)
            }
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
            
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            print("Cannot perform In App Purchases.")
        }
    }
    
    @objc func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product)
                
            }
            listener.onProductsReady(productsArray)
        }
        else {
            print("There are no products.")
            listener.onError("No products found")
        }
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
            listener.onError(response.invalidProductIdentifiers.description)
        }
    }
    
    func canMakePayents() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func buyProduct(productIndex:Int) {
        if !self.transactionInProgress {
            let payment = SKPayment(product: self.productsArray[productIndex] as SKProduct)
            SKPaymentQueue.defaultQueue().addPayment(payment)
            self.transactionInProgress = true
        } else {
            print("Only 1 transaction at a time.")
            listener.onError("Only 1 transaction at a time.")
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                transactionInProgress = false
                let productIdentifier = transaction.originalTransaction?.payment.productIdentifier
                if productIdentifier != nil && productIdentifier == productIDs[0] {
                    listener.onTransactionComplete()
                }
                break
            case SKPaymentTransactionState.Failed:
                print("Transaction Failed \(transaction.error)")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                transactionInProgress = false
                if transaction.error != nil {
                    listener.onError("Transaction Failed \(transaction.error!)")
                } else {
                    listener.onError("Transaction Failed")
                }
                break
            case SKPaymentTransactionState.Restored:
                print("Transaction Restored")
                transactionInProgress = false
                let productIdentifier = transaction.originalTransaction?.payment.productIdentifier
                if productIdentifier != nil && productIdentifier == productIDs[0] {
                    listener.onTransactionComplete()
                } else {
                    listener.onError("Unable to find previous purchase.")
                }
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                break
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
}

protocol IAPHelperListener {
    func onProductsReady(productsArray: [SKProduct])
    func onTransactionComplete()
    func onError(error:String)
}