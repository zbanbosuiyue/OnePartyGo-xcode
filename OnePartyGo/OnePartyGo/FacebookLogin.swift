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

public func facebookLogin(vc: UIViewController){
    FBSDKLoginManager().logOut()
    
    let login = FBSDKLoginManager()
    login.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: vc) { (result, error) in
        if error != nil {
            print(error)
        } else if result.isCancelled {
            print("Cancelled")
        } else {
            //Show user information
            
            let fb_access_Token = FBSDKAccessToken.currentAccessToken().tokenString
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name, picture.type(large)",])
            
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                if ((error) != nil)
                {
                    // Process error
                    print("Error: \(error)")
                }else
                {
                    let fbUnMutableUserInfo = result as! NSDictionary
                    
                    let fbUserInfo = fbUnMutableUserInfo.mutableCopy() as! NSMutableDictionary
                
                    let fb_id = fbUserInfo["id"] as! String
                    
                    if let email = fbUserInfo["email"]{
                        localStorage.setObject(email, forKey: localStorageKeys.UserEmail)
                        localStorage.setObject(fb_id, forKey: localStorageKeys.FBId)
                        localStorage.setObject(fb_access_Token, forKey: localStorageKeys.FBAccessToken)
                    }
                    if let imageUrl = fbUserInfo["picture"]!["data"]!!["url"]{
                        fbUserInfo.removeObjectForKey("picture")
                        fbUserInfo.setObject(imageUrl!, forKey: "picture")
                        fbUserInfo.setObject(fb_access_Token, forKey: "fb_access_token")
                        localStorage.setObject(fbUserInfo, forKey: localStorageKeys.FBUserInfo)
                        localStorage.setObject(imageUrl, forKey: localStorageKeys.UserHeadImageURL)
                        print(imageUrl)
                    }
                    vc.getFBUserInfo(fb_id)
                }
            })
        }
    }
}
