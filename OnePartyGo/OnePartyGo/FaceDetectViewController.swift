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
        
        imageView.frame = CGRect(x: 0, y: 0, width: AppWidth, height: AppHeight)
        imageView.contentMode = .scaleAspectFit
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                
                self.imageView.image = self.detectFace(image!)
                self.view.addSubview(self.imageView)
            })
        }).resume()
    }
    
    
    func imageWithImage(_ sourceImage: UIImage, scaledToWidth i_width: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = i_width / oldWidth
        let newHeight  = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
            
    func textToImage(_ drawText: NSString, inImage: UIImage, atPoint: CGPoint) -> UIImage{
        
        // Setup the font specific variables
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 12)!
        
        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        print(scale)
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
        ]
        
        // Put the image into a rectangle as large as the original image
        inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        
        // Create a point within the space that is as bit as the image
        let rect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)
        
        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage!
        
    }
    
    
    func detectFace(_ image: UIImage) -> UIImage{
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        let ciimg = CIImage(image: image)
        context!.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        
        let cid = CIDetector(ofType:CIDetectorTypeFace, context:nil, options:[CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let results = cid!.features(in: ciimg!, options: NSDictionary() as? [String : AnyObject])
        
        for r in results {
            let face = r as! CIFaceFeature
            NSLog("Face found at (%f,%f) of dimensions %fx%f", face.bounds.origin.x, face.bounds.origin.y, face.bounds.width, face.bounds.height)
            context!.setStrokeColor(UIColor.purple.cgColor)
            context!.stroke(face.bounds, width: 2.0)
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
