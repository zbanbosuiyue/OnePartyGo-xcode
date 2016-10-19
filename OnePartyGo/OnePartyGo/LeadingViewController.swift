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
    var isWechatInstall = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        
        let backgroundImageView = UIImageView(frame: CGRect(x: AppWidth * 0.2, y: AppHeight * 0.2, width: AppWidth * 0.6, height: AppHeight * 0.5))
        backgroundImageView.image = UIImage(named: "BigLogo")
        backgroundImageView.contentMode = .scaleAspectFit
        
        view.addSubview(backgroundImageView)
        
        var iconNum: CGFloat = 2.0
        
        if checkWeChatInstall(self){
            isWechatInstall = true
            iconNum = 3.0
        }
        print(iconNum)
        
        

        let iconPadding: CGFloat = AppWidth/(iconNum * 2)
        let iconWidth: CGFloat = (AppWidth - iconPadding * 2) / (5/3 * iconNum - 2/3)
        let iconGap = iconWidth * 2/3

        
        let startingHeight = backgroundImageView.frame.height + AppHeight * 0.25
        
        let phoneLoginBtn = UIButton(frame: CGRect(x: iconPadding, y: startingHeight, width: iconWidth, height: iconWidth))
        phoneLoginBtn.setImage(UIImage(named: "Iphone01"), for: UIControlState())
        phoneLoginBtn.contentMode = UIViewContentMode.scaleAspectFit
        phoneLoginBtn.addTarget(self, action: #selector(LeadingViewController.phoneLogin), for: .touchUpInside)
        
        print(isWechatInstall)
        
        if isWechatInstall{
            let wechatLoginBtn = UIButton(frame: CGRect(x: iconPadding + iconWidth + iconGap,y:  startingHeight, width: iconWidth, height: iconWidth))
            wechatLoginBtn.setImage(UIImage(named: "Wechat01"), for: UIControlState())
            wechatLoginBtn.contentMode = UIViewContentMode.scaleAspectFit
            wechatLoginBtn.addTarget(self, action: #selector(LeadingViewController.wechatLogin), for: .touchUpInside)
            
            view.addSubview(wechatLoginBtn)
        }

        
        let fbLoginBtn = UIButton(frame: CGRect(x: iconPadding + iconWidth * (iconNum - 1) + iconGap * (iconNum - 1), y: startingHeight, width: iconWidth, height: iconWidth))
        fbLoginBtn.setImage(UIImage(named: "Facebook01"), for: UIControlState())
        fbLoginBtn.contentMode = UIViewContentMode.scaleAspectFit
        fbLoginBtn.addTarget(self, action: #selector(LeadingViewController.fbLogin), for: .touchUpInside)
 

        
        view.addSubview(phoneLoginBtn)
        view.addSubview(fbLoginBtn)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        clearSession()
        //checkLogin()
        //verisonChecker()
    }
    
    
        

    func checkLogin(){
        if let user_email = localStorage.object(forKey: localStorageKeys.UserEmail), let _ = localStorage.object(forKey: localStorageKeys.UserPhone), let _ = localStorage.object(forKey: localStorageKeys.UserPwd)  {
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

