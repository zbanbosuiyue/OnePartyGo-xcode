//
//  FacebookLogin.swift
//  Zouqiba
//
//  Created by Miibox on 8/19/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import Foundation

import FBSDKCoreKit
import FBSDKLoginKit

public func facebookLogin(_ vc: UIViewController){
    FBSDKLoginManager().logOut()
    
    let login = FBSDKLoginManager()
    login.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: vc) { (result, error) in
        if error != nil {
            print(error)
        } else if (result?.isCancelled)! {
            print("Cancelled")
        } else {
            //Show user information
            
            let fb_access_Token = FBSDKAccessToken.current().tokenString!
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name, picture.type(large)",])
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if ((error) != nil)
                {
                    // Process error
                    print("Error: \(error)")
                }else
                {
                    let fbUnMutableUserInfo = result as! NSDictionary
                    print("FB Result:  \(fbUnMutableUserInfo)")
                    let fbUserInfo = fbUnMutableUserInfo.mutableCopy() as! NSMutableDictionary
                    let pic = fbUserInfo["picture"] as! [String: NSDictionary]
                    print(pic)
                    let picData = pic["data"] as! [String : Any]
                    print("aaaa")
                    let fb_id = fbUserInfo["id"] as! String
                    
                    if let email = fbUserInfo["email"]{
                        print("bbbb")
                        localStorage.set(email, forKey: localStorageKeys.UserEmail)
                        localStorage.set(fb_id, forKey: localStorageKeys.FBId)
                        localStorage.set(fb_access_Token, forKey: localStorageKeys.FBAccessToken)
                    }
                    if let imageUrl = picData["url"]{
                        fbUserInfo.removeObject(forKey: "picture")
                        fbUserInfo.setObject(imageUrl, forKey: "picture" as NSCopying)
                        fbUserInfo.setObject(fb_access_Token, forKey: "fb_access_token" as NSCopying)
                        localStorage.set(fbUserInfo, forKey: localStorageKeys.FBUserInfo)
                        localStorage.set(imageUrl, forKey: localStorageKeys.UserHeadImageURL)
                    }
                    vc.getFBUserInfo(fb_id)
                }
            })
        }
    }
}
