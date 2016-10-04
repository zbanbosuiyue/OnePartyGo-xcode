//
//  FaceDetectViewController.swift
//  Zouqiba
//
//  Created by Miibox on 8/18/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit
import CoreImage

class FaceDetectViewController: UIViewController {
    let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detectImage()
        // Do any additional setup after loading the view.
    }


    func detectImage(){
        let url = "http://imgcache.mysodao.com/img3/M05/DA/F1/CgAPD1LSD4XUmBetAARxBVbAQ88364_900x0x1.JPG"
        
        imageView.frame = CGRectMake(0, 0, AppWidth, AppHeight)
        imageView.contentMode = .ScaleAspectFit
        
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let image = UIImage(data: data!)
                
                self.imageView.image = self.detectFace(image!)
                self.view.addSubview(self.imageView)
            })
        }).resume()
    }
    
    
    func imageWithImage(sourceImage: UIImage, scaledToWidth i_width: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = i_width / oldWidth
        let newHeight  = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        sourceImage.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
            
    func textToImage(drawText: NSString, inImage: UIImage, atPoint: CGPoint) -> UIImage{
        
        // Setup the font specific variables
        var textColor = UIColor.whiteColor()
        var textFont = UIFont(name: "Helvetica Bold", size: 12)!
        
        // Setup the image context using the passed image
        let scale = UIScreen.mainScreen().scale
        print(scale)
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
        ]
        
        // Put the image into a rectangle as large as the original image
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Create a point within the space that is as bit as the image
        let rect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
        
        // Draw the text into an image
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage!
        
    }
    
    
    func detectFace(image: UIImage) -> UIImage{
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        let ciimg = CIImage(image: image)
        CGContextDrawImage(context!, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage!)
        
        
        let cid = CIDetector(ofType:CIDetectorTypeFace, context:nil, options:[CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let results = cid!.featuresInImage(ciimg!, options: NSDictionary() as? [String : AnyObject])
        
        for r in results {
            let face = r as! CIFaceFeature
            NSLog("Face found at (%f,%f) of dimensions %fx%f", face.bounds.origin.x, face.bounds.origin.y, face.bounds.width, face.bounds.height)
            CGContextSetStrokeColorWithColor(context!, UIColor.purpleColor().CGColor)
            CGContextStrokeRectWithWidth(context!, face.bounds, 2.0)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        
        return newImage!
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
