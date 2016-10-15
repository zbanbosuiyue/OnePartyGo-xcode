//
//  MainFunctions.swift
//  zouqiTest2
//
//  Created by Miibox on 8/4/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Alamofire
import AVFoundation
import ObjectiveC



// Creates a UIColor from a Hex string.
extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}



extension UIViewController {
    func finishLogin(actionTarget: UIAlertAction){
        self.navigationController?.pushViewController(MainViewController(), animated: true)
    }

    func createProfileAlert(){
        if let email = localStorage.objectForKey(localStorageKeys.UserEmail), let _ = localStorage.objectForKey(localStorageKeys.UserPhone), let _ = localStorage.objectForKey(localStorageKeys.UserPwd){
            
            /// Check All Profile  ////
            finishLoginAlert("Success", message: email as! String + " login.")
        } else if let _ = localStorage.objectForKey(localStorageKeys.UserEmail), let _ = localStorage.objectForKey(localStorageKeys.UserPhone){
            
            /// Email and phone ready, no passsword ////
            createProfileAlert("Setup Password", message: "Please enter your password")
        } else if let email = localStorage.objectForKey(localStorageKeys.UserEmail) as? String{
            /// Email ready, setup phone ///
            self.createProfileAlert("Setup Phone", message: email + " has been registered, but you need to setup your phone number.")
        } else{
            /// Setup email ///
            if let name = localStorage.objectForKey(localStorageKeys.UserFirstName) as? String{
                createProfileAlert("New Customer", message: name + " please setup your email as login name")
            }else{
                createProfileAlert("New Customer", message: "Please setup your email as login name")
            }
        }
    }
    
    
    
    func loginProfileCheck(){
        if let FBUserInfo = localStorage.objectForKey(localStorageKeys.FBUserInfo){
            if let userHeadImageURL = FBUserInfo["picture"]{
                localStorage.setObject(userHeadImageURL, forKey: localStorageKeys.UserHeadImageURL)
            }
            if let email = FBUserInfo[FBUserInfoSelector.email.rawValue]!{
                localStorage.setObject(email, forKey: localStorageKeys.UserEmail)
            }
        }
        
        if let WeChatUserInfo = localStorage.objectForKey(localStorageKeys.WeChatUserInfo){
            if let userHeadImageURL = WeChatUserInfo[WeChatUserInfoSelector.headImgURL.rawValue]{
                localStorage.setObject(userHeadImageURL, forKey: localStorageKeys.UserHeadImageURL)
            }
            
            if let name = WeChatUserInfo[WeChatUserInfoSelector.name.rawValue]{
                localStorage.setObject(name, forKey: localStorageKeys.UserFirstName)
            }
        }
        
        
        ///Check if email and phone all setup
        if let email = localStorage.objectForKey(localStorageKeys.UserEmail), let phone = localStorage.objectForKey(localStorageKeys.UserPhone), let pwd = localStorage.objectForKey(localStorageKeys.UserPwd){
            let email = email as! String
            let phone = phone as! String
            let pwd = pwd as! String
            
            createAppApiUser(email, phone: phone, pwd: pwd)
        } else{
            if let email = localStorage.objectForKey(localStorageKeys.UserEmail) {
                let email = email as! String
                getWCCustomerInfo(email, completion: { (Detail, Success) in
                    
                    /// Existing User, let them enter pwd to login.
                    if Success{
                        if let phone = Detail["customer"]!!["billing_address"]!!["phone"]{
                            localStorage.setObject(phone, forKey: localStorageKeys.UserPhone)
                            self.enterPwdAlert("Email Found", message: email + " has been registered, please login.")
                        }
                    }else{
                        self.createProfileAlert("Setup Phone", message: email + " please setup your phone number.")
                    }
                })
            }else{
                /// New Customer
                createProfileAlert()
            }
        }
    }
    
    // Alert
    func updateShowError(){
        let alert = UIAlertController(title: "New Version Available", message: "Must Update to Newest Version", preferredStyle: UIAlertControllerStyle.Alert)
        
        let updateAction = UIAlertAction(title: "Update", style: UIAlertActionStyle.Default, handler: updateHandle)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: cancelHandle)
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Update Handle
    func updateHandle(alter: UIAlertAction!){
        print("Update")
        UIApplication.sharedApplication().openURL(NSURL(string : "https://itunes.apple.com/us/app/miibox/id1033286619?mt=8")!)
    }
    
    func cancelHandle(alert: UIAlertAction!){
        print("Cancel")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        updateShowError()
    }
    
    
    
    func showAlertDoNothing(title: String, message: String){
        let title = title
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func finishLoginAlert(title: String, message: String){
        let title = title
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: self.finishLogin))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    
    func createProfileAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        if let nvc = self.navigationController{
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(UIAlertAction) in
                switch title{
                case "New Customer":
                    nvc.pushViewController(CreateEmailViewController(), animated: true)
                case "Setup Password":
                    nvc.pushViewController(CreatePasswordViewController(), animated: true)
                case "Setup Phone":
                    nvc.pushViewController(CreatePhoneViewController(), animated: true)
                default:
                    break
                }
                
            }))
        } else{
            let nvc = self.childViewControllers.first?.navigationController
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(UIAlertAction) in
                switch title{
                case "New Customer":
                    nvc!.pushViewController(CreateEmailViewController(), animated: true)
                case "Setup Password":
                    nvc!.pushViewController(CreatePasswordViewController(), animated: true)
                case "Setup Phone":
                    nvc!.pushViewController(CreatePhoneViewController(), animated: true)
                default:
                    break
                }
                
            }))
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func enterPwdAlert(title: String, message: String){
        let title = title
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(UIAlertAction) in
            self.navigationController!.pushViewController(LoginEnterPwdViewController(), animated: true)
        }))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    
}



extension UIImageView {
    public func imageFromServerURL(urlString: String, completion: (Detail: AnyObject, Success: Bool) -> Void) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                completion(Detail: "Not Valid URL", Success: false)
                return
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let image = UIImage(data: data!){
                    print("sss")
                    self.image = image
                    completion(Detail: "", Success: true)
                } else{
                    print("kk")
                    completion(Detail: "Not Valid URL", Success: false)
                }
                self.contentMode = .ScaleAspectFit
            })
        }).resume()
    }
}

extension String {
    public func localize() -> String{
        let s = NSLocalizedString(self, comment: self)
        return s
    }
}

extension UIImage {
    func resizeWith(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.renderInContext(context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

extension Dictionary {
    mutating func merge<K, V>(dict: [K: V]){
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}

extension String {
    
    /// Percent escapes values to be added to a URL query as specified in RFC 3986
    ///
    /// This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: Returns percent-escaped string.
    
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
    }
    
}

extension Dictionary {
    
    /// Build string representation of HTTP parameter dictionary of keys and objects
    ///
    /// This percent escapes in compliance with RFC 3986
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joinWithSeparator("&")
    }
    
}


struct Platform {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
        return TARGET_IPHONE_SIMULATOR != 0 // Use this line in Xcode 6
    }
    
}
