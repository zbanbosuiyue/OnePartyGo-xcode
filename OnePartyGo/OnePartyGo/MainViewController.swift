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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if QRMessage != nil{
            if QRMessage.contains("Too Many"){
                showAlertDoNothing("Error", message: QRMessage)
                QRMessage = nil
            }else{
                gotoURL(QRMessage)
            }
            
        }
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func getCookiesAndRedirect(){
        if LoginHTMLString != nil {
            //mainWebView.loadHTMLString(NetworkErrorMsg, BaseURL: NSURL(string: BaseURL))
            
            let url = URL(string: BaseURL)!
            let request = NSMutableURLRequest(url: url)
            //request.addValue(cookieString, forHTTPHeaderField: "Cookie")
            mainWebView.load(request as URLRequest)
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


