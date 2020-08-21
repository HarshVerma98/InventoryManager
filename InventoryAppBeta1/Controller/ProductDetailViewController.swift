//
//  ProductDetailViewController.swift
//  InventoryAppBeta1
//
//  Created by Harsh Verma on 18/05/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import RealmSwift
import BRYXBanner
import Foundation

class ProductDetailViewController: FormViewController {
    
    let realm = try! Realm()
    var token: NotificationToken?
    var newProductMode = false
    var editMode = false
    var processingObjectUpdate = false
    var productId: String?
    var product: Products?
    var quantityTmp = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if newProductMode {
            let leftBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(BackCancelPressed) as Selector?)
            let rightBtn = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(SavePressed))
            self.navigationItem.leftBarButtonItem = leftBtn
            self.navigationItem.rightBarButtonItem = rightBtn
            
            product = Products()
            if productId != nil {
                product?.id = productId!
            }
        }
        else {
            product = realm.objects(Products.self).filter("id = %@", productId!).first
            let rightBtn = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(EditTaskPressed))
            self.navigationItem.rightBarButtonItem = rightBtn
        }
        
        form = createForm(editable: formIsEditable(), product: product)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if newProductMode == false {
            self.token = product?.observe { change in
                switch change {
                case .change(let properties):
                    for property in properties {
                        switch property.name {
                        case "productName":
                            let row = self.form.rowBy(tag: "productName")as! TextRow
                            self.processingObjectUpdate = true
                            row.updateCell()
                            break
                        case "productDescription":
                            let row = self.form.rowBy(tag: "productDescription")as! TextRow
                            self.processingObjectUpdate = true
                            row.updateCell()
                            break
                        case "image":
                            let row = self.form.rowBy(tag: "image") as! ImageRow
                            self.processingObjectUpdate = true
                            row.updateCell()
                            break
                        case "transactions":
                            let row = self.form.rowBy(tag: "QuantityOnHandRow") as! IntRow
                            self.processingObjectUpdate = true
                            row.updateCell()
                            break
                        default:
                            break
                        }
                    }
                    
                case .error(let error):
                    print("Error\(error)")
                case .deleted:
                    print("object Deleted")
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.token != nil {
            self.token = nil
        }
    }
    
    
    func createForm(editable: Bool, product: Products?) -> Form {
        let form = Form()
        form +++ Section(NSLocalizedString("Product Detail Information", comment: "Product Detail"))
            <<< TextRow(NSLocalizedString("Product ID", comment: "Product ID")) { row in
                row.tag = "Product ID"
                row.title = NSLocalizedString("Product ID", comment: "Product ID")
                if self.product!.id != "" {
                    let R = try! Realm()
                    try! R.write {
                        row.value = self.product!.id
                        R.add(self.product!, update: .modified)
                    }
                }
                
                if editable == false || newProductMode == false {
                    row.disabled = true
                }
            }.cellSetup { cell, row in
                cell.textField.placeholder = "Enter UPC Code"
                
            }.onChange({ (row) in
                self.product?.id = row.value!
            })
            
            
            
            <<< ImageRow() { row in
                row.tag = "image"
                row.title = "Profile Picture"
                row.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
                row.clearAction = .yes(style: .destructive)
                if editable == false {
                    row.disabled = true
                }
            }.cellSetup({ (cell, row) in
                if self.product?.image == nil {
                    row.value = UIImage(named: "Package")
                }else {
                    let imageData = self.product?.image!
                    row.value = UIImage(data: imageData! as Data)!
                }
            })
                
                .onChange({ (row) in
                    if row.value != nil {
                        let R = try! Realm()
                        try! R.write {
                            let resizedImage = row.value?.stretchableImage(withLeftCapWidth: 256, topCapHeight: 256)
                            self.product?.image = resizedImage?.pngData() as Data?
                            R.add(self.product!, update: .modified)
                        }
                    }else {
                        self.product?.image = nil
                        row.value = UIImage(named: "Package")
                    }
                })
            
            
            <<< TextRow() { row in
                row.tag = "productName"
                row.title = NSLocalizedString("Product Name", comment: "product name")
                row.placeholder = NSLocalizedString("Enter Product Name Here", comment: "product name")
                if self.product?.productname != "" {
                    row.value = self.product?.productname
                }
                if editable == false {
                    row.disabled = true
                }
            }.cellUpdate({ (cell , row) in
                row.value = self.product?.productname
            })
                .onChange({ (row) in
                    let R = try! Realm()
                    try! R.write {
                        self.product?.productname = row.value as! String
                        R.add(self.product!, update: .modified)
                    }
                })
            
            <<< TextRow() { row in
                row.tag = "productDescription"
                row.placeholder = NSLocalizedString("Product Description", comment: "description")
                if editable == false {
                    row.disabled = true
                }
            }.cellUpdate({ (cell, row) in
                row.value = self.product?.productDescription
            })
                .onChange({ (row) in
                    let R = try! Realm()
                    try! R.write {
                        if row.value != nil {
                            self.product?.productDescription = row.value!
                        }else {
                            self.product?.productDescription = ""
                        }
                        R.add(self.product!, update: .modified)
                    }
                })
            
            <<< IntRow() { row in
                row.tag = "QuantityOnHandRow"
            }
            .cellSetup({ (cell, row) in
                row.value = self.product?.quantityOnHand()
                if self.newProductMode == true {
                    row.title = NSLocalizedString("Initial Quantity", comment: "Initial Quantity on Hand")
                    row.placeholder = "initial quantity"
                }else {
                    row.title = NSLocalizedString("Quantity on Hand", comment: "Quantity on Hand")
                    row.placeholder = NSLocalizedString("No Stock", comment: "initial quantity")
                }
                if editable == false || self.product?.hasTransactionHistory() == true {
                    row.disabled = true
                }
            })
                
                .cellUpdate({ (cell, row) in
                    row.value = self.product!.quantityOnHand()
                    row.reload()
                })
                .onChange({ (row) in
                    self.quantityTmp = row.value!
                })
        
        
        if  newProductMode == false { // we never show this on the initial creation - users fill in the "initial quantity" instead
            form +++ Section(NSLocalizedString("Inventory Change Transaction", comment: "Inventory Change"))
                <<< StepperRow("Add or Subtract Items") { row in
                    row.tag = "quantityStepper"
                    row.title = NSLocalizedString("Add/Subtract", comment: "Add/Subtract")
                }
                .cellSetup({ (cell, row) in
                    cell.stepper.minimumValue = -(Double)(UINT64_MAX)
                })
                    .onChange({ (row) in
                        let actionButtonRow = form.rowBy(tag: "AddRemoveButton") as! ButtonRow
                        let qohRow = form.rowBy(tag: "QuantityOnHandRow") as! IntRow
                        
                        if row.value! < 0 {
                            actionButtonRow.disabled = false
                            actionButtonRow.title = NSLocalizedString("Subtract Quantity", comment: "Add")
                        } else if row.value! == 0{
                            actionButtonRow.disabled = true
                            actionButtonRow.title = NSLocalizedString("", comment: "Add")
                        } else if row.value! > 0 {
                            actionButtonRow.disabled = true
                            actionButtonRow.title = NSLocalizedString("Add Quantity", comment: "Add")
                        }
                        // However if we're removing items and the result of the requested change would be more
                        // would be more than the quantity on hand (QoH), clamp the value at the QoH
                        if  row.value! < 0 && (Int(qohRow.value!) - abs(Int(row.value!)) < 0) {
                            row.value! = Double(qohRow.value!) * -1
                        }
                        
                        actionButtonRow.updateCell()
                    })
                <<< ButtonRow() { row in
                    row.tag = "AddRemoveButton"
                    row.title = ""
                }.onCellSelection({ (cell, row)  in
                    let stepper = form.rowBy(tag: "quantityStepper") as! StepperRow
                    let qohRow = form.rowBy(tag: "QuantityOnHandRow") as! IntRow
                    var subtitle = ""
                    
                    if stepper.value != 0 {
                        self.product?.addTransaction(quantity: Int(stepper.value!), userIdentity: "Harsh")
                        if stepper.value! > 0 {
                            subtitle = "Added \(Int(stepper.value!)) item(s)."
                        } else {
                            subtitle = "Removed \(abs(Int(stepper.value!))) item(s)."
                        }
                        let banner = Banner(title: "Inventory Update Successful", subtitle: subtitle, image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                        banner.dismissesOnTap = true
                        banner.show(duration: 3.0)
                        stepper.value = 0
                        stepper.updateCell() // forces the stepper to update to zero
                        qohRow.updateCell() // forces the quantity on Hand to redisplay
                        
                    }
                })
        } // of if newProductMode
        
        return form
    }
    
    
    
    func formIsEditable() -> Bool {
        if newProductMode || editMode {
            return true
        }
        return false
    }
    
    // MARK: Actions
    @IBAction func BackCancelPressed(sender: AnyObject) {
        // Unwind/pop from the segue
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func EditTaskPressed(sender: AnyObject) {
        print("Edit Tasks Pressed")
        if editMode == true {
            //we're here because the user clicked edit (which now says "Done") ... so we're going to save the record with whatever they've changed
            self.SavePressed(sender: self)
            editMode = false
        } else {
            self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Done", comment: "Done")
            editMode = true
            
            form = createForm(editable: formIsEditable(), product: product)
        }
    }
    
    
    
    @IBAction func SavePressed(sender: AnyObject) {
        
        let rlm = try! Realm()
        try! rlm.write {
            if self.newProductMode {
                self.product?.creationDate = Date()
                self.product?.lastUpdate = Date()
            } else {
                self.product?.lastUpdate = Date()
            }
            rlm.add(self.product!, update: .modified)
            if self.newProductMode == true && self.quantityTmp > 0 {
                self.product?.addTransaction(quantity: self.quantityTmp, userIdentity: "SyncUser.current!.identity!")
            }
            
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
}


