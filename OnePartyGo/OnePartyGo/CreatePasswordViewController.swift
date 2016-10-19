//
//  CreatePasswordViewController.swift
//  Zouqiba
//
//  Created by Miibox on 9/6/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



class CreatePasswordViewController: BasicViewController, UITextFieldDelegate{
    @IBOutlet weak var PwdTextField: UITextField!
    @IBOutlet weak var VerifyPwdTextField: UITextField!
    @IBOutlet weak var ConfirmBtn: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var PwdWarningLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        

        PwdTextField.delegate = self
        PwdTextField.becomeFirstResponder()
        VerifyPwdTextField.delegate = self
        ConfirmBtn.layer.cornerRadius = 5
        ConfirmBtn.isEnabled = false
        ConfirmBtn.backgroundColor = UIColor.gray
        
        PwdTextField.isSecureTextEntry = true
        VerifyPwdTextField.isSecureTextEntry = true
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(CreatePasswordViewController.closeKeyboard))
        self.view.addGestureRecognizer(singleTap)
    }
    
    @IBAction func ClickConfirmBtn(_ sender: AnyObject) {
        let password = PwdTextField.text!
        localStorage.set(password, forKey: localStorageKeys.UserPwd)
        print("confirmed")
        loginProfileCheck()
    }
    
    
    func closeKeyboard(){
        PwdTextField.resignFirstResponder()
        VerifyPwdTextField.resignFirstResponder()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == VerifyPwdTextField{

            let userEnteredString = textField.text! as NSString
            let text = userEnteredString.replacingCharacters(in: range, with: string)
            verifyPwd(self.PwdTextField.text!,verifyText: text)

        }
        return true
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == PwdTextField{
            self.VerifyPwdTextField.becomeFirstResponder()
        } else {
            verifyPwd(self.PwdTextField.text!,verifyText: textField.text!)
            ClickConfirmBtn(ConfirmBtn)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        if textField == VerifyPwdTextField{
            verifyPwd(self.PwdTextField.text!,verifyText: textField.text!)
        } else{
            if textField.text?.characters.count < 6{
                ConfirmBtn.isEnabled = false
                ConfirmBtn.backgroundColor = UIColor.gray
                textField.backgroundColor = UIColor.init(rgb: 0xf98886)
            } else{
                textField.backgroundColor = UIColor.clear
            }
        }
    }
    
    func verifyPwd(_ pwdText: String, verifyText: String){
        if pwdText.characters.count >= 6{
            if pwdText == verifyText{
                ConfirmBtn.isEnabled = true
                ConfirmBtn.backgroundColor = UIColor.init(rgb: 0x744eaa)
                VerifyPwdTextField.backgroundColor = UIColor.clear
                PwdTextField.backgroundColor = UIColor.clear
            } else{
                ConfirmBtn.isEnabled = false
                ConfirmBtn.backgroundColor = UIColor.gray
                VerifyPwdTextField.backgroundColor = UIColor.init(rgb: 0xf98886)
            }
        }
    }
}
