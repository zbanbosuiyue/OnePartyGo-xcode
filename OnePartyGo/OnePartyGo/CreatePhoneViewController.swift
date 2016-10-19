//
//  PhoneViewController.swift
//  zouqiTest2
//
//  Created by Miibox on 8/12/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit
import DigitsKit
import Crashlytics


class CreatePhoneViewController: BasicViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let authButton = DGTAuthenticateButton { (DGTSession, Error) in
            if (DGTSession != nil) {
                let phone = DGTSession?.phoneNumber
                localStorage.setValue(phone, forKey: localStorageKeys.UserPhone)
                
                self.checkIfInfoExist("user_phone", info_value: phone!, completion: { (Detail, Exist) in
                    if Exist{
                        let email = Detail
                        
                        let alertController = UIAlertController(title: "Phone already used by other account", message: "Do you want to login through this email: \(email)?", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
                            self.navigationController!.pushViewController(LoginEnterPwdViewController(), animated: true)
                        }))
                        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(UIAlertAction) in
                            
                        }))
                        
                        DispatchQueue.main.async(execute: {
                            self.present(alertController, animated: true, completion: nil)
                        })
                        
                    } else{
                        self.createProfileAlert()
                    }
                })
                
                
            } else {
                NSLog("Authentication error: %@", Error!.localizedDescription)
            }

        }
    
        //authButton.digitsAppearance = self.makeTheme()
        authButton?.center = self.view.center
        self.view.addSubview(authButton!)
        
        navigationController?.navigationBar.isHidden = false
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    func makeTheme() -> DGTAppearance {
        let theme = DGTAppearance();
        theme.bodyFont = UIFont(name: "Noteworthy-Light", size: 16);
        theme.labelFont = UIFont(name: "Noteworthy-Bold", size: 17);
        theme.accentColor = UIColor(red: (255.0/255.0), green: (172/255.0), blue: (238/255.0), alpha: 1);
        theme.backgroundColor = UIColor(red: (240.0/255.0), green: (255/255.0), blue: (250/255.0), alpha: 1);
        
        
        // TODO: set a UIImage as a logo with theme.logoImage
        return theme;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
