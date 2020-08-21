//
//  InventoryModel.swift
//  InventoryAppBeta1
//
//  Created by Harsh Verma on 18/05/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

private var realm: Realm!

class Products: Object {
    @objc dynamic var id = ""
    @objc dynamic var creationDate: Date?
    @objc dynamic var lastUpdate: Date?
    @objc dynamic var productname = ""
    @objc dynamic var productDescription = ""
    @objc dynamic var image: Data?
    var amount: Int {
        get  {
            return self.quantityOnHand()
        }
    }
    
    
    
    
    let transactions = List<Transaction>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override class func ignoredProperties() -> [String] {
        return ["amount"]
    }
    
    
    func quantityOnHandUsingMapReduce() -> Int {
        let realm = try! Realm()
        let transactions = realm.objects(Transaction.self).filter("productId = %@", self.id).map({$0.amount}).filter({$0 < 0})
        
        return abs(transactions.reduce(0, +))
    }
    
    
    func quantitySoldUsingmapReduce() -> Int {
        let realm = try! Realm()
        let transactions = realm.objects(Transaction.self).filter("productId = %@", self.id).map({$0.amount}).filter({$0 < 0})
        return transactions.reduce(0, +)
    }
    
    
    func quantitySold() -> Int {
        let realm = try! Realm()
        let transactions = realm.objects(Transaction.self).filter("productId = %@ AND amount < 0", self.id)
        return transactions.sum(ofProperty: "amount")
    }
    
    func quantityOnHand() -> Int {
        let realm = try! Realm()
        let transactions = realm.objects(Transaction.self).filter("productId = %@", self.id)
        return transactions.sum(ofProperty: "amount")
    }
    
    
    func addTransaction(quantity: Int, userIdentity: String) {
        
        let R = try! Realm()
        try! R.write {
            if quantity != 0 {
                let now = Date()
                let transaction = Transaction()
                transaction.transactionDate = now
                transaction.transactedBy = userIdentity
                transaction.productId = self.id
                transaction.amount = quantity
                R.add(transaction)
                self.lastUpdate = now
                self.transactions.append(transaction)
                R.add(self, update: .modified)
                
            }
        }
    }
    
    
    
    func hasTransactionHistory() -> Bool {
        let R = try! Realm()
        return R.objects(Transaction.self).filter("productId = %@", self.id).count > 0
    }
    
    
    func quantitySold(between startDate: Date, endDate: Date?) -> Array<Dictionary<Date, Int>>? {
        
        let rv = Array<Dictionary<Date, Int>>()
        return rv.count == 0 ? nil : rv
        
    }
    
    
    func quantityReplenished(between startDate: Date, endDate: Date) -> Array<Dictionary<Date, Int>>? {
        return nil
    }
}
    
    class Transaction: Object {
        @objc dynamic var id = NSUUID().uuidString
        @objc dynamic var transactionDate: Date?
        @objc dynamic var transactedBy = ""
        @objc dynamic var productId = ""
        @objc dynamic var amount = 0
        
        
        override class func primaryKey() -> String? {
            return "id"
        }
    }
    
