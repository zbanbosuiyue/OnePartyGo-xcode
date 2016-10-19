//
//  WeChatLogin.swift
//  Zouqiba
//
//  Created by Miibox on 8/19/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import Foundation

public func weChatLogin(_ vc: UIViewController){
    if WXApi.isWXAppInstalled(){
        print("wechat login")
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "123"
        WXApi.send(req)
    } else{
        vc.showAlertDoNothing("WeChat Not Found", message: "Wechat not installed. Please use Phone or Facebook to login. ")
    }
}

public func checkWeChatInstall(_ vc: UIViewController) -> Bool{
    if WXApi.isWXAppInstalled(){
        print("wechat Installed")
        return true
    } else{
        print("wechat Not Installed")
        return false
    }
}
