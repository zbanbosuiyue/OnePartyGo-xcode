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
    func myPushViewController(vc: UIViewController, animated: Bool){
        for _vc in (self.navigationController?.childViewControllers)! {
            let className = NSStringFromClass(vc.classForCoder)
            let _className = NSStringFromClass(_vc.classForCoder)
            if className == _className {
                _ = self.navigationController?.popToViewController(_vc, animated: animated)
                return
            }
        }
        self.navigationController?.pushViewController(vc, animated: animated)
    }
    
    
    func finishLogin(_ actionTarget: UIAlertAction){
        self.myPushViewController(vc: MainViewController(), animated: true)
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
        if let FBUserInfo = localStorage.object(forKey: localStorageKeys.FBUserInfo) as? [String: AnyObject]{
            if let userHeadImageURL = FBUserInfo["picture"] as? String{
                localStorage.set(userHeadImageURL, forKey: localStorageKeys.UserHeadImageURL)
            }
            if let email = FBUserInfo[FBUserInfoSelector.email.rawValue] as? String{
                localStorage.set(email, forKey: localStorageKeys.UserEmail)
            }
        }
        
        ///Check if email and phone all setup
        if let email = localStorage.object(forKey: localStorageKeys.UserEmail) as? String, let phone = localStorage.object(forKey: localStorageKeys.UserPhone) as? String, let pwd = localStorage.object(forKey: localStorageKeys.UserPwd) as? String{
            let email = email
            let phone = phone
            let pwd = pwd
            
            createAppApiUser(email, phone: phone, pwd: pwd)
        } else{
            /// New Customer
            if isRegularLogin, let email = localStorage.object(forKey: localStorageKeys.UserEmail) as? String, let pwd = localStorage.object(forKey: localStorageKeys.UserPwd) as? String{
                    createAppApiUser(email, phone: "Regular", pwd: pwd)
            } else{
                createProfileAlert()
            }
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

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
            switch title{
            case "New Customer":
                self.myPushViewController(vc: CreateEmailViewController(), animated: true)
            case "Setup Password":
                self.myPushViewController(vc: CreatePasswordViewController(), animated: true)
            case "Setup Phone":
                self.myPushViewController(vc: CreatePhoneViewController(), animated: true)
            default:
                break
            }
            
        }))

        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func enterPwdAlert(_ title: String, message: String){
        let title = title
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
            self.myPushViewController(vc: LoginEnterPwdViewController(), animated: true)
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
        Alamofire.request(url, method: .get, parameters: parameter).validate().responseJSON { response in
            switch response.result {
            case .success:
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
            case .failure(let error):
                print(error)
            }
        }
    
        let modelName = UIDevice.current.modelName
        let systemVersion = UIDevice.current.systemVersion
        let systemName = UIDevice.current.systemName
        
        let parameters = [
            "model_name" : modelName,
            "system_version" : systemVersion,
            "system_name" : systemName
        ]
        
        Alamofire.request(url, method: .get, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success:
                print()
            case .failure(let error):
                print(error)
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
                    let image = UIImage(named: "default")
                    self.image = image
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
    }
    
}

extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
