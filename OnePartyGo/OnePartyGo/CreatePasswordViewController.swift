//
//  CreatePasswordViewController.swift
//  Zouqiba
//
//  Created by Miibox on 9/6/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit

import UIKit


class CreatePasswordViewController: BasicViewController, UITextFieldDelegate{
    @IBOutlet weak var PwdTextField: UITextField!
    @IBOutlet weak var VerifyPwdTextField: UITextField!
    @IBOutlet weak var ConfirmBtn: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var PwdWarningLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.hidden = false
        

        PwdTextField.delegate = self
        PwdTextField.becomeFirstResponder()
        VerifyPwdTextField.delegate = self
        ConfirmBtn.layer.cornerRadius = 5
        ConfirmBtn.enabled = false
        ConfirmBtn.backgroundColor = UIColor.grayColor()
        
        PwdTextField.secureTextEntry = true
        VerifyPwdTextField.secureTextEntry = true
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(CreatePasswordViewController.closeKeyboard))
        self.view.addGestureRecognizer(singleTap)
    }
    
    @IBAction func ClickConfirmBtn(sender: AnyObject) {
        let password = PwdTextField.text!
        localStorage.setObject(password, forKey: localStorageKeys.UserPwd)
        print("confirmed")
        loginProfileCheck()
    }
    
    
    func closeKeyboard(){
        PwdTextField.resignFirstResponder()
        VerifyPwdTextField.resignFirstResponder()
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        if textField == VerifyPwdTextField{

            let userEnteredString = textField.text! as NSString
            let text = userEnteredString.stringByReplacingCharactersInRange(range, withString: string)
            verifyPwd(self.PwdTextField.text!,verifyText: text)

        }
        return true
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == PwdTextField{
            self.VerifyPwdTextField.becomeFirstResponder()
        } else {
            verifyPwd(self.PwdTextField.text!,verifyText: textField.text!)
            ClickConfirmBtn(ConfirmBtn)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {

        if textField == VerifyPwdTextField{
            verifyPwd(self.PwdTextField.text!,verifyText: textField.text!)
        } else{
            if textField.text?.characters.count < 6{
                ConfirmBtn.enabled = false
                ConfirmBtn.backgroundColor = UIColor.grayColor()
                textField.backgroundColor = UIColor.init(rgb: 0xf98886)
            } else{
                textField.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    func verifyPwd(pwdText: String, verifyText: String){
        if pwdText.characters.count >= 6{
            if pwdText == verifyText{
                ConfirmBtn.enabled = true
                ConfirmBtn.backgroundColor = UIColor.init(rgb: 0x744eaa)
                VerifyPwdTextField.backgroundColor = UIColor.clearColor()
                PwdTextField.backgroundColor = UIColor.clearColor()
            } else{
                ConfirmBtn.enabled = false
                ConfirmBtn.backgroundColor = UIColor.grayColor()
                VerifyPwdTextField.backgroundColor = UIColor.init(rgb: 0xf98886)
            }
        }
    }
}
