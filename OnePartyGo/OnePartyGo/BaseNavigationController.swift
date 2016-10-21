//
//  BaseNavigationController.swift
//  zouqiTest2
//
//  Created by Miibox on 8/11/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    var isAnimation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer!.delegate = nil
        view.backgroundColor = UIColor.white
    }
    
    
    
    
    lazy var backBtn: UIButton = {
        //设置返回按钮属性
        let backBtn = UIButton(type: UIButtonType.custom)
        backBtn.setImage(UIImage(named: "v2_goback"), for: UIControlState())
        backBtn.titleLabel?.isHidden = true
        backBtn.addTarget(self, action: #selector(BaseNavigationController.backBtnClick), for: .touchUpInside)
        backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        backBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
        let btnW: CGFloat = AppWidth > 375.0 ? 50 : 44
        backBtn.frame = CGRect(x: 0, y: 0, width: btnW, height: 40)
        return backBtn
    }()
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.hidesBackButton = true
        if childViewControllers.count > 0 {
            UINavigationBar.appearance().backItem?.hidesBackButton = false
            
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
            
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    
    func backBtnClick() {
        popViewController(animated: isAnimation)
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
