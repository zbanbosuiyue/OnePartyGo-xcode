//
//  WooCommerceAPI.swift
//  Zouqiba
//
//  Created by Miibox on 8/19/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import Foundation
import Alamofire
import JGProgressHUD

extension UIViewController{
    
    public func createAppApiUser(_ email: String, phone: String, pwd: String){
        var url:String!
        
        let customerInfo : NSMutableDictionary = [
            "user_email" : email,
            "user_pwd" : pwd,
            "user_phone" : phone
        ]
        
        if let wechatUserInfo = localStorage.object(forKey: localStorageKeys.WeChatUserInfo){
            url = BaseURL + "api/wp-create-wechat-user.php"
            customerInfo.addEntries(from: wechatUserInfo as! [AnyHashable: Any])
        }else if let fbUserInfo = localStorage.object(forKey: localStorageKeys.FBUserInfo){
            url = BaseURL + "api/wp-create-fb-user.php?"
            customerInfo.addEntries(from: fbUserInfo as! [AnyHashable: Any])
        } else{
            //Phone Only
            url = BaseURL + "api/wp-create-phone-user.php"
        }
    
        let parameters = customerInfo as NSDictionary
        
        
        Alamofire.request(url, method: .get, parameters: parameters as? Parameters)
            .responseJSON { response in
                
                let data = response.result.value as! [String: AnyObject]
                if let _ = data["exist"] as? Bool{
                    print("User Already Exists")
                } else{
                    if let phone_access_token = data["phone_access_token"] as? String{
                        localStorage.set(phone_access_token, forKey: localStorageKeys.PhoneAccessToken)
                    }
                    self.finishLoginAlert("Success", message: "\(email) has successfully login")
                }
        }
    }
    

    
    public func getWeChatUserInfo(_ response_code: String){
        let url = BaseURL + "api/wp-api.php?"
        let hud = JGProgressHUD(style: .light)
        hud?.textLabel.text = "Retriving info from Wechat"
        hud?.show(in: view, animated: true)

        Alamofire.request(url, method: .get, parameters: ["wechat_response_code" : response_code])
            .responseJSON { response in
                print(response.result.value)
                let data = NSMutableDictionary(dictionary: response.result.value! as! NSDictionary)
                if let userExist = data["user_exist"] as? Bool{
                    print("afsdf")
                    print(userExist)
                    if userExist == true{
                        print("bdfsf")
                        /// Old WeChat User Let them login
                        if let wechat_openid = data["open_id"], let access_token = data["access_token"], let user_email = data["user_email"]{
                            localStorage.set(user_email, forKey: localStorageKeys.UserEmail)
                            localStorage.set(access_token, forKey: localStorageKeys.WeChatAccessToken)
                            localStorage.set(wechat_openid, forKey: localStorageKeys.WeChatOpenId)
                            
                            self.navigationController?.pushViewController(MainViewController(), animated: true)
                        }
                    } else{
                        if userExist{
                            print("afefeeefe")
                            /// New WeChat User
                            let wechat_access_token = data["access_token"]
                            let wechat_open_id = data["openid"]
                            let wechat_headImage_url = data["headimgurl"]
                            
                                
                           
                            localStorage.set(wechat_access_token, forKey: localStorageKeys.WeChatAccessToken)
                            localStorage.set(wechat_open_id, forKey: localStorageKeys.WeChatOpenId)
                            localStorage.set(wechat_headImage_url, forKey: localStorageKeys.UserHeadImageURL)
                            localStorage.set(data, forKey: localStorageKeys.WeChatUserInfo)
                            
                            print("kkk")
                            
                            DispatchQueue.main.async(execute: { 
                                self.loginProfileCheck()
                            })
                        }
                    }
                }else{
                    print("wooew")
                }
                print("asafewe")
        }

    }
    
    

    
    public func getFBUserInfo(_ fb_id: String){
        let url = BaseURL + "api/wp-api.php?"
        
        Alamofire.request(url, method: .get, parameters: ["fb_id": fb_id])
            .responseJSON { response in
                
                
                let data = response.result.value as! [String: AnyObject]
                print(response.request)
                print(data)
                if let fb_access_token = data["fb_access_token"] as? String{
                    localStorage.set(fb_access_token, forKey: localStorageKeys.FBAccessToken)
                    self.navigationController?.pushViewController(MainViewController(), animated: true)
                }
                else{
                    if let email = localStorage.object(forKey: localStorageKeys.UserEmail){
                        self.createProfileAlert("Setup Phone", message: "\(email) please setup your phone for future login.")
                    }else{
                        self.createProfileAlert()
                    }
                }
            }
        }



    
    public func getPhoneUserInfo(_ phone_number: String){
        let url = BaseURL + "api/wp-api.php?"
        
        
        Alamofire.request(url, method: .get, parameters: ["phone_number": phone_number])
            .responseJSON { response in
                
                print(response.request)
                let data = response.result.value! as! [String: AnyObject]
                if let phone_access_token = data["phone_access_token"] as? String{
                    localStorage.set(phone_access_token, forKey: localStorageKeys.PhoneAccessToken)
                    self.navigationController?.pushViewController(MainViewController(), animated: true)
                }
                else{
                    print("Not found acccess token")
                }
            }
    }
    
    
    
    
    public func updateUserInfo(_ user_phone: String){
        let url = BaseURL + "/api/wp-update-info.php"
        
        var customerInfo = [ "user_phone"  : user_phone ]
        
        if let wechatUserInfo = localStorage.object(forKey: localStorageKeys.WeChatUserInfo) as? [String: Any]{
            
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
            
        }
        else if let fbUserInfo = localStorage.object(forKey: localStorageKeys.FBUserInfo) as? [String: Any]{
            let fb_access_token = localStorage.object(forKey: localStorageKeys.FBAccessToken)
            let user_image_url = localStorage.object(forKey: localStorageKeys.UserHeadImageURL)
            let fb_id = fbUserInfo["id"] as! String
            
            customerInfo["fb_access_token"] = fb_access_token as? String
            customerInfo["user_image_url"] = user_image_url as? String
            customerInfo["fb_id"] = fb_id
        }

        Alamofire.request(url, method: .get, parameters: customerInfo)
            .responseJSON { response in
                
                print(response.request)
                let data = response.result.value as! [String:Any]
                if let _ = data["Exist"] as? Bool{
                    self.showAlertDoNothing("Found phone number in database", message: "Updated your info")
                } else{
                    self.showAlertDoNothing("Error", message: "Phone not found in DB.")
                }
        }
    }

    
    public func uploadFileToServer(_ image: UIImage, imageName: String){
        let url = BaseURL + "api/upload.php"
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                if let imageData = UIImageJPEGRepresentation(image, 0.6) {
                    multipartFormData.append(imageData, withName: "fileToUpload", fileName: "\(imageName).png", mimeType: "image/png")
                }
            },
            to: url,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
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
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }
 

    public func checkIfInfoExist(_ info_key: String, info_value: String,  completion: @escaping (_ Detail: String, _ String: Bool) -> Void){
        let url = BaseURL + "api/wp-verify.php?"
        
        Alamofire.request(url, method: .get, parameters: [info_key: info_value])
            .responseJSON { response in
                

                let data = response.result.value as! [String: Any]
                if let _ = data["exist"] as? Bool{
                    if let user_email = data["user_email"] as? String{
                        completion(user_email, true)
                        localStorage.set(user_email, forKey: localStorageKeys.UserEmail)
                    }else{
                        completion("Phone exists, but email not found", true)
                    }
                } else{
                    completion("Network Problem", false)
                }
            }
    }
    
    
    
    public func WPEmailPwdLogin(_ user_email: String, pwd: String){
        let url = BaseURL + "api/wp-test.php"
        let parameters = [
            "user_email" : user_email,
            "pwd" : pwd
        ]
        
        Alamofire.request(url, method: .get, parameters: parameters)
            .responseJSON { response in
                
                
                let data = response.result.value as! [String: Any]
                if let _ = data["error"] as? String{
                    self.showAlertDoNothing("Invalid password", message: "Please try again")
                }else{
                    if let email_pwd_access_token = data["email_pwd_access_token"] as? String{
                        localStorage.set(email_pwd_access_token, forKey: localStorageKeys.EmailPwdAccessToken)
                        print(email_pwd_access_token)
                        self.navigationController?.pushViewController(MainViewController(), animated: true)
                    }else{
                        self.showAlertDoNothing("Network Problem", message: "Please check your connection")
                    }
                }
            }
    }
}







