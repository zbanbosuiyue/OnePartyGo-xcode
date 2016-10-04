//
//  CreateUserHeadImageViewController.swift
//  Zouqiba
//
//  Created by Miibox on 9/7/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit
import ImagePicker

class CreateUserHeadImageViewController: ImagePickerController{

    override func viewDidLoad() {
        super.viewDidLoad()
        imageLimit = 1

        // Do any additional setup after loading the view.
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
