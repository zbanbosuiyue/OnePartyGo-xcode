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
    var videoDataOutputQueue : DispatchQueue!;
    var previewLayer:AVCaptureVideoPreviewLayer!;
    var captureDevice : AVCaptureDevice!
    var session : AVCaptureSession!
    var currentFrame:CIImage!
    var done = false;
    var cameraPosition = AVCaptureDevicePosition.back
    var isDetect = false
    var detectImage: UIImage!
    var isFace = false
    var switchDetectFuncBtn: UIButton!
    var isPopingMsg = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewView = UIView(frame: CGRect(x: 0, y: 0, width: AppWidth, height: AppHeight));
        previewView.contentMode = UIViewContentMode.scaleAspectFit
        view.addSubview(previewView);
        
        //Add a box view
        boxView = UIImageView(frame: CGRect(x: 0, y: 0, width: AppWidth, height: AppHeight));
        boxView.alpha = 0.6
        boxView.contentMode = .scaleAspectFit
        view.addSubview(self.boxView);
        
        setupAVCapture(cameraPosition);
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.touchInCamera))
        
        previewView.addGestureRecognizer(gesture)
        
        let switchCameraBtn = UIButton(frame: CGRect(x: (AppWidth - 200)/2, y: AppHeight - 40, width: 200, height: 20))
        switchCameraBtn.addTarget(self, action: #selector(CameraViewController.switchCamera), for: .touchUpInside)
        switchCameraBtn.setTitle("Switch Camera", for: UIControlState())
        
        switchDetectFuncBtn = UIButton(frame: CGRect(x: (AppWidth - 200)/2, y: 100, width: 200, height: 20))
        switchDetectFuncBtn.addTarget(self, action: #selector(CameraViewController.switchDetectFunc), for: .touchUpInside)
        
        switchDetectFuncBtn.setTitle("QR Code", for: UIControlState())
        
        
        view.addSubview(switchCameraBtn)
        view.addSubview(switchDetectFuncBtn)
    }
    
    func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func switchCamera(){
        if cameraPosition == .front{
            cameraPosition = .back
        } else{
            cameraPosition = .front
        }
        session.stopRunning()
        setupAVCapture(cameraPosition)
    }
    
    func switchDetectFunc(){
        if isFace {
            isFace = false
            switchDetectFuncBtn.setTitle("QR Code", for: UIControlState())
            
        } else {
            isFace = true
            switchDetectFuncBtn.setTitle("Face", for: UIControlState())
        }
    }
    
    func touchInCamera(_ touchPoint: UITapGestureRecognizer){
        let focusPoint = CGPoint(x: touchPoint.location(in: previewView).y / AppHeight, y: 1.0 - touchPoint.location(in: previewView).x / AppWidth)
        
        do{
            if let device = captureDevice {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = AVCaptureFocusMode.autoFocus
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureExposureMode.autoExpose
                }
                device.unlockForConfiguration()
            }
        } catch{
            print(error)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !done {
            session.startRunning();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        session.stopRunning()
    }
    

}


// AVCaptureVideoDataOutputSampleBufferDelegate protocol and related methods
extension CameraViewController:  AVCaptureVideoDataOutputSampleBufferDelegate{
    func setupAVCapture(_ cameraPosition: AVCaptureDevicePosition){
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        
        let devices = AVCaptureDevice.devices();
        // Loop through all the capture devices on this phone
        for device in devices! {
            // Make sure this particular device supports video
            if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the front camera
                if((device as AnyObject).position == cameraPosition) {
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
        self.videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue", attributes: []);
        self.videoDataOutput.setSampleBufferDelegate(self, queue:self.videoDataOutputQueue);
        if session.canAddOutput(self.videoDataOutput){
            session.addOutput(self.videoDataOutput);
        }
        self.videoDataOutput.connection(withMediaType: AVMediaTypeVideo).isEnabled = true;
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session);
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        let rootLayer :CALayer = self.previewView.layer;
        rootLayer.masksToBounds=true;
        self.previewLayer.frame = rootLayer.bounds;
        rootLayer.addSublayer(self.previewLayer);
        session.startRunning();
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        self.convertImageFromCMSampleBufferRef(sampleBuffer);
    }
    
    
    // clean up AVCapture
    func stopCamera(){
        session.stopRunning()
        done = false;
    }
    
    func convertImageFromCMSampleBufferRef(_ sampleBuffer:CMSampleBuffer){
        let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!;
        let ciImage:CIImage = CIImage(cvPixelBuffer: pixelBuffer)
        let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        if !isPopingMsg{
            if isFace{
                detectFace(ciImage)
            } else{
                detectQRcode(ciImage)
            }
            if isDetect {
                DispatchQueue.main.async
                {
                    if !self.isFace {
                        let hud = JGProgressHUD(style: .light)
                        
                        if self.verifyUrl(QRMessage){
                            self.isPopingMsg = true
                            hud?.textLabel.text = "QR: " + QRMessage
                            hud?.show(in: self.view)
                            
                            let seconds = 1.5
                            let delay = seconds * Double(NSEC_PER_SEC)
                            let delayTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                                hud?.dismiss()
                                print(self.navigationController?.childViewControllers)
                                _ = self.navigationController?.popViewController(animated: true)
                            })
                        } else{
                            hud?.textLabel.text = "QRCode not valid"
                            hud?.dismiss(afterDelay: 1.5)
                        }
                    }
                    
                    
                    self.boxView.image = self.detectImage
                }
            } else{
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.boxView.image = nil
                }
            }
        }
    }
    
    
    func detectFace(_ ciimg: CIImage){
        isDetect = false
        
        let scale = UIScreen.main.scale
        
        let ratio = UIImage(ciImage: ciimg).size.height / AppWidth
        
        
        UIGraphicsBeginImageContextWithOptions(boxView.frame.size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        let cid = CIDetector(ofType:CIDetectorTypeFace, context:nil, options:[CIDetectorAccuracy: CIDetectorAccuracyLow])
        let results = cid!.features(in: ciimg, options: NSDictionary() as? [String : AnyObject])
        
        for r in results {
            let face = r as! CIFaceFeature
            
            context!.setStrokeColor(UIColor.purple.cgColor)
            let rect = CGRect(x: face.bounds.origin.y/ratio, y: face.bounds.origin.x/ratio, width: face.bounds.height/ratio, height: face.bounds.width/ratio)
            context!.stroke(rect, width: 2.0)
            isDetect = true
            detectImage = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }
    
    
        func detectQRcode(_ ciimg: CIImage){
        isDetect = false
        
        let scale = UIScreen.main.scale
        
        let ratio = UIImage(ciImage: ciimg).size.height / AppWidth
        
        
        UIGraphicsBeginImageContextWithOptions(boxView.frame.size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        let cid = CIDetector(ofType:CIDetectorTypeQRCode, context:nil, options:[CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let results = cid!.features(in: ciimg, options: NSDictionary() as? [String : AnyObject])
        
        
        for r in results {
            let QR = r as! CIQRCodeFeature
            print("QR String: \(QR.messageString)")
            QRMessage = QR.messageString
            
            print(UIImage(ciImage: ciimg).size)
            //print(boxView.frame.size)
            
            context!.setStrokeColor(UIColor.purple.cgColor)
            let rect = CGRect(x: QR.bounds.origin.y/ratio, y: QR.bounds.origin.x/ratio, width: QR.bounds.height/ratio, height: QR.bounds.width/ratio)
            //print(rect)
            context!.stroke(rect, width: 2.0)
            isDetect = true
            detectImage = UIGraphicsGetImageFromCurrentImageContext()
        }
        
        if results.count > 1 {
            QRMessage = "Too Many QR Found. Can't Read."
        }
        
        UIGraphicsEndImageContext()
    }
    
    func verifyUrl (_ urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
}
