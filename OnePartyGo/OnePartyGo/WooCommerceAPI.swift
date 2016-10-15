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
    
    public func createAppApiUser(email: String, phone: String, pwd: String){
        var url:String!
        
        let customerInfo : NSMutableDictionary = [
            "user_email" : email,
            "user_pwd" : pwd,
            "user_phone" : phone
        ]
        
        if let wechatUserInfo = localStorage.objectForKey(localStorageKeys.WeChatUserInfo){
            url = BaseURL + "api/wp-create-wechat-user.php"
            customerInfo.addEntriesFromDictionary(wechatUserInfo as! [NSObject : AnyObject])
        }else if let fbUserInfo = localStorage.objectForKey(localStorageKeys.FBUserInfo){
            url = BaseURL + "api/wp-create-fb-user.php?"
            customerInfo.addEntriesFromDictionary(fbUserInfo as! [NSObject : AnyObject])
        } else{
            //Phone Only
            url = BaseURL + "api/wp-create-phone-user.php"
        }
    
        let parameters = customerInfo as NSDictionary
        
        Alamofire.request(.GET, url, parameters: parameters as? [String : AnyObject]).responseJSON { response in
            print(response.request)
            switch response.result{
            case .Failure:
                print(response.result.error)
            case .Success:
                let data = response.result.value!
                if let _ = data["exist"] as? Bool{
                    print("User Already Exists")
                } else{
                    self.finishLoginAlert("Success", message: "\(email) has successfully login")
                }
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
                case .Failure( _):
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
                    case .Failure( _):
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
                print(response.result.error)
                hud.textLabel.text = "Network Problem"
            case .Success:
                print(response.result.value)
                let data = NSMutableDictionary(dictionary: response.result.value! as! NSDictionary)
                if let userExist = data["user_exist"] as? Bool{
                    if userExist{
                        /// Old WeChat User Let them login
                        if let wechat_openid = data["open_id"], access_token = data["access_token"], user_email = data["user_email"]{
                            localStorage.setObject(user_email, forKey: localStorageKeys.UserEmail)
                            localStorage.setObject(access_token, forKey: localStorageKeys.WeChatAccessToken)
                            localStorage.setObject(wechat_openid, forKey: localStorageKeys.WeChatOpenId)
                            
                            self.navigationController?.pushViewController(MainViewController(), animated: true)
                        }
                        
                    } else{
                        /// New WeChat User
                        localStorage.setObject(data, forKey: localStorageKeys.WeChatUserInfo)
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
                print(response.request)
                let data = response.result.value!
                if let fb_access_token = data["fb_access_token"] as? String{
                    localStorage.setObject(fb_access_token, forKey: localStorageKeys.FBAccessToken)
                    self.navigationController?.pushViewController(MainViewController(), animated: true)
                }
                else{
                    if let email = localStorage.objectForKey(localStorageKeys.UserEmail){
                        self.createProfileAlert("Setup Phone", message: "\(email) please setup your phone for future login.")
                    }else{
                        self.createProfileAlert()
                    }
                }
            }
        }
    }
    
    
    public func getPhoneUserInfo(phone_number: String){
        let url = BaseURL + "api/wp-api.php?"
        
        Alamofire.request(.GET, url, parameters: ["phone_number": phone_number]).responseJSON { response in
            print(response.request)
            switch response.result{
            case .Failure:
                print(response.result.error)
            case .Success:
                print(response.request)
                let data = response.result.value!
                if let phone_access_token = data["phone_access_token"] as? String{
                    localStorage.setObject(phone_access_token, forKey: localStorageKeys.PhoneAccessToken)
                    self.navigationController?.pushViewController(MainViewController(), animated: true)
                }
                else{
                    print("Not found acccess token")
                }
            }
        }
    }
    
    
    
    public func updateUserInfo(user_phone: String){
        let url = BaseURL + "/api/wp-update-info.php"
        
        var customerInfo = [ "user_phone"  : user_phone ]
        
        if let wechatUserInfo = localStorage.objectForKey(localStorageKeys.WeChatUserInfo){
            
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
            let fb_access_token = localStorage.objectForKey(localStorageKeys.FBAccessToken)
            let user_image_url = localStorage.objectForKey(localStorageKeys.UserHeadImageURL)
            let fb_id = fbUserInfo["id"] as! String
            
            customerInfo["fb_access_token"] = fb_access_token as? String
            customerInfo["user_image_url"] = user_image_url as? String
            customerInfo["fb_id"] = fb_id
        }
        
        Alamofire.request(.GET, url, parameters: customerInfo).responseJSON { response in
            print(response.request)
            switch response.result{
            case .Failure:
                print(response.result.error)
            case .Success:
                print(response.request)
                let data = response.result.value!
                if let _ = data["Exist"] as? Bool{
                    self.showAlertDoNothing("Found phone number in database", message: "Updated your info")
                } else{
                    self.showAlertDoNothing("Error", message: "Phone not found in DB.")
                }
            }
        }
    }
    
    
    public func uploadFileToServer(image: UIImage, imageName: String){
        let parameters = [
            "par1": "value",
            "par2": "value2"]
        
        let url = BaseURL + "api/upload.php"

        Alamofire.upload(.POST, url, multipartFormData: {
            multipartFormData in
            
            if let imageData = UIImageJPEGRepresentation(image, 0.6) {
                multipartFormData.appendBodyPart(data: imageData, name: "fileToUpload", fileName: "\(imageName).png", mimeType: "image/png")
            }
            for (key, value) in parameters {
                multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
            }
            }, encodingCompletion: {
                encodingResult in
                
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON {
                        response in
                        print(response.request)  // original URL request
                        print(response.response) // URL response
                        //print(response.data)     // server data
                        debugPrint(response.result)   // result of response serialization
                        print("lll")
                        debugPrint(response.result.value)
                        
                        if let JSON = response.result.value {
                            print("JSON: \(JSON)")
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        })
    
    }
 

    public func checkIfInfoExist(info_key: String, info_value: String,  completion: (Detail: String, Exist: Bool) -> Void){
        let url = BaseURL + "api/wp-verify.php?"
        
        Alamofire.request(.GET, url, parameters: [info_key: info_value]).responseJSON { response in
            print(response.request)
            switch response.result{
            case .Failure:
                completion(Detail: "Network Problem", Exist: false)
            case .Success:
                let data = response.result.value!
                if let _ = data["exist"] as? Bool{
                    if let user_email = data["user_email"] as? String{
                        completion(Detail: user_email, Exist: true)
                        localStorage.setObject(user_email, forKey: localStorageKeys.UserEmail)
                    }else{
                        completion(Detail: "Phone exists, but email not found", Exist: true)
                    }
                    completion(Detail: "Network Problem", Exist: false)
                } else{
                    completion(Detail: "Network Problem", Exist: false)
                }
            }
        }
        
    }
    
    
    public func WPEmailPwdLogin(user_email: String, pwd: String){
        let url = BaseURL + "api/wp-test.php"
        let parameters = [
            "user_email" : user_email,
            "pwd" : pwd
        ]
        
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            print(response.request)
            switch response.result{
            case .Failure:
                print(response.result.error)
            case .Success:
                let data = response.result.value!
                if let _ = data["error"] as? String{
                    self.showAlertDoNothing("Invalid password", message: "Please try again")
                }else{
                    if let email_pwd_access_token = data["email_pwd_access_token"] as? String{
                        localStorage.setObject(email_pwd_access_token, forKey: localStorageKeys.EmailPwdAccessToken)
                        self.navigationController?.pushViewController(MainViewController(), animated: true)
                    }else{
                        self.showAlertDoNothing("Network Problem", message: "Please check your connection")
                    }
                }
            }
        }

        
    }

}






