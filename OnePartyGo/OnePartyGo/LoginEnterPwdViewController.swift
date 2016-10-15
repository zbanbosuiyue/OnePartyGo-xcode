//
//  LoginEnterPwdViewController.swift
//  Zouqiba
//
//  Created by Miibox on 9/6/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit

class LoginEnterPwdViewController: BasicViewController, UITextFieldDelegate {
    @IBOutlet weak var LoginPwdTextField: UITextField!
    @IBOutlet weak var LoginBtn: UIButton!
    
    @IBOutlet weak var TitleLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.hidden = false
        
        LoginPwdTextField.delegate = self
        LoginPwdTextField.becomeFirstResponder()
        LoginPwdTextField.secureTextEntry = true
        
        
        LoginBtn.layer.cornerRadius = 5
        
        LoginBtn.backgroundColor = UIColor.init(rgb: 0x744eaa)
        
        TitleLable.text = "Enter your password"
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(CreateEmailViewController.closeKeyboard))
        self.view.addGestureRecognizer(singleTap)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func ClickLoginBtn(sender: AnyObject) {
        let pwd = LoginPwdTextField.text!
        if let email = localStorage.objectForKey(localStorageKeys.UserEmail){
            WPEmailPwdLogin(email as! String, pwd: pwd)
        }else{
            self.createProfileAlert()
        }
        
        
        
    }
    

    
    func closeKeyboard(){
        LoginPwdTextField.resignFirstResponder()
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        ClickLoginBtn(LoginBtn)
        
        return true
    }
}
