//
//  CreateEmailView.swift
//  Zouqiba
//
//  Created by Miibox on 8/31/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit


class CreateEmailViewController: BasicViewController, UITextFieldDelegate{
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var ConfirmBtn: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.hidden = false
        
        EmailTextField.delegate = self
        EmailTextField.becomeFirstResponder()
        ConfirmBtn.layer.cornerRadius = 5
        ConfirmBtn.enabled = false
        ConfirmBtn.backgroundColor = UIColor.init(rgb: 0xb9a6d4)
        
        TitleLabel.text = "Please enter your email address"
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(CreateEmailViewController.closeKeyboard))
        self.view.addGestureRecognizer(singleTap)
    }
    
    @IBAction func ClickConfirmBtn(sender: AnyObject) {
        let email = EmailTextField.text!
        localStorage.setObject(email, forKey: localStorageKeys.UserEmail)
        
        checkIfInfoExist("user_email", info_value: email) { (Detail, Exist) in
            if Exist{
                self.showAlertDoNothing("This email \(email) already registerred", message: "Please use other email.")
            } else{
                self.createProfileAlert()
            }
        }
        
    }

    
    func closeKeyboard(){
        EmailTextField.resignFirstResponder()
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let userEnteredString = textField.text! as NSString
        
        let text = userEnteredString.stringByReplacingCharactersInRange(range, withString: string)
        
        
        if isValidEmail(text){
            ConfirmBtn.enabled = true
            ConfirmBtn.backgroundColor = UIColor.init(rgb: 0x744eaa)
            textField.backgroundColor = UIColor.clearColor()
        } else {
            ConfirmBtn.enabled = false
            ConfirmBtn.backgroundColor = UIColor.init(rgb: 0xb9a6d4)
            textField.backgroundColor = UIColor.yellowColor()
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        ClickConfirmBtn(ConfirmBtn)
        
        return true
    }
}

