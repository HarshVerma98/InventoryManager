//
//  IDS.swift
//  InventoryAppBeta1
//
//  Created by Harsh Verma on 18/05/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
import RealmSwift


let kKoginToMainView = "loginToMainView"
let kExitToLoginViewSegue = "segueToLogin"
let kInventoryToProductDetail = "inventoryToProductDetail"
let kInventoryToNewProduct = "inventoryToNewProduct"
let kSortingPopoverSegue = "SortByPopover"
let HVC = "HomeVC"

func config() {
    var x = Realm.Configuration.defaultConfiguration
    x.objectTypes = [Products.self, Transaction.self]
}

