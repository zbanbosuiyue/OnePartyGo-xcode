//
//  CameraViewController.swift
//  Zouqiba
//
//  Created by Miibox on 8/19/16.
//  Copyright © 2016 Miibox. All rights reserved.
//


import UIKit
import AVFoundation
import JGProgressHUD

class CameraViewController: UIViewController{
    var previewView : UIView!;
    var boxView:UIImageView!;
    
    //Camera Capture requiered properties
    var videoDataOutput: AVCaptureVideoDataOutput!;
    var videoDataOutputQueue : dispatch_queue_t!;
    var previewLayer:AVCaptureVideoPreviewLayer!;
    var captureDevice : AVCaptureDevice!
    var session : AVCaptureSession!
    var currentFrame:CIImage!
    var done = false;
    var cameraPosition = AVCaptureDevicePosition.Back
    var isDetect = false
    var detectImage: UIImage!
    var isFace = false
    var switchDetectFuncBtn: UIButton!
    var isPopingMsg = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewView = UIView(frame: CGRectMake(0, 0, AppWidth, AppHeight));
        previewView.contentMode = UIViewContentMode.ScaleAspectFit
        view.addSubview(previewView);
        
        //Add a box view
        boxView = UIImageView(frame: CGRectMake(0, 0, AppWidth, AppHeight));
        boxView.alpha = 0.6
        boxView.contentMode = .ScaleAspectFit
        view.addSubview(self.boxView);
        
        setupAVCapture(cameraPosition);
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.touchInCamera))
        
        previewView.addGestureRecognizer(gesture)
        
        let switchCameraBtn = UIButton(frame: CGRectMake((AppWidth - 200)/2, AppHeight - 40, 200, 20))
        switchCameraBtn.addTarget(self, action: #selector(CameraViewController.switchCamera), forControlEvents: .TouchUpInside)
        switchCameraBtn.setTitle("Switch Camera", forState: .Normal)
        
        switchDetectFuncBtn = UIButton(frame: CGRectMake((AppWidth - 200)/2, 100, 200, 20))
        switchDetectFuncBtn.addTarget(self, action: #selector(CameraViewController.switchDetectFunc), forControlEvents: .TouchUpInside)
        
        switchDetectFuncBtn.setTitle("QR Code", forState: .Normal)
        
        
        view.addSubview(switchCameraBtn)
        view.addSubview(switchDetectFuncBtn)
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func switchCamera(){
        if cameraPosition == .Front{
            cameraPosition = .Back
        } else{
            cameraPosition = .Front
        }
        session.stopRunning()
        setupAVCapture(cameraPosition)
    }
    
    func switchDetectFunc(){
        if isFace {
            isFace = false
            switchDetectFuncBtn.setTitle("QR Code", forState: .Normal)
            
        } else {
            isFace = true
            switchDetectFuncBtn.setTitle("Face", forState: .Normal)
        }
    }
    
    func touchInCamera(touchPoint: UITapGestureRecognizer){
        let focusPoint = CGPoint(x: touchPoint.locationInView(previewView).y / AppHeight, y: 1.0 - touchPoint.locationInView(previewView).x / AppWidth)
        
        do{
            if let device = captureDevice {
                try device.lockForConfiguration()
                if device.focusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = AVCaptureFocusMode.AutoFocus
                }
                if device.exposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureExposureMode.AutoExpose
                }
                device.unlockForConfiguration()
            }
        } catch{
            print(error)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if !done {
            session.startRunning();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        session.stopRunning()
    }
    

}


// AVCaptureVideoDataOutputSampleBufferDelegate protocol and related methods
extension CameraViewController:  AVCaptureVideoDataOutputSampleBufferDelegate{
    func setupAVCapture(cameraPosition: AVCaptureDevicePosition){
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        
        let devices = AVCaptureDevice.devices();
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the front camera
                if(device.position == cameraPosition) {
                    captureDevice = device as? AVCaptureDevice;
                    if captureDevice != nil {
                        beginSession();
                        done = true;
                        break;
                    }
                }
            }
        }
    }
    
    func beginSession(){
        var err : NSError? = nil
        var deviceInput:AVCaptureDeviceInput?
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            err = error
            deviceInput = nil
        };
        if err != nil {
            print("error: \(err?.localizedDescription)");
        }
        if self.session.canAddInput(deviceInput){
            self.session.addInput(deviceInput);
        }
        
        self.videoDataOutput = AVCaptureVideoDataOutput();
        self.videoDataOutput.alwaysDiscardsLateVideoFrames=true;
        self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        self.videoDataOutput.setSampleBufferDelegate(self, queue:self.videoDataOutputQueue);
        if session.canAddOutput(self.videoDataOutput){
            session.addOutput(self.videoDataOutput);
        }
        self.videoDataOutput.connectionWithMediaType(AVMediaTypeVideo).enabled = true;
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session);
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        let rootLayer :CALayer = self.previewView.layer;
        rootLayer.masksToBounds=true;
        self.previewLayer.frame = rootLayer.bounds;
        rootLayer.addSublayer(self.previewLayer);
        session.startRunning();
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        self.convertImageFromCMSampleBufferRef(sampleBuffer);
    }
    
    
    // clean up AVCapture
    func stopCamera(){
        session.stopRunning()
        done = false;
    }
    
    func convertImageFromCMSampleBufferRef(sampleBuffer:CMSampleBuffer){
        let pixelBuffer:CVPixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!;
        let ciImage:CIImage = CIImage(CVPixelBuffer: pixelBuffer)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        
        if !isPopingMsg{
            if isFace{
                detectFace(ciImage)
            } else{
                detectQRcode(ciImage)
            }
        

            if isDetect {
                dispatch_async(dispatch_get_main_queue())
                {
                    if !self.isFace {
                        let hud = JGProgressHUD(style: .Light)
                        
                        if self.verifyUrl(QRMessage){
                            self.isPopingMsg = true
                            hud.textLabel.text = "QR: " + QRMessage
                            hud.showInView(self.view)
                            
                            let seconds = 1.5
                            let delay = seconds * Double(NSEC_PER_SEC)
                            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                            dispatch_after(delayTime, dispatch_get_main_queue(), {
                                hud.dismiss()
                                self.navigationController?.popViewControllerAnimated(true)
                            })
                        } else{
                            hud.textLabel.text = "QRCode not valid"
                            hud.dismissAfterDelay(1.5)
                        }
                    }
                    
                    
                    self.boxView.image = self.detectImage
                }
            } else{
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.boxView.image = nil
                }
            }
        }
    }
    
    
    func detectFace(ciimg: CIImage){
        isDetect = false
        
        let scale = UIScreen.mainScreen().scale
        
        let ratio = UIImage(CIImage: ciimg).size.height / AppWidth
        
        
        UIGraphicsBeginImageContextWithOptions(boxView.frame.size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        let cid = CIDetector(ofType:CIDetectorTypeFace, context:nil, options:[CIDetectorAccuracy: CIDetectorAccuracyLow])
        let results = cid!.featuresInImage(ciimg, options: NSDictionary() as? [String : AnyObject])
        
        for r in results {
            let face = r as! CIFaceFeature
            
            CGContextSetStrokeColorWithColor(context!, UIColor.purpleColor().CGColor)
            let rect = CGRectMake(face.bounds.origin.y/ratio, face.bounds.origin.x/ratio, face.bounds.height/ratio, face.bounds.width/ratio)
            CGContextStrokeRectWithWidth(context!, rect, 2.0)
            isDetect = true
            detectImage = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }
    
    
        func detectQRcode(ciimg: CIImage){
        isDetect = false
        
        let scale = UIScreen.mainScreen().scale
        
        let ratio = UIImage(CIImage: ciimg).size.height / AppWidth
        
        
        UIGraphicsBeginImageContextWithOptions(boxView.frame.size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        let cid = CIDetector(ofType:CIDetectorTypeQRCode, context:nil, options:[CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let results = cid!.featuresInImage(ciimg, options: NSDictionary() as? [String : AnyObject])
        
        
        for r in results {
            let QR = r as! CIQRCodeFeature
            print("QR String: \(QR.messageString)")
            QRMessage = QR.messageString
            
            print(UIImage(CIImage: ciimg).size)
            //print(boxView.frame.size)
            
            CGContextSetStrokeColorWithColor(context!, UIColor.purpleColor().CGColor)
            let rect = CGRectMake(QR.bounds.origin.y/ratio, QR.bounds.origin.x/ratio, QR.bounds.height/ratio, QR.bounds.width/ratio)
            //print(rect)
            CGContextStrokeRectWithWidth(context!, rect, 2.0)
            isDetect = true
            detectImage = UIGraphicsGetImageFromCurrentImageContext()
        }
        
        if results.count > 1 {
            QRMessage = "Too Many QR Found. Can't Read."
        }
        
        UIGraphicsEndImageContext()
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
    
}
