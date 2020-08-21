//
//  Device+Extension.swift
//  InventoryAppBeta1
//
//  Created by Harsh Verma on 18/05/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
import UIKit
extension UIDevice {
    static var isSimulator: Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
}

