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
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Digits.self, Crashlytics.self])
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        setKeyWindow()
        setWeChat()
        
        let notificationType: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationType, categories: nil)
        
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func setKeyWindow(){
        window = UIWindow(frame: MainBounds)
        window?.rootViewController = showLeadPage()
        window?.makeKeyAndVisible()
    }
    
    
    func showLeadPage()-> UIViewController{
        var nvc = BaseNavigationController(rootViewController: MainViewController())
        print(localStorage.object(forKey: localStorageKeys.WeChatAccessToken))
        print(localStorage.object(forKey: localStorageKeys.FBAccessToken))
        print(localStorage.object(forKey: localStorageKeys.EmailPwdAccessToken))

        if let _ = localStorage.object(forKey: localStorageKeys.WeChatAccessToken){
        } else if let _ = localStorage.object(forKey: localStorageKeys.FBAccessToken){
        } else if let _ = localStorage.object(forKey: localStorageKeys.EmailPwdAccessToken){
        } else if let _ = localStorage.object(forKey: localStorageKeys.PhoneAccessToken){
        } else{
            nvc = BaseNavigationController(rootViewController: LeadingViewController())
        }
        

        return nvc
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) || WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func setWeChat(){
        WXApi.registerApp("wx4919669d66798fb5")
    }
    
    func onReq(_ req: BaseReq!) {
        print(req.type)
    }
    
    func onResp(_ resp: BaseResp!) {
        if resp.isKind(of: SendAuthResp.self) {
            let response = resp as! SendAuthResp
            if response.code != nil{
                print("OK")
                print(response.code)
                print(window?.rootViewController)
                print(window?.rootViewController?.childViewControllers)
                for vc in (window?.rootViewController?.childViewControllers)!{
                    let className = NSStringFromClass(vc.classForCoder)
                    if className == "OnePartyGo.LeadingViewController" {
                        vc.getWeChatUserInfo(response.code)
                    }
                }
            } else {
                print("Fail to Login")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        localStorage.set(token, forKey: localStorageKeys.DeviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
        print("ssss")
    }
}
