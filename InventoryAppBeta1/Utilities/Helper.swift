//
//  Helper.swift
//  InventoryAppBeta1
//
//  Created by Harsh Verma on 28/05/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
class Helper {

  static func isPasswordValid(_ password: String) -> Bool {
        let pRT = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        
        return pRT.evaluate(with: password)
    }

}
