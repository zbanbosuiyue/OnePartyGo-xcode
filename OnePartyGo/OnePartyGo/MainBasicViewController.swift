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
    
    
    lazy var cookieString:String! = {
        let cookiesStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()

        var cookieProperties = [String : AnyObject]()
        cookieProperties[NSHTTPCookieName] = "isAppLogin"
        cookieProperties[NSHTTPCookieValue] = "1"
        cookieProperties[NSHTTPCookieDomain] = "www.onepartygo.com"
        cookieProperties[NSHTTPCookieOriginURL] = "www.onepartygo.com"
        cookieProperties[NSHTTPCookiePath] = "/"
        cookieProperties[NSHTTPCookieVersion] = "0"
        
        cookieProperties[NSHTTPCookieExpires] = NSDate().dateByAddingTimeInterval(2629743)
        var cookie = NSHTTPCookie(properties: cookieProperties)
        cookiesStorage.setCookie(cookie!)
        
        var cookieStr = ""
        cookiesStorage.cookies?.forEach({ cookie in
            cookieStr += "\(cookie.name)=\(cookie.value);"
        })
        
        return cookieStr
    }()
    
    
    func setNav(){
        navigationController?.navigationBar.hidden = false
        
        let mainMenuItem = UIBarButtonItem(image: UIImage(named: "Menu"), style: .Plain, target: self, action: #selector(MainViewController.openMainMenu))
        
        let moreMenuItem = UIBarButtonItem(image: UIImage(named: "moreMenu"), style: .Plain, target: self, action: #selector(MainViewController.clickMoreMenu(_:)))
        
        
        let logoImage = UIImage(named: "Logo")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = logoImage
        
        navigationItem.titleView = imageView
        
        navigationItem.leftBarButtonItem = mainMenuItem
        navigationItem.rightBarButtonItem = moreMenuItem
        
        //navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        currentWindow = UIApplication.sharedApplication().keyWindow
        
        
        hud = JGProgressHUD(style: .Light)
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
        mainMenuView.backgroundColor = UIColor.whiteColor()
        mainMenuView.layer.shadowColor = UIColor.grayColor().CGColor
        mainMenuView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        mainMenuView.layer.shadowOpacity = 0.8
        mainMenuView.layer.shadowRadius = 2.0
        mainMenuView.tag = -1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshCache()
    }
    
    func refreshCache(){
        userImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 80, height: 80))
        
        userImageView.image = UIImage(named: "default");
        
        if let userHeadImageNSData = localStorage.objectForKey(localStorageKeys.UserHeadImage){
            let userHeadImage = UIImage(data: userHeadImageNSData as! NSData)
            userImageView.image = userHeadImage
        }else{
            if let url = localStorage.objectForKey(localStorageKeys.UserHeadImageURL){
                print("fuck")
                
                userImageView.imageFromServerURL(url as! String, completion: { (Detail, Success) in
                })
            }
            let user_email = localStorage.objectForKey(localStorageKeys.UserEmail) as! String
            let imageUrl = BaseURL + "api/uploads/" + "\(user_email).png"
            userImageView.imageFromServerURL(imageUrl, completion: { (Detail, Success) in
            })
 
        }
    }
    
    /// Trigger OpenMainMenu
    func openMainMenu(sender: AnyObject){
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
        userImageView.layer.borderColor = UIColor.grayColor().CGColor
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        userImageView.clipsToBounds = true
        userImageView.contentMode = .ScaleAspectFit
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MainBasicViewController.setUserProfile))
        userImageView.addGestureRecognizer(tap)
        userImageView.userInteractionEnabled = true
        
        let mainMenuTableView = TableMenuView(frame:CGRect(x: 0, y: userImageView.frame.height + 10, width: AppWidth * 0.382, height: AppHeight * 0.382))
        mainMenuView.addSubview(mainMenuTableView)
        mainMenuTableView.titles = MainMenuBtnArr
        mainMenuTableView.font = MainMenuBtnFont
        mainMenuTableView.tableView?.rowHeight = 35
        mainMenuTableView.delegate = self
        mainMenuTableView.menuId = 1
        
        currentWindow.addSubview(mainMenuView)
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
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
        UIView.animateWithDuration(0.3, animations: { () -> Void in
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
        moreMenuView.backgroundColor = UIColor.whiteColor()
        
        moreMenuView.layer.shadowColor = UIColor.grayColor().CGColor
        moreMenuView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        moreMenuView.layer.shadowOpacity = 0.8
        moreMenuView.layer.shadowRadius = 2.0
        moreMenuView.tag = -1
        
    }
    
    /// Trigger OpenMoreMenu
    func clickMoreMenu(sender: AnyObject){
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
        moreMenuTableView.titles = MoreMenuBtnArr
        moreMenuTableView.font = MoreMenuBtnFont
        moreMenuTableView.tableView?.rowHeight = 30
        moreMenuTableView.delegate = self
        moreMenuTableView.menuId = 2
        
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
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
        UIView.animateWithDuration(0.3, animations: { () -> Void in
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
        let jScript: String = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=\(AppWidth)'); document.getElementsByTagName('head')[0].appendChild(meta);"
        
        mainWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: AppWidth, height: AppHeight), configuration: setWebConfigByJS(jScript))
        
        mainWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
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
    func tapOutsideMenu(sender:AnyObject){
        if isOpenedMainMenu{
            closingMainMenu()
        }
        
        if isOpenedMoreMenu{
            closingMoreMenu()
        }
    }
    
    /// Add BlueEffect
    func addBlurEffect(){
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        blurEffectView.frame = self.view.bounds
        blurEffectView.alpha = 0.2
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
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
        
        let forwardTabBarItem = UITabBarItem(tabBarSystemItem: .Bookmarks, tag: 1)
        
        tabBar.setItems([backTabBarItem,forwardTabBarItem], animated: true)
        
        self.view.addSubview(tabBar)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "estimatedProgress" {
            hud.indicatorView.progress = Float(mainWebView.estimatedProgress)
        }
    }
    
}


extension MainBasicViewController: UIScrollViewDelegate, TableMenuDelegate, WKNavigationDelegate, ImagePickerDelegate{
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    /* ----        Button And Clicked Funtions       ---- */
    
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    
    func tableMenuDidChangedToIndex(menuId: Int, btnIndex: Int) {
        /// Main Menu
        if menuId == 1{
            let index = MainButtonNameSelector(rawValue: btnIndex)!
            switch index{
            case .scanQRBtn:
                showQRPage()
            case .homeBtn:
                gotoURL(URLSelector.home)
            /*
            case .eventCalendarBtn:
                gotoURL(URLSelector.eventCalendar)
 */
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
            
            /// More Menu
        else {
            let index = MoreButtonNameSelector(rawValue: btnIndex)!
            switch index{
            case .shareToWeChat:
                shareToWeChat()
            case .shareToMoment:
                shareToMoment()
            case .shareToFB:
                shareToFB()
            }
        }
        
    }
    
    ////////////////    Main Menu Button Functions /////////////
    
    /// Click Clear Session
    func logoutApp(){
        closingMainMenu()
        isInit = true
        /// delete cookies
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        self.navigationController?.pushViewController(LeadingViewController(), animated: true)
        CurrentURL = nil
    }
    
    
    func showQRPage(){
        closeAllMenu()
        if Platform.isSimulator{
            showAlertDoNothing("Not Found Camera", message: "Check your device or your are running in a simulator")
        } else{
            navigationController?.pushViewController(CameraViewController(), animated: true)
        }
    }
    
    
    func setUserProfile(){
        closeAllMenu()
        
        self.navigationController?.navigationBar.hidden = true
        let imagePickerVC = CreateUserHeadImageViewController()
        imagePickerVC.delegate = self
        self.navigationController?.pushViewController(imagePickerVC, animated: true)
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
    
    func shareWeChat(scene: Int32){
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
            WXApi.sendReq(req)
        } else{
            showAlertDoNothing("Wechat Not Installed", message: "Sorry, please install wechat first")
        }
    }
    
    func shareToFB(){
        closeAllMenu()
        
        let content = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: CurrentURL)
        content.contentTitle = "One Party Go"
        content.contentDescription = "One Party Go: Quick way to buy ticket"
        content.imageURL = NSURL(string: "http://www.onepartygo.com/wp-content/uploads/2016/08/girl-party-1.jpeg")
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
    }
    
    
    ///////////////////////////////////////////////////////////
    
    
    func gotoURL(url:String){
        if url == BaseURL{
            mainWebView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
            CurrentURL = url
        }else if url.containsString("http"){
            mainWebView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
            CurrentURL = url
        }else{
            
            mainWebView.loadRequest(NSURLRequest(URL: NSURL(string: BaseURL + url)!))
            CurrentURL = BaseURL + url
        }
        print(CurrentURL)
        closeAllMenu()
    }
    
    func gotoURL(url: URLSelector){
        let urlString = url.rawValue
        gotoURL(urlString)
    }
    
    
    /////////////////     Delegate Functions    ///////////////////
    
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //activityIndicator.startAnimating()
        hud.showInView(webView)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        hud.dismiss()
    }

    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        print("Fire WebView")
    }
    
    
    
    
    // Set JavaScript for WKWebView
    func setWebConfigByJS(jScript: String) -> WKWebViewConfiguration {
        let wkUScript: WKUserScript = WKUserScript(source: jScript, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
        let wkUController: WKUserContentController = WKUserContentController()
        wkUController.addUserScript(wkUScript)
        
        let wkWebConfig: WKWebViewConfiguration = WKWebViewConfiguration()
        
        wkWebConfig.userContentController = wkUController
        return wkWebConfig
    }

    
    
    func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]){
        print("Wrapper")
        //imagePicker.galleryView.collectionView(images)
    }
    
    func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]){
        print("done")
        let imageName = localStorage.objectForKey(localStorageKeys.UserEmail) as! String
        let smallImage = images.last?.resizeWith(80)!
        
        uploadFileToServer(smallImage!, imageName: imageName)
        
        let imagesNSData = UIImagePNGRepresentation(smallImage!)
        
        localStorage.setObject(imagesNSData, forKey: localStorageKeys.UserHeadImage)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func cancelButtonDidPress(imagePicker: ImagePickerController){
        print("cancel")
        self.navigationController?.popViewControllerAnimated(true)
    }
}



