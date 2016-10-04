//
//  CreateUserProfileViewController.swift
//  Zouqiba
//
//  Created by Miibox on 9/2/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit
import DigitsKit

class CreateUserProfileViewController: UIViewController {
    var isEmail = false
    var isPhone = false
    var isValid = false

    @IBOutlet weak var ProfileTitleLabel: UILabel!
    @IBOutlet weak var ProfileTextField: UITextField!
    @IBOutlet weak var ConfirmBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProfileTextField.delegate = self
        ConfirmBtn.enabled = false

        if let _ = localStorage.objectForKey(localStorageKeys.UserEmail){
        } else{
            isEmail = true
        }
        
        if let _ = localStorage.objectForKey(localStorageKeys.UserPhone){
        } else{
            isPhone = true
        }
        
        if isEmail{
            ProfileTitleLabel.text = "Please enter your email address"
            ProfileTextField.keyboardType = .EmailAddress
        }

        
        // Do any additional setup after loading the view.
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clickConfirmBtn(){
        print("clicked")
        if isEmail{
            let email = ProfileTextField.text
            localStorage.setObject(email, forKey: localStorageKeys.UserEmail)
            
            if let phone = localStorage.objectForKey(localStorageKeys.UserPhone){
                /// Email and phone ready
                createCustomer(email!, phone: phone as! String)
            } else {
                /// Email ready, but Phone not ready
                createPhonePage()
            }
        }
        
        if isPhone{
            let phone = ProfileTextField.text
            localStorage.setObject(phone, forKey: localStorageKeys.UserPhone)
            
            if let email = localStorage.objectForKey(localStorageKeys.UserEmail){
                /// Email and Phone Ready
                createCustomer(email as! String, phone: phone!)
            } else {
                /// Phone ready, but email nont ready
                createEmailPage()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CreateUserProfileViewController: UITextFieldDelegate{
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let text = textField.text!
        if isEmail{
            if isValidEmail(text){
                ConfirmBtn.enabled = true
                ConfirmBtn.backgroundColor = UIColor.init(rgb: 0x744eaa)
                textField.backgroundColor = UIColor.clearColor()
            } else {
                ConfirmBtn.enabled = false
                isValid = true
                ConfirmBtn.backgroundColor = UIColor.grayColor()
                textField.backgroundColor = UIColor.init(rgb: 0xbbbbbb)
            }
        }
        
        
        return true
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if isValid{
            clickConfirmBtn()
        }
        return true
    }
}
