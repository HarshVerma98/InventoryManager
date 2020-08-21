//
//  SortOptionsTableViewController.swift
//  InventoryAppBeta1
//
//  Created by Harsh Verma on 18/05/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit

protocol SortOptionsSelectionProtocol {
    func didChangeSortOptions(sortTitle: String, sortProperty: String)
}

class SortOptionsTableViewController: UITableViewController {

    let sortOption: Array<Dictionary<String, String>> = [["productname": NSLocalizedString("Name", comment: "Name")], ["lastUpdate": NSLocalizedString("Updated", comment: "Updated")],
    ]
    
      var delegate: SortOptionsSelectionProtocol?
        let cellIdentifier = "SortOptionsCell"
        var currentlySelectedSortOption = "productName"
        
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
        }
        
        
        override func viewWillAppear(_ animated: Bool) {
            if currentlySelectedSortOption.isEmpty {
                currentlySelectedSortOption = "productname"
            }
        }
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return sortOption.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            let theOption: Dictionary<String, String> = sortOption[indexPath.row]
            
            cell.textLabel?.text = theOption.values.first
            if self.currentlySelectedSortOption == theOption.keys.first! {
                cell.accessoryType = .checkmark
            }else {
                cell.accessoryType = .none
            }
            return cell
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let theOption: Dictionary<String,String> = sortOption[indexPath.row]
            delegate?.didChangeSortOptions(sortTitle: theOption.values.first!, sortProperty: theOption.keys.first!)
            self.dismiss(animated: true, completion: nil)
        }
    }

