//
//  MainNavViewController.swift
//  Zouqiba
//
//  Created by Miibox on 8/15/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit

class MainNavViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAllChildViewController()
        tabBar.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    func setupAllChildViewController(){
        let mainVC = BaseNavigationController(rootViewController: MainViewController())
        addChildViewController(mainVC)
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
