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
    func finishLogin(_ actionTarget: UIAlertAction){
        self.navigationController?.pushViewController(MainViewController(), animated: true)
    }

    func createProfileAlert(){
        if let email = localStorage.object(forKey: localStorageKeys.UserEmail), let _ = localStorage.object(forKey: localStorageKeys.UserPhone), let _ = localStorage.object(forKey: localStorageKeys.UserPwd){
            
            /// Check All Profile  ////
            finishLoginAlert("Success", message: email as! String + " login.")
        } else if let _ = localStorage.object(forKey: localStorageKeys.UserEmail), let _ = localStorage.object(forKey: localStorageKeys.UserPhone){
            
            /// Email and phone ready, no passsword ////
            createProfileAlert("Setup Password", message: "Please enter your password")
        } else if let email = localStorage.object(forKey: localStorageKeys.UserEmail) as? String{
            /// Email ready, setup phone ///
            self.createProfileAlert("Setup Phone", message: email + " Please setup your phone number.")
        } else{
            /// Setup email ///
            DispatchQueue.main.async
            {
                if let name = localStorage.object(forKey: localStorageKeys.UserFirstName) as? String{
                    self.createProfileAlert("New Customer", message: name + " please setup your email as login name")
                }else{
                    self.createProfileAlert("New Customer", message: "Please setup your email as login name")
                }
            }
        }
    }
    
    
    
    func loginProfileCheck(){
        print(localStorage.object(forKey: localStorageKeys.UserEmail))
        if let FBUserInfo = localStorage.object(forKey: localStorageKeys.FBUserInfo) as? [String: AnyObject]{
            if let userHeadImageURL = FBUserInfo["picture"] as? String{
                localStorage.set(userHeadImageURL, forKey: localStorageKeys.UserHeadImageURL)
            }
            if let email = FBUserInfo[FBUserInfoSelector.email.rawValue] as? String{
                localStorage.set(email, forKey: localStorageKeys.UserEmail)
            }
        }
        
        print(localStorage.object(forKey: localStorageKeys.UserEmail))
        ///Check if email and phone all setup
        if let email = localStorage.object(forKey: localStorageKeys.UserEmail), let phone = localStorage.object(forKey: localStorageKeys.UserPhone), let pwd = localStorage.object(forKey: localStorageKeys.UserPwd){
            let email = email as! String
            let phone = phone as! String
            let pwd = pwd as! String
            
            createAppApiUser(email, phone: phone, pwd: pwd)
        } else{
            /// New Customer
            createProfileAlert()
        }
    }

    func showAlertDoNothing(_ title: String, message: String){
        let title = title
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func finishLoginAlert(_ title: String, message: String){
        let title = title
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: self.finishLogin))
        
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    
    func createProfileAlert(_ title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if let nvc = self.navigationController{
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
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
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
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
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func enterPwdAlert(_ title: String, message: String){
        let title = title
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
            self.navigationController!.pushViewController(LoginEnterPwdViewController(), animated: true)
        }))
        
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func verisonChecker(){
        var ifNeedShowAlert = false
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        print(localStorage.object(forKey: localStorageKeys.LastWarningDate))
        
        if let lastWarningDate = localStorage.object(forKey: localStorageKeys.LastWarningDate){
            let flags = NSCalendar.Unit.day
            let components = (calendar as NSCalendar).components(flags, from: lastWarningDate as! Date, to: currentDate, options: [])
            
            let differenceDay = components.day
            
            print(differenceDay)
            if differenceDay! > 0 {
                localStorage.set(currentDate, forKey: localStorageKeys.LastWarningDate)
                ifNeedShowAlert = true
            }
        } else{
            localStorage.set(currentDate, forKey: localStorageKeys.LastWarningDate)
            ifNeedShowAlert = true
        }
        
        
        let url = BaseURL + "api/update.php"
        let parameter = ["app_version" : CurrentVersion]
        Alamofire.request(url, method: .get, parameters: parameter)
            .responseJSON { response in
                if let data = response.result.value as? [String: Any]{
                    if let _ = data["error"] as? String {
                        let isForceUpdate = data["is_force_update"] as! Bool
                        let serverAppVersion = data["server_app_version"] as! Double
                        let updateUrl = data["update_url"] as! String
                        
                        if CurrentVersion < serverAppVersion {
                            if ifNeedShowAlert {
                                self.versionCheckAlert(updateUrl, isForceUpdate: isForceUpdate)
                            }
                        }
                        
                    }
                }
        }
        
    }
    
    // Alert
    func versionCheckAlert(_ url: String, isForceUpdate: Bool){
        let alert = UIAlertController(title: "New Version Available", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let updateAction = UIAlertAction(title: "Update", style: UIAlertActionStyle.default, handler: { action in
            UIApplication.shared.openURL(URL(string : url)!)
        })
        
        alert.addAction(updateAction)
        
        if !isForceUpdate{
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(cancelAction)
        }
        
        DispatchQueue.main.async
        {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkUserLogin() -> Bool{
        if let _ = localStorage.object(forKey: localStorageKeys.WeChatAccessToken){
            return true
        }
        if let _ = localStorage.object(forKey: localStorageKeys.FBAccessToken){
            return true
        }
        if let _ = localStorage.object(forKey: localStorageKeys.EmailPwdAccessToken){
            return true
        }
        if let _ = localStorage.object(forKey: localStorageKeys.PhoneAccessToken){
            return true
        }
        return false
    }
}



extension UIImageView {
    public func imageFromServerURL(_ urlString: String, completion: @escaping (_ Detail: AnyObject, _ Success: Bool) -> Void) {
        URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                completion("Not Valid URL" as AnyObject, false)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                if let image = UIImage(data: data!){
                    self.image = image
                    completion("" as AnyObject, true)
                } else{
                    completion("Not Valid URL" as AnyObject, false)
                }
                self.contentMode = .scaleAspectFit
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
    func resizeWith(_ width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

extension Dictionary {
    mutating func merge<K, V>(_ dict: [K: V]){
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
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
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
        
        return parameterArray.joined(separator: "&")
    }
    
}

extension Date
{
    func hour() -> Int
    {
        //Get Hour
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.hour, from: self)
        let hour = components.hour
        
        //Return Hour
        return hour!
    }
    
    
    func minute() -> Int
    {
        //Get Minute
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.minute, from: self)
        let minute = components.minute
        
        //Return Minute
        return minute!
    }
    
    func toShortTimeString() -> String
    {
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: self)
        
        //Return Short Time String
        return timeString
    }
}

struct Platform {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
        return TARGET_IPHONE_SIMULATOR != 0 // Use this line in Xcode 6
    }
    
}
