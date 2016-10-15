//
//  ViewController.swift
//  zouqiTest2
//
//  Created by Miibox on 8/3/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit


class MainViewController: MainBasicViewController{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if QRMessage != nil{
            gotoURL(QRMessage)
        }
        self.navigationController?.navigationBar.hidden = false
        if isInit{
            setupUserImage()
            isInit = false
        }
        
        verisonChecker()
    }
    
    func initViews(){
        setNav()
        setMainMenuView()
        setMoreMenu()
        setKKMainWebView()
        checkAccessToken()
    }
    
    func checkAccessToken(){
        print("a")
        var parameters = [String : AnyObject]()
        print(localStorage.objectForKey(localStorageKeys.WeChatAccessToken))
        
        if let wechat_access_token = localStorage.objectForKey(localStorageKeys.WeChatAccessToken), wechat_openid = localStorage.objectForKey(localStorageKeys.WeChatOpenId){
            parameters["wechat_openid"] = wechat_openid
            parameters["wechat_access_token"] = wechat_access_token
            print("b")
        }
        
        if let fb_access_token = localStorage.objectForKey(localStorageKeys.FBAccessToken), fb_id = localStorage.objectForKey(localStorageKeys.FBId){
            parameters["fb_access_token"] = fb_access_token
            parameters["fb_id"] = fb_id
            print("c")
        }
        
        if let phone_access_token = localStorage.objectForKey(localStorageKeys.PhoneAccessToken), user_phone = localStorage.objectForKey(localStorageKeys.UserPhone){
            parameters["phone_access_token"] = phone_access_token
            parameters["user_phone"] = user_phone
            print("d")
        }
        
        if let email_pwd_access_token = localStorage.objectForKey(localStorageKeys.EmailPwdAccessToken), email = localStorage.objectForKey(localStorageKeys.UserEmail){
            parameters["email"] = email
            parameters["email_pwd_access_token"] = email_pwd_access_token
            print("e")
        }

        print(localStorage.objectForKey(localStorageKeys.UserHeadImageURL))
        let parametersString = parameters.stringFromHttpParameters()
        let url = BaseURL + "api/wp-test.php?\(parametersString)"
        gotoURL(url)
    }
    
    func setupUserImage(){
        let user_email = localStorage.objectForKey(localStorageKeys.UserEmail) as! String
        let imageUrl = BaseURL + "api/uploads/" + "\(user_email).png"
        
        userImageView.imageFromServerURL(imageUrl, completion: { (Detail, Success) in
            if Success{
                print("success")
                localStorage.setObject(imageUrl, forKey: localStorageKeys.UserHeadImageURL)
            } else{
                if let _ = localStorage.objectForKey(localStorageKeys.UserHeadImageURL){
                    
                } else{
                    let createImageAlter = UIAlertController(title: "Add Profile", message: "You can add your profile now or later", preferredStyle: .Alert)
                    let createImageOKAction = UIAlertAction(title: "Setup Now", style: .Default, handler: { (UIAlertAction) in
                        self.setUserProfile()
                    })
                    let createImageCancelAction = UIAlertAction(title: "Later", style: .Cancel, handler:nil)
                    createImageAlter.addAction(createImageOKAction)
                    createImageAlter.addAction(createImageCancelAction)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(createImageAlter, animated: true, completion: {
                            
                        })
                    })
                }
            }
        })
    }
    
    func getCookiesAndRedirect(){
        if LoginHTMLString != nil {
            //mainWebView.loadHTMLString(NetworkErrorMsg, BaseURL: NSURL(string: BaseURL))
            
            let url = NSURL(string: BaseURL)!
            let request = NSMutableURLRequest(URL: url)
            request.addValue(cookieString, forHTTPHeaderField: "Cookie")
            mainWebView.loadRequest(request)
            //mainWebView.loadHTMLString(LoginHTMLString, baseURL: url)
            
        } else{
            gotoURL(BaseURL)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


