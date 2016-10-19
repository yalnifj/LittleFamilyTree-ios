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
    var productIDs: Array<String?> = ["LFTPremium"]
    var productsArray =  [SKProduct]()
    var transactionInProgress = false
    var listener:IAPHelperListener
    
    init(listener:IAPHelperListener) {
        self.listener = listener
        super.init()
        SKPaymentQueue.default().add(self)
        requestProductInfo()
    }
    
    func cleanup() {
        SKPaymentQueue.default().remove(self)
    }
    
    func restorePurchases() {
        transactionInProgress = true
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
 
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            DispatchQueue.main.async(execute: {
                var productIdentifiers = Set<String>()
                for id in self.productIDs {
                    productIdentifiers.insert(id!)
                }
                let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
                
                productRequest.delegate = self
                productRequest.start()
            })
        }
        else {
            print("Cannot perform In App Purchases.")
        }
    }
    
    @objc func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            if productsArray.count == 0 {
                for product in response.products {
                    productsArray.append(product)
                    
                }
                listener.onProductsReady(productsArray)
            }
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
    
    func buyProduct(_ productIndex:Int) {
        if !self.transactionInProgress {
            DispatchQueue.main.async(execute: {
                let payment = SKPayment(product: self.productsArray[productIndex] as SKProduct)
                SKPaymentQueue.default().add(payment)
                self.transactionInProgress = true
            })
        } else {
            print("Only 1 transaction at a time.")
            //listener.onError("Only 1 transaction at a time.")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                let productIdentifier = transaction.original?.payment.productIdentifier
                if productIdentifier != nil && productIdentifier == productIDs[0] {
                    listener.onTransactionComplete()
                }
                break
            case SKPaymentTransactionState.failed:
                print("Transaction Failed \(transaction.error)")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                if transaction.error != nil {
                    listener.onError("Transaction Failed \(transaction.error!)")
                } else {
                    listener.onError("Transaction Failed")
                }
                break
            case SKPaymentTransactionState.restored:
                print("Transaction Restored")
                transactionInProgress = false
                let productIdentifier = transaction.original?.payment.productIdentifier
                if productIdentifier != nil && productIdentifier == productIDs[0] {
                    listener.onTransactionComplete()
                } else {
                    listener.onError("Unable to find previous purchase.")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
}

protocol IAPHelperListener {
    func onProductsReady(_ productsArray: [SKProduct])
    func onTransactionComplete()
    func onError(_ error:String)
}
