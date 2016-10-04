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
        let authButton = DGTAuthenticateButton(authenticationCompletion: { (session: DGTSession?, error: NSError?) in
            if (session != nil) {
                localStorage.setValue(session?.phoneNumber, forKey: localStorageKeys.UserPhone)
                self.createProfileAlert()
            } else {
                NSLog("Authentication error: %@", error!.localizedDescription)
            }
        })
        //authButton.digitsAppearance = self.makeTheme()
        authButton.center = self.view.center
        self.view.addSubview(authButton)
        
        navigationController?.navigationBar.hidden = false
        
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
