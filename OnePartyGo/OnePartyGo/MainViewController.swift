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
        refreshCache()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if QRMessage != nil{
            gotoURL(QRMessage)
        }
        self.navigationController?.navigationBar.hidden = false
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


