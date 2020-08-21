//
//  LoginVC.swift
//  InventoryAppBeta1
//
//  Created by Harsh Verma on 22/05/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var errorLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupElts()
    }
    

    func setupElts() {
        errorLbl.alpha = 0
    }
    
  
    @IBAction func loginBtn(_ sender: Any) {
        
        let E = emailTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let P = passwordTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().signIn(withEmail: E, password: P) { (result, error) in
            
            if error != nil {
                self.errorLbl.text = error?.localizedDescription
                self.errorLbl.alpha = 1
            }
            else {
                let X = self.storyboard?.instantiateViewController(identifier: HVC) as? GetStarted
                self.view.window?.rootViewController = X
                self.view.window?.makeKeyAndVisible()
               
            }
            
        }
        
        
    }
    
}
