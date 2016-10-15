//
//  LeadingViewController.swift
//  zouqiTest2
//
//  Created by Miibox on 8/5/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit

public let Show_ValidatePageViewController_Notification = "Show_ValidatePageViewController_Notification"

class LeadingViewController: BasicViewController{
    var validateView: UIView!
    
    var numberTextField: UITextField!
    var actionSheet: UIAlertController!
    var startBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        
        let backgroundImageView = UIImageView(frame: CGRectMake(AppWidth * 0.2, AppHeight * 0.2, AppWidth * 0.6, AppHeight * 0.5))
        backgroundImageView.image = UIImage(named: "BigLogo")
        backgroundImageView.contentMode = .ScaleAspectFit
        
        view.addSubview(backgroundImageView)

        let iconPadding: CGFloat = 50.0
        let iconWidth: CGFloat = (AppWidth - iconPadding * 2) / 4.5

        
        let iconGap: CGFloat = (AppWidth - 2 * iconPadding - 3 * iconWidth) / 2
        
        let startingHeight = backgroundImageView.frame.height + AppHeight * 0.25
        
        let phoneLoginBtn = UIButton(frame: CGRect(x: iconPadding, y: startingHeight, width: iconWidth, height: iconWidth))
        phoneLoginBtn.setImage(UIImage(named: "Iphone01"), forState: .Normal)
        phoneLoginBtn.contentMode = UIViewContentMode.ScaleAspectFit
        phoneLoginBtn.addTarget(self, action: #selector(LeadingViewController.phoneLogin), forControlEvents: .TouchUpInside)
        
        
        let wechatLoginBtn = UIButton(frame: CGRect(x: iconPadding + iconWidth + iconGap,y:  startingHeight, width: iconWidth, height: iconWidth))
        wechatLoginBtn.setImage(UIImage(named: "Wechat01"), forState: .Normal)
        wechatLoginBtn.contentMode = UIViewContentMode.ScaleAspectFit
        wechatLoginBtn.addTarget(self, action: #selector(LeadingViewController.wechatLogin), forControlEvents: .TouchUpInside)
        
        let fbLoginBtn = UIButton(frame: CGRect(x: iconPadding + iconWidth * 2 + iconGap * 2, y: startingHeight, width: iconWidth, height: iconWidth))
        fbLoginBtn.setImage(UIImage(named: "Facebook01"), forState: .Normal)
        fbLoginBtn.contentMode = UIViewContentMode.ScaleAspectFit
        fbLoginBtn.addTarget(self, action: #selector(LeadingViewController.fbLogin), forControlEvents: .TouchUpInside)
 

        
        view.addSubview(phoneLoginBtn)
        view.addSubview(wechatLoginBtn)
        view.addSubview(fbLoginBtn)
    }
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.hidden = true
        clearSession()
        checkLogin()
        verisonChecker()
    }
    
    
        

    func checkLogin(){
        if let user_email = localStorage.objectForKey(localStorageKeys.UserEmail), let _ = localStorage.objectForKey(localStorageKeys.UserPhone), let _ = localStorage.objectForKey(localStorageKeys.UserPwd)  {
            finishLoginAlert("Welcome", message: user_email as! String + " is successfully login")
        }
    }
    
    func phoneLogin(){
        //addChildViewController(FabricViewController())
        self.navigationController?.pushViewController(CreatePhoneViewController(), animated: true)
    }
    
    func wechatLogin(){
        weChatLogin(self)
    }
    
    
    func fbLogin(){
        facebookLogin(self)
    }
    
    func sendPostToWC(){
        self.navigationController?.pushViewController(CreateEmailViewController(), animated: true)
    }
    
    
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
}

