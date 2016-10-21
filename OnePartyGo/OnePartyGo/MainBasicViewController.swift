//
//  MainBasicViewController.swift
//  zouqiTest2
//
//  Created by Miibox on 8/5/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit
import WebKit
import FBSDKShareKit
import ImagePicker
import JGProgressHUD
import Alamofire

class MainBasicViewController: BasicViewController {
    
    var isOpenedMainMenu = false
    var isOpenedMoreMenu = false
    
    var mainMenuView: UIView!
    var userImageView: UIImageView!
    var moreMenuView: UIView!
    var mainWebView: WKWebView!
    var blurEffectView: UIVisualEffectView!
    var navBar: UINavigationBar!
    var currentWindow: UIWindow!
    let swipeRecognizer = UISwipeGestureRecognizer()
    var hud: JGProgressHUD!
    

    
    func setNav(){
        navigationController?.navigationBar.isHidden = false
        
        let mainMenuItem = UIBarButtonItem(image: UIImage(named: "Menu"), style: .plain, target: self, action: #selector(MainViewController.openMainMenu))
        
        let moreMenuItem = UIBarButtonItem(image: UIImage(named: "moreMenu"), style: .plain, target: self, action: #selector(MainViewController.clickMoreMenu(_:)))
        
        
        let logoImage = UIImage(named: "Logo")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = logoImage
        
        navigationItem.titleView = imageView
        
        navigationItem.leftBarButtonItem = mainMenuItem
        navigationItem.rightBarButtonItem = moreMenuItem
        
        //navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.tintColor = UIColor.black
        
        currentWindow = UIApplication.shared.keyWindow
        
        
        hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Loading..."
        hud.textLabel.textColor = UIColor.init(rgb: 0x888888)

        
    }
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    /* ----                  Main MenuView Section                    ---- */
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    
    /// Set MainMenu
    func setMainMenuView(){
        mainMenuView = UIView()
        mainMenuView.frame = CGRect(x: -AppWidth * 0.382 , y: StatusHeight + 5,  width: 0, height: 0)
        mainMenuView.backgroundColor = UIColor.white
        mainMenuView.layer.shadowColor = UIColor.gray.cgColor
        mainMenuView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        mainMenuView.layer.shadowOpacity = 0.8
        mainMenuView.layer.shadowRadius = 2.0
        mainMenuView.tag = -1
    }
    

    
    func refreshCache(){
        userImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 80, height: 80))
    
        if let userHeadImageNSData = localStorage.object(forKey: localStorageKeys.UserHeadImage){
            let userHeadImage = UIImage(data: userHeadImageNSData as! Data)
            userImageView.image = userHeadImage
        }else if let url = localStorage.object(forKey: localStorageKeys.UserHeadImageURL){
                userImageView.imageFromServerURL(url as! String, completion: { (Detail, Success) in
                })
        }else if let user_email = localStorage.object(forKey: localStorageKeys.UserEmail) as? String {
                let imageUrl = BaseURL + "api/uploads/" + "\(user_email).png"
                userImageView.imageFromServerURL(imageUrl, completion: { (Detail, Success) in
                })
        } else{
            userImageView.image = UIImage(named: "default")
        }
    }
    
    /// Trigger OpenMainMenu
    func openMainMenu(_ sender: AnyObject){
        if !isOpenedMainMenu{
            if isOpenedMoreMenu{
                closingMoreMenu()
            }
            openingMainMenu()
            
        } else{
            print("closingMainMenu")
            closingMainMenu()
        }
        
    }
    
    /// Open Main Menu
    func openingMainMenu(){
        addBlurEffect()
        

        userImageView.layer.borderWidth = 1
        userImageView.layer.masksToBounds = false
        userImageView.layer.borderColor = UIColor.gray.cgColor
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        userImageView.clipsToBounds = true
        userImageView.contentMode = .scaleAspectFit
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MainBasicViewController.setUserProfile))
        userImageView.addGestureRecognizer(tap)
        userImageView.isUserInteractionEnabled = true
        
        let mainMenuTableView = TableMenuView(frame:CGRect(x: 0, y: userImageView.frame.height + 10, width: AppWidth * 0.382, height: AppHeight * 0.382))
        mainMenuView.addSubview(mainMenuTableView)
        mainMenuTableView.titles = MainMenuBtnArr as [NSString]
        
        if checkUserLogin(){
            mainMenuTableView.titles.remove(at: 1)
        } else{
            mainMenuTableView.titles.remove(at: 3)
        }
        
        mainMenuTableView.font = MainMenuBtnFont
        mainMenuTableView.tableView?.rowHeight = 35
        mainMenuTableView.delegate = self
        mainMenuTableView.menuId = 1
        
        currentWindow.addSubview(mainMenuView)
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.mainMenuView.frame = CGRect(x: 0, y: StatusHeight + 5, width: AppWidth * 0.382, height: AppHeight * 0.5)
            
            }, completion: { (Bool) -> Void in
                self.mainMenuView.addSubview(self.userImageView)
                self.mainMenuView.addSubview(mainMenuTableView)
        })
        
        isOpenedMainMenu = true
    }
    
    
    
    /// Close Main Menu
    func closingMainMenu(){
        for v in mainMenuView.subviews {
            v.removeFromSuperview()
        }
        removeBlurEffect()
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.mainMenuView.frame = CGRect(x: -AppWidth * 0.382 , y: StatusHeight + 5, width: 0, height: 0)
            }, completion: { (Bool) -> Void in
                self.mainMenuView.removeFromSuperview()
        })
        isOpenedMainMenu = false
    }
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    /* ----                More Menu Section          ---- */
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    func setMoreMenu(){
        moreMenuView = UIView()
        //moreMenuView.frame = CGRectMake(AppWidth, MainViewHeight, AppWidth * 0.3, AppHeight * 0.2)
        moreMenuView.frame = CGRect(x: AppWidth, y: StatusHeight + 5,  width: 0,  height: 0)
        moreMenuView.backgroundColor = UIColor.white
        
        moreMenuView.layer.shadowColor = UIColor.gray.cgColor
        moreMenuView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        moreMenuView.layer.shadowOpacity = 0.8
        moreMenuView.layer.shadowRadius = 2.0
        moreMenuView.tag = -1
        
    }
    
    /// Trigger OpenMoreMenu
    func clickMoreMenu(_ sender: AnyObject){
        if !isOpenedMoreMenu{
            if isOpenedMainMenu{
                closingMainMenu()
            }
            openingMoreMenu()
        } else{
            closingMoreMenu()
        }
    }
    
    
    /// Opening More Menu
    func openingMoreMenu(){
        addBlurEffect()
        currentWindow.addSubview(moreMenuView)
        
        let moreMenuTableView = TableMenuView(frame: CGRect(x: 0, y: 10, width: AppWidth * 0.3, height: AppHeight * 0.3))
        moreMenuTableView.titles = MoreMenuBtnArr as [NSString]
        
        if !checkWeChatInstall(self){
            moreMenuTableView.titles.remove(at: 0)
            moreMenuTableView.titles.remove(at: 1)
        }
        
        moreMenuTableView.font = MoreMenuBtnFont
        moreMenuTableView.tableView?.rowHeight = 30
        moreMenuTableView.delegate = self
        moreMenuTableView.menuId = 2
        
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.moreMenuView.frame = CGRect(x: AppWidth * 0.7, y: StatusHeight + 5, width: AppWidth * 0.3, height: AppHeight * 0.2)
            }, completion: { (Bool) -> Void in
                self.moreMenuView.addSubview(moreMenuTableView)
        })
        
        isOpenedMoreMenu = true
    }
    
    
    /// closingMoreMenu
    func closingMoreMenu(){
        for v in moreMenuView.subviews {
            v.removeFromSuperview()
        }
        removeBlurEffect()
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.moreMenuView.frame = CGRect(x: AppWidth, y: StatusHeight + 5,  width: 0,  height: 0)
            }, completion: { (Bool) -> Void in
                self.moreMenuView.removeFromSuperview()
        })
        
        isOpenedMoreMenu = false
        
    }
    
    /// close All Menu
    func closeAllMenu(){
        if isOpenedMainMenu{
            closingMainMenu()
        }
        if isOpenedMoreMenu{
            closingMoreMenu()
        }
    }
    
    
    
    
    
    
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    /* ----                  Main MainWebView Section                    ---- */
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    /////////////////////////////////////////////////////////
    
    
    /* ----         MainWebView Section     ---- */
    /// Set MainWebView
    func setKKMainWebView(){

        mainWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: AppWidth, height: AppHeight))
        
        mainWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        mainWebView.navigationDelegate = self
        mainWebView.scrollView.delegate = self
        
        //gotoURL(BaseURL)
        self.view.addSubview(mainWebView)
        
    }
    
    
    /// Remove MainWebView
    func removeMainWebView(){
        mainWebView.removeFromSuperview()
    }
    
    
    
    
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    /* ----              Main Interface Functions               ---- */
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    /// Click Outside Menu -- Close Menu
    func tapOutsideMenu(_ sender:AnyObject){
        if isOpenedMainMenu{
            closingMainMenu()
        }
        
        if isOpenedMoreMenu{
            closingMoreMenu()
        }
    }
    
    /// Add BlueEffect
    func addBlurEffect(){
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurEffectView.frame = self.view.bounds
        blurEffectView.alpha = 0.2
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tap = UITapGestureRecognizer(target: self, action: #selector(MainViewController.tapOutsideMenu))
        self.blurEffectView.addGestureRecognizer(tap)
        currentWindow.addSubview(blurEffectView)
    }
    
    /// removeBlueEffect
    func removeBlurEffect(){
        blurEffectView.removeFromSuperview()
    }
    
    
    
    func setTabBar(){
        
        let tabBarHeight:CGFloat = 50
        
        let tabBar = UITabBar(frame: CGRect(x: -25, y: AppHeight - tabBarHeight, width: AppWidth + 50, height: tabBarHeight))
        
        let backTabBarItem = UITabBarItem(title: "back", image: nil, selectedImage: nil)
        
        let forwardTabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        
        tabBar.setItems([backTabBarItem,forwardTabBarItem], animated: true)
        
        self.view.addSubview(tabBar)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            hud.indicatorView.progress = Float(mainWebView.estimatedProgress)
        }
    }
    deinit {
        if mainWebView != nil{
            mainWebView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
    }
    
}


extension MainBasicViewController: UIScrollViewDelegate, TableMenuDelegate, WKNavigationDelegate, ImagePickerDelegate{
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    /* ----        Button And Clicked Funtions       ---- */
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    func tableMenuDidChangedToIndex(_ menuId: Int, btnIndex: Int) {
        /// Main Menu
        if menuId == 1{
            if checkUserLogin(){
                print("login")
                let index = MainButtonNameSelector(rawValue: btnIndex)!
                switch index{
                case .scanQRBtn:
                    showQRPage()
                case .homeBtn:
                    gotoURL(URLSelector.home)
                case .myAccountBtn:
                    gotoURL(URLSelector.myAccount)
                case .checkoutBtn:
                    gotoURL(URLSelector.checkout)
                case .cartBtn:
                    gotoURL(URLSelector.cart)
                case .logotBtn:
                    logoutApp()
                }
            }
            else{
                print("not login")
                let index = MainButtonWithoutLoginNameSelector(rawValue: btnIndex)!
                switch index{
                case .scanQRBtn:
                    showQRPage()
                case .homeBtn:
                    gotoURL(URLSelector.home)
                case .loginBtn:
                    gotoLoginPage()
                case .checkoutBtn:
                    gotoURL(URLSelector.checkout)
                case .cartBtn:
                    gotoURL(URLSelector.cart)
                case .logotBtn:
                    logoutApp()
                }
            }
        }
        
        /// More Menu
        else {
            if checkWeChatInstall(self){
                let index = MoreButtonNameSelector(rawValue: btnIndex)!
                switch index{
                case .shareToWeChat:
                    shareToWeChat()
                case .shareToMoment:
                    shareToMoment()
                case .shareToFB:
                    shareToFB()
                }
            } else{
                shareToFB()
            }
        }
        
    }
    
    ////////////////    Main Menu Button Functions /////////////
    
    /// Click Clear Session
    func logoutApp(){
        closingMainMenu()
        isInit = true
        isRegularLogin = false
        /// delete cookies
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        clearSession()
        clearCache()
        CurrentURL = nil
        
        self.myPushViewController(vc: LeadingViewController(), animated: true)
    }
    
    
    func showQRPage(){
        closeAllMenu()
        if Platform.isSimulator{
            showAlertDoNothing("Not Found Camera", message: "Check your device or your are running in a simulator")
        } else{
            self.myPushViewController(vc: CameraViewController(), animated: true)
        }
    }
    
    
    func setUserProfile(){
        closeAllMenu()
        
        if checkUserLogin(){
            self.navigationController?.navigationBar.isHidden = true
            let imagePickerVC = ImagePickerController()
            imagePickerVC.imageLimit = 1
            imagePickerVC.delegate = self
            self.myPushViewController(vc: imagePickerVC, animated: true)
        }else{
            showAlertDoNothing("Not login", message: "Please login first")
        }

    }
    
    
    ////////////                                   ///////////////
    ////////////       More Menu Button Functions  ///////////////
    ////////////                                   ///////////////
    func shareToWeChat(){
        shareWeChat(0)
    }
    
    func shareToMoment(){
        shareWeChat(1)
    }
    
    func shareWeChat(_ scene: Int32){
        closeAllMenu()
        if WXApi.isWXAppInstalled(){
            let req = SendMessageToWXReq()
            req.text = "Quick way to buy ticket"
            let msg = WXMediaMessage()
            msg.title = "One Party Go"
            msg.setThumbImage(UIImage(named: "Logo"))
            msg.description = "Quick way to buy ticket"
            let ext = WXAppExtendObject()
            ext.extInfo = "One Party Go"
            ext.url = CurrentURL
            msg.mediaObject=ext
            req.message = msg
            req.scene = scene
            WXApi.send(req)
        } else{
            showAlertDoNothing("Wechat Not Installed", message: "Sorry, please install wechat first")
        }
    }
    
    func shareToFB(){
        closeAllMenu()
        
        let content = FBSDKShareLinkContent()
        content.contentURL = URL(string: CurrentURL)
        content.contentTitle = "One Party Go"
        content.contentDescription = "One Party Go: Quick way to buy ticket"
        content.imageURL = URL(string: "http://www.onepartygo.com/wp-content/uploads/2016/08/girl-party-1.jpeg")
        FBSDKShareDialog.show(from: self, with: content, delegate: nil)
    }
    
    
    ///////////////////////////////////////////////////////////
    
    
    func gotoURL(_ url:String){
        if url == BaseURL{
            self.mainWebView.load(URLRequest(url: URL(string: url)!))
            CurrentURL = url
        }else if url.contains("http"){
            hud.show(in: self.mainWebView)
            
            Alamofire.request(url).validate().responseData { response in
                switch response.result{
                case .failure(let error):
                    self.showAlertDoNothing("Error", message: "URL is not valid Or URL can't reach")
                    print(error)
                case .success:
                    self.mainWebView.load(URLRequest(url: URL(string: url)!))
                    CurrentURL = url
                    print(CurrentURL)
                }
                self.hud.dismiss()
            }
            
        }else{
            self.mainWebView.load(URLRequest(url: URL(string: BaseURL + url)!))
            CurrentURL = BaseURL + url
        }
        closeAllMenu()
    }
 
    
    
    func gotoURL(_ url: URLSelector){
        let urlString = url.rawValue
        gotoURL(urlString)
    }
    
    
    /////////////////     Delegate Functions    ///////////////////
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //activityIndicator.startAnimating()
        hud.show(in: webView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hud.dismiss()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("Fire WebView")
    }
    
    
    
    
    // Set JavaScript for WKWebView
    func setWebConfigByJS(_ jScript: String) -> WKWebViewConfiguration {
        let wkUScript: WKUserScript = WKUserScript(source: jScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController: WKUserContentController = WKUserContentController()
        wkUController.addUserScript(wkUScript)
        
        let wkWebConfig: WKWebViewConfiguration = WKWebViewConfiguration()
        
        wkWebConfig.userContentController = wkUController
        return wkWebConfig
    }

    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
        print("Wrapper")
        //imagePicker.galleryView.collectionView(images)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
        print("done")
        let imageName = localStorage.object(forKey: localStorageKeys.UserEmail) as! String
        let smallImage = images.last?.resizeWith(80)!
        
        uploadFileToServer(smallImage!, imageName: imageName)
        
        let imagesNSData = UIImagePNGRepresentation(smallImage!)
        
        localStorage.set(imagesNSData, forKey: localStorageKeys.UserHeadImage)
        _ = navigationController?.popViewController(animated: true)
        print("wtf")
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController){
        print("cancel")
        _ = navigationController?.popViewController(animated: true)
        print("hello")
    }
    
    func gotoLoginPage(){
        closeAllMenu()
        print("gotoLoginPage")
        print(self.navigationController)
        print(self.navigationController?.childViewControllers)
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    func initViews(){
        setNav()
        setMainMenuView()
        setMoreMenu()
        setKKMainWebView()
        if CurrentURL != nil{
            gotoURL(CurrentURL)
        } else{
            gotoURL(BaseURL)
        }
        
        verisonChecker()
        refreshCache()
    }
    
    func checkAccessToken(){
        print("checkAccessToken")
        var parameters = [String : Any]()
        
        if let wechat_access_token = localStorage.object(forKey: localStorageKeys.WeChatAccessToken), let wechat_openid = localStorage.object(forKey: localStorageKeys.WeChatOpenId){
            parameters["wechat_openid"] = wechat_openid
            parameters["wechat_access_token"] = wechat_access_token
        }
        
        if let fb_access_token = localStorage.object(forKey: localStorageKeys.FBAccessToken), let fb_id = localStorage.object(forKey: localStorageKeys.FBId){
            parameters["fb_access_token"] = fb_access_token
            parameters["fb_id"] = fb_id
        }
        
        if let phone_access_token = localStorage.object(forKey: localStorageKeys.PhoneAccessToken), let user_phone = localStorage.object(forKey: localStorageKeys.UserPhone){
            parameters["phone_access_token"] = phone_access_token
            parameters["user_phone"] = user_phone
        }
        
        if let email_pwd_access_token = localStorage.object(forKey: localStorageKeys.EmailPwdAccessToken), let email = localStorage.object(forKey: localStorageKeys.UserEmail){
            parameters["email"] = email
            parameters["email_pwd_access_token"] = email_pwd_access_token
        }
        
        print(localStorage.object(forKey: localStorageKeys.UserHeadImageURL))
        
        print("isInit \(isInit)")
        if isInit{
            let parametersString = parameters.stringFromHttpParameters()
            let url = BaseURL + "api/wp-test.php?\(parametersString)"
            
            print(url)
            gotoURL(url)
        }

    }
    
    func setupUserImage(){
        if let user_email = localStorage.object(forKey: localStorageKeys.UserEmail) as? String{
            let imageUrl = BaseURL + "api/uploads/" + "\(user_email).png"
            userImageView.imageFromServerURL(imageUrl, completion: { (Detail, Success) in
                if Success{
                    print("success")
                    localStorage.set(imageUrl, forKey: localStorageKeys.UserHeadImageURL)
                } else{
                    if let imageUrl = localStorage.object(forKey: localStorageKeys.UserHeadImageURL){
                        print(imageUrl)
                    } else{
                        let createImageAlter = UIAlertController(title: "Add Profile", message: "You can add your profile now or later", preferredStyle: .alert)
                        let createImageOKAction = UIAlertAction(title: "Setup Now", style: .default, handler: { (UIAlertAction) in
                            self.setUserProfile()
                        })
                        let createImageCancelAction = UIAlertAction(title: "Later", style: .cancel, handler:nil)
                        createImageAlter.addAction(createImageOKAction)
                        createImageAlter.addAction(createImageCancelAction)
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.present(createImageAlter, animated: true, completion: {
                                
                            })
                        })
                    }
                }
            })
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshCache()
        checkAccessToken()
        if isInit{
            setupUserImage()
            isInit = false
        }
        print("viewWillAppear")
    }
    
    
}



