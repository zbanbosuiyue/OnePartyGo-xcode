//
//  WooCommerceAPI.swift
//  Zouqiba
//
//  Created by Miibox on 8/19/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import Foundation
import Alamofire
import Kanna
import JGProgressHUD


private let WCConsumerKey = "ck_d9416856e0192556cfb0810cb27df38647adad5b"
private let WCSecretKey = "cs_3e86cad7fd7260dd449ccd1e706e7f64a72bc15d"


extension UIViewController{
    
    public func createAppApiUser(email: String, phone: String, pwd: String, completion:(Detail: AnyObject, Success: Bool) -> Void){
        var url:String!
        
        var customerInfo = [
            "user_email" : email,
            "user_pwd" : pwd,
            "user_phone" : phone
        ]
        
        if let wechatUserInfo = localStorage.objectForKey(localStorageKeys.WeChatUserInfo){
            url = BaseURL + "api/wp-create-wechat-user.php"
            
            let wechat_access_token = wechatUserInfo["access_token"] as! String
            let wechat_refresh_token = wechatUserInfo["refresh_token"] as! String
            let wechat_open_id = wechatUserInfo["openid"] as! String
            let wechat_union_id = wechatUserInfo["unionid"] as! String
            let user_image_url = wechatUserInfo["headimgurl"] as! String
        
            customerInfo["wechat_access_token"] = wechat_access_token
            customerInfo["wechat_refresh_token"] = wechat_refresh_token
            customerInfo["wechat_openid"] = wechat_open_id
            customerInfo["wechat_unionid"] = wechat_union_id
            customerInfo["user_image_url"] = user_image_url

        }else if let fbUserInfo = localStorage.objectForKey(localStorageKeys.FBUserInfo){
            url = BaseURL + "api/wp-create-fb-user.php?"
            
            
            let fb_access_token = localStorage.objectForKey(localStorageKeys.FBAccessToken)
            let user_image_url = localStorage.objectForKey(localStorageKeys.UserHeadImageURL)
            let fb_id = fbUserInfo["id"] as! String

            customerInfo["fb_access_token"] = fb_access_token as? String
            customerInfo["user_image_url"] = user_image_url as? String
            customerInfo["fb_id"] = fb_id
            
        } else{
            print("Wechat Info Nil and FB info Nil Too")
        }
        
        Alamofire.request(.GET, url, parameters: customerInfo).responseString { response in
            print(response.request)
            let data = response.result.value!
            if data.containsString("Success"){
                print(data)
                completion(Detail: "", Success: true)
            }else{
                completion(Detail: data, Success: false)
                print(data)
            }
        }
        
    }
    
    public func createWCCustomer(email: String, phone: String, pwd: String, completion: (Detail: AnyObject, Success: Bool) -> Void){
        
        let hud = JGProgressHUD(style: .Light)
        hud?.textLabel.text = "Creating Customer"
        hud?.showInView(view)
        
        let customerInfo = [
            "customer" : [
                "email" : email,
                "password" : pwd,
                "billing" : [
                    "phone" : phone
                ]
            ]
        ]
        
        let url = NSURL(string: "\(BaseURL)/wc-api/v3/customers?consumer_key=\(WCConsumerKey)&consumer_secret=\(WCSecretKey)")!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(customerInfo, options: [])
        
        Alamofire.request(request)
            .responseJSON { response in
                
                switch response.result {
                case .Failure(let error):
                    completion(Detail: "Network Problem", Success: false)
                    hud.textLabel.text = "Network Problem"
                    
                case .Success(let responseObject):
                    let responseContent = responseObject as! [String : AnyObject]
                    if let errors = responseContent["errors"] as? [[String : AnyObject]]{
                        completion(Detail: errors, Success: true)
                    } else{
                        completion(Detail: "Created Customer Success", Success: true)
                    }
                }
                
                hud.dismissAnimated(true)
                hud.dismissAfterDelay(1.0)
                
        }
        
        
    }
    
    public func loginToWC(uname: String, pwd: String, completion: (Detail: String, Success: Bool) -> Void){
        let hud = JGProgressHUD(style: .Light)
        hud?.textLabel.text = "Try to login"
        hud?.showInView(view)
        
        
        if let nonce = WCNonce{
            let loginInfo = [
                "username" : uname,
                "password" : pwd,
                "woocommerce-login-nonce" : nonce,
                "_wp_http_referer" : "/my-account/",
                "login" : "Login"
            ]
            
            Alamofire.request(.POST, BaseURL, parameters: loginInfo)
                .validate().responseString { response in
                    hud.dismiss()
                    switch response.result {
                    case .Failure(let error):
                        completion(Detail: "Network Problem", Success: false)
                        
                    case .Success(let responseObject):
                        LoginHTMLString = responseObject
                        if let
                            headerFields = response.response?.allHeaderFields as? [String: String],
                            let URL = response.request?.URL
                        {
                            let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: URL)
                            if cookies.isEmpty{
                                completion(Detail: "Username or password not correct.", Success: false)
                                self.showAlertDoNothing("Error", message: "Wrong password. Please try again.")
                            } else{
                                completion(Detail: "Success", Success: true)

                            }
                        }
                        
                        
                    }
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.showAlertDoNothing("Error", message: "Can't get Nonce from website")
            })
        }
        
    }
    
    public func getWCNonce(){
        let url = BaseURL + "/my-account/"
        Alamofire.request(.GET, url).validate()
            .responseString { response in
                switch response.result{
                case .Failure(let error):
                    print(error)
                case .Success(let responseObject):
                    let html = responseObject
                   if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                        for link in doc.xpath(".//*[@id='woocommerce-login-nonce']"){
                            WCNonce = link["value"]
                        }
                    }
                }
        }
    }
    
    public func getWCCustomerInfo(email: String, completion: (Detail: AnyObject, Success: Bool) -> Void){
        let hud = JGProgressHUD(style: .Light)
        hud?.textLabel.text = "Finding Customer"
        hud?.showInView(view)
        
        
        let url = NSURL(string: "\(BaseURL)/wc-api/v3/customers/email/\(email)?consumer_key=\(WCConsumerKey)&consumer_secret=\(WCSecretKey)")!
        Alamofire.request(.GET, url).validate()
            .responseJSON { response in
                hud.dismiss()
                
                switch response.result{
                case .Failure(let error):
                    completion(Detail: error, Success: false)
                    
                case .Success(let responseObject):
                    completion(Detail: responseObject, Success: true)
                }
        }
    }
    
    public func getWeChatUserInfo(response_code: String){
        let url = BaseURL + "api/wp-api.php?"
        
        let hud = JGProgressHUD(style: .Light)
        hud?.textLabel.text = "Retriving info from Wechat"
        hud?.showInView(view, animated: true)
        
        Alamofire.request(.GET, url, parameters: ["wechat_response_code" : response_code]).responseJSON { response in
            hud.dismiss()
            print(response.request)
            switch response.result{
            case .Failure:
                hud.textLabel.text = "Network Problem"
            case .Success:
                let data = response.result.value!
                if let userExist = data["user_exist"]{
                    let userExist = userExist as! Bool
                    if userExist{
                        print(data)
                        /// Get userEmail and pwd to login.
                        let user_email = data["user_email"] as! String
                        let user_phone = data["user_phone"] as! String
                        let user_pwd = data["user_pwd"] as! String
                        let user_image_url = data["user_image_url"]
                        
                        let wechat_access_token = data["wechat_access_token"]
                        let wechat_refresh_token = data["wechat_refresh_token"]
                        let wechat_openid = data["wechat_openid"]
                        
                        localStorage.setObject(user_email, forKey: localStorageKeys.UserEmail)
                        localStorage.setObject(user_phone, forKey: localStorageKeys.UserPhone)
                        localStorage.setObject(user_pwd, forKey: localStorageKeys.UserPwd)
                        localStorage.setObject(user_image_url, forKey: localStorageKeys.UserHeadImageURL)
                        
                        localStorage.setObject(wechat_access_token, forKey: localStorageKeys.WeChatAccessToken)
                        localStorage.setObject(wechat_refresh_token, forKey: localStorageKeys.WeChatRefreshToken)
                        localStorage.setObject(wechat_openid, forKey: localStorageKeys.WeChatOpenId)
                        
                        
                        
                        self.loginToWC(user_email, pwd: user_pwd, completion: { (Detail, Success) in
                            if Success{
                                print(data)
                                self.showViewController(MainViewController(), sender: self)
                            } else{
                                print("failed")
                            }
                        })
                        
                    } else{
                        print(data)
                        let wechatUserInfo = data
                        localStorage.setObject(wechatUserInfo, forKey: localStorageKeys.WeChatUserInfo)
                        dispatch_async(dispatch_get_main_queue()){
                           self.loginProfileCheck()
                        }
                    }
                }
            }
            
            
        }
    }
    
    public func getFBUserInfo(fb_id: String){
        let url = BaseURL + "api/wp-api.php?"
        
        Alamofire.request(.GET, url, parameters: ["fb_id": fb_id]).responseJSON { response in
            print(response.request)
            switch response.result{
            case .Failure:
                print(response.result.error)
            case .Success:
                let data = response.result.value!
                if let userExist = data["user_exist"]{
                    let userExist = userExist as! Bool
                    if userExist{
                        print(data)
                        /// Get pwd to login.
                        let user_email = data["user_email"] as! String
                        let user_phone = data["user_phone"] as! String
                        let user_pwd = data["user_pwd"] as! String
                        let user_image_url = data["user_image_url"]
                        
                        let fb_access_token = data["fb_access_token"]
                        let fb_id = data["fb_id"]

                        localStorage.setObject(user_email, forKey: localStorageKeys.UserEmail)
                        localStorage.setObject(user_phone, forKey: localStorageKeys.UserPhone)
                        localStorage.setObject(user_pwd, forKey: localStorageKeys.UserPwd)
                        localStorage.setObject(user_image_url, forKey: localStorageKeys.UserHeadImageURL)
                        
                        localStorage.setObject(fb_access_token, forKey: localStorageKeys.FBAccessToken)
                        localStorage.setObject(fb_id, forKey: localStorageKeys.FBId)
                        

                        self.loginToWC(user_email, pwd: user_pwd, completion: { (Detail, Success) in
                            if Success{
                                print(data)
                                self.showViewController(MainViewController(), sender: self)
                            } else{
                                print("failed")
                            }
                        })
                        
                    } else{
                        dispatch_async(dispatch_get_main_queue()){
                            self.loginProfileCheck()
                        }
                    }
                }
            }
            
            
        }

    }
    

    
}






