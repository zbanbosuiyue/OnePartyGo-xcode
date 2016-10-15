//
//  AppDelegate.swift
//  Zouqiba
//
//  Created by Miibox on 8/12/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit
import Fabric
import DigitsKit
import Crashlytics
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
import JGProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {
    
    let facebookReadPermissions = ["public_profile", "email", "user_friends"]
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Digits.self, Crashlytics.self])
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        setKeyWindow()
        setWeChat()
        return true
    }
    
    func setKeyWindow(){
        window = UIWindow(frame: MainBounds)
        window?.rootViewController = showLeadPage()
        window?.makeKeyAndVisible()
    }
    
    
    func showLeadPage()-> UIViewController{
        var nvc = BaseNavigationController(rootViewController: MainViewController())
        print(localStorage.objectForKey(localStorageKeys.WeChatAccessToken))
        print(localStorage.objectForKey(localStorageKeys.FBAccessToken))
        print(localStorage.objectForKey(localStorageKeys.EmailPwdAccessToken))

        
        if let _ = localStorage.objectForKey(localStorageKeys.WeChatAccessToken){
        } else if let _ = localStorage.objectForKey(localStorageKeys.FBAccessToken){
        } else if let _ = localStorage.objectForKey(localStorageKeys.EmailPwdAccessToken){
        } else if let _ = localStorage.objectForKey(localStorageKeys.PhoneAccessToken){
        } else{
            nvc = BaseNavigationController(rootViewController: LeadingViewController())
        }

        return nvc
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) || WXApi.handleOpenURL(url, delegate: self)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    func setWeChat(){
        WXApi.registerApp("wx4919669d66798fb5")
    }
    
    func onReq(req: BaseReq!) {
        print(req.type)
    }
    
    func onResp(resp: BaseResp!) {
        if resp.isKindOfClass(SendAuthResp) {
            let response = resp as! SendAuthResp
            if response.code != nil{
                print("OK")
                window?.rootViewController?.childViewControllers.first?.getWeChatUserInfo(response.code)
                
            } else {
                print("Fail to Login")
            }
        }
    }
    
}
