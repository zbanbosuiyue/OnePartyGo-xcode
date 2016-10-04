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
    }
    
    func initViews(){
        setNav()
        setMainMenuView()
        setMoreMenu()
        setKKMainWebView()
        
        setupUserImage()
        getCookiesAndRedirect()
        isInit = false
    }
    
    
    func setupUserImage(){
        if let userHeadImgURL = localStorage.objectForKey(localStorageKeys.UserHeadImageURL){
        }else{
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


