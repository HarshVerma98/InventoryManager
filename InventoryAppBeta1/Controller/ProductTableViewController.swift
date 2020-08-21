//
//  ProductTableViewController.swift
//  InventoryAppBeta1
//
//  Created by Harsh Verma on 18/05/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import BarcodeScanner
import Realm

class ProductTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate, SortOptionsSelectionProtocol {

    var realm = try! Realm()
        var notificationToken: NotificationToken? = nil
       // let myIdentity = SyncUser.current?.identity!
        var products: Results<Products>?
        var sortProperty = "productname"
        var sortAscending = true
        var sortDirectionButtonItem: UIBarButtonItem!
        var searchBar: UISearchBar = UISearchBar()
        var newProductID: String?
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            sortDirectionButtonItem = self.navigationItem.leftBarButtonItems![1]
            sortDirectionButtonItem.action = #selector(toggleSortDirection)
            sortDirectionButtonItem.title = self.sortAscending ? "⬆️" : "⬇️"
            searchBar.delegate = self
            searchBar.searchBarStyle = .prominent
            searchBar.placeholder = "Search"
            searchBar.sizeToFit()
            searchBar.isTranslucent = false
            searchBar.backgroundImage = UIImage()
            navigationItem.titleView = searchBar
            
            products = realm.objects(Products.self).sorted(byKeyPath: sortProperty, ascending: sortAscending ? true : false)
            notificationToken = products?.observe { [weak self] (changes: RealmCollectionChange) in
                guard let tableView = self?.tableView else {return}
                switch changes {
                case .initial:
                    tableView.reloadData()
                    break
                case .update(_, let deletions, let insertions, let modifications):
                    tableView.beginUpdates()
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                    tableView.endUpdates()
                    break
                    
                case .error(let error):
                    fatalError("Error\(error)")
                    break
                }
                
            }
            
        }
        
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let selectedRow = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedRow, animated: true)
            }
            self.restoreEntries()
        }
        
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
            
        }
        
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return products?.count ?? 0
        }
        
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 120.0
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let product = products![indexPath.row]
            var qohString = ""
            product.quantityOnHand() > 0 ? (qohString = NSLocalizedString("(\(product.quantityOnHand())) in stock", comment: "QoH String")) : (qohString = NSLocalizedString("(out of stock)", comment: "Out"))
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath as IndexPath)
            cell.textLabel?.text = product.productname
            cell.detailTextLabel?.lineBreakMode = .byWordWrapping
            cell.detailTextLabel?.numberOfLines = 3
            cell.detailTextLabel?.text = "\(product.productDescription) \(qohString)"
            if let productImg = product.image {
                cell.imageView?.image = UIImage(data: productImg)?.stretchableImage(withLeftCapWidth: 110, topCapHeight: 110)
            }else {
                cell.imageView?.image = UIImage(named: "Package")?.stretchableImage(withLeftCapWidth: 110, topCapHeight: 110)
            }
            return cell
        }
        
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: kInventoryToProductDetail, sender: self)
        }
        
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == kInventoryToProductDetail {
                let indexPath = tableView.indexPathForSelectedRow
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                
                let vc = segue.destination as? ProductDetailViewController
                vc!.productId = products![indexPath!.row].id
                vc!.hidesBottomBarWhenPushed = true
            }
            
            if segue.identifier == kInventoryToNewProduct {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                let vc = segue.destination as? ProductDetailViewController
                vc?.navigationItem.title = NSLocalizedString("New Task", comment: "New Task")
                vc?.newProductMode = true
                if newProductID != nil {
                    vc?.productId = newProductID!
                }
                vc?.navigationItem.title = NSLocalizedString("New Product", comment: "New Product")
                vc?.hidesBottomBarWhenPushed = true
            }
            
            if segue.identifier == kSortingPopoverSegue {
                let sortSelectorController = segue.destination as! SortOptionsTableViewController
                sortSelectorController.preferredContentSize = CGSize(width: 250, height: 150)
                sortSelectorController.delegate = self
                sortSelectorController.currentlySelectedSortOption = self.sortProperty
                
                let popoverController = sortSelectorController.popoverPresentationController
                if popoverController != nil {
                    popoverController?.delegate = self
                    popoverController?.backgroundColor = UIColor.red
                }
            }
            
        }
        
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return .none
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String) {
            if textSearched != "" {
                config()
                let predicate = NSPredicate(format: "productname CONTAINS[c] %@ OR productDescription CONTAINS[c] %@ OR id CONTAINS[c] %@", textSearched, textSearched, textSearched)
                products = realm.objects(Products.self).filter(predicate)
            }else {
                products = realm.objects(Products.self).sorted(byKeyPath: sortProperty, ascending: sortAscending ? true : false)
            }
            tableView.reloadData()
        }
        
        
        func didChangeSortOptions(sortTitle: String, sortProperty: String) {
            self.sortProperty = sortProperty
            self.navigationItem.leftBarButtonItem?.title = NSLocalizedString("by \(sortTitle)", comment: "Sorted by Interpolation")
        }
        
        @IBAction func toggleSortDirection() {
            sortAscending = !self.sortAscending
            self.restoreEntries()
        }
        
        func restoreEntries() {
            sortDirectionButtonItem.title = self.sortAscending ? "⬆️" : "⬇️"
            self.navigationItem.leftBarButtonItem?.title = NSLocalizedString("by \(self.sortProperty)", comment: "Sorted by Interpolation")
            products = self.products?.sorted(byKeyPath: self.sortProperty, ascending: self.sortAscending ? true: false)
            tableView.reloadData()
        }
        
        
        
        @IBAction func scanBarcodeTap(_ sender: Any) {
            if UIDevice.isSimulator == false {
                let controller = BarcodeScannerViewController()
                controller.dismissalDelegate = self
                controller.errorDelegate = self
                controller.codeDelegate = self
                present(controller, animated: true, completion: nil)
            }
            else {
                inSimulatorAlert(message: NSLocalizedString("Unavailable on Simulator", comment: "No Scanner"))
            }
        }
        
        
        @IBAction func addButtonTapped(_ sender: Any) {
            performSegue(withIdentifier: kInventoryToNewProduct, sender: self)
        }
        
        func jumpToProduct(productId: String) {
            if let row = products?.index(matching: "id == '\(productId)'") {
                tableView.selectRow(at: IndexPath(row: row, section: 0),animated: false, scrollPosition: .middle)
                performSegue(withIdentifier: kInventoryToProductDetail, sender: self)
            }
        }
        
        
        func findByProductID(productID: String) -> Bool {
            if let result = products?.filter("id = %@", productID).first {
                return true
            }
            else {
                return false
            }
        }
        
        
        func inSimulatorAlert(message: String) {
            let alert = UIAlertController(title: "iOS Simulator", message: message, preferredStyle: .alert)
            let cancelBtn = UIAlertAction(title: "OK", style: .cancel) { (action: UIAlertAction!) in
                
            }
            alert.addAction(cancelBtn)
            present(alert, animated: true, completion: nil)
        }
        
        
        func proposeNewProduct(productId: String) {
            let message = NSLocalizedString("Create new product for id\(productId)?", comment: "Create?")
            let alert = UIAlertController(title: "Unknown Product ID", message: message, preferredStyle: .alert)
            let createAction = UIAlertAction(title: "Create", style: .default) { (action:UIAlertAction!) in
                self.newProductID = productId
                self.performSegue(withIdentifier: kInventoryToNewProduct, sender: self)
            }
            alert.addAction(createAction)
            
            let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                print("Tapped Cancel")
            }
            alert.addAction(cancelBtn)
            present(alert, animated: true, completion: nil)
        }
    }


    extension ProductTableViewController: BarcodeScannerCodeDelegate {
        func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
            controller.dismiss(animated: true, completion: nil)
            if findByProductID(productID: code) {
                jumpToProduct(productId: code)
            }else {
                proposeNewProduct(productId: code)
            }
        }
    }


    extension ProductTableViewController: BarcodeScannerErrorDelegate {
        func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
            print(error.localizedDescription)
        }
    }

    extension ProductTableViewController: BarcodeScannerDismissalDelegate {
        func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
            controller.dismiss(animated: true, completion: nil)
        }
    }

