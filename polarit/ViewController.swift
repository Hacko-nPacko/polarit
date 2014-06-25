//
//  ViewController.swift
//  polarit
//
//  Created by Atanas Balevsky on 6/19/14.
//  Copyright (c) 2014 Atanas Balevsky. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let videoCamera:GPUImageStillCamera
    
    var customFilterClass:GPUImageFilterGroup.Type?
    var polarFilter:PolarFilter!
    var sepiaFilter:GPUImageSepiaFilter!
    var rotateFilter:GPUImageTransformFilter!
    var lastFilter:GPUImageFilter!
    
    @IBOutlet var gpuImageView:GPUImageView
    @IBOutlet var angleSlider:ASValueTrackingSlider
    @IBOutlet var sepiaSlider:ASValueTrackingSlider
    @IBOutlet var indicator:TYMActivityIndicatorView
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPreset1280x720, cameraPosition: .Back)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(coder aDecoder: NSCoder!) {
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPreset1280x720, cameraPosition: .Back)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoCamera.outputImageOrientation = .Portrait
        videoCamera.startCameraCapture()

        gpuImageView.setInputRotation(kGPUImageNoRotation, atIndex: 0)
        //customFilterClass = GPUImageMissEtikateFilter.self
        //customFilterClass = GPUImageAmatorkaFilter.self
        
        (lastFilter, sepiaFilter, rotateFilter, polarFilter) = buildFilters(source: videoCamera, target: gpuImageView, originalSize: CGSizeMake(720, 1280), sepia: 0, angle: 0)
        
        angleSlider.setMaxFractionDigitsDisplayed(0)
        angleSlider.dataSource = AngleSliderDataSource()
        
        configureIndicator(indicator)
    }


    override func viewWillDisappear(animated: Bool) {
        NSLog("view did disappear")
        videoCamera.stopCameraCapture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func savePicture() {
        indicator.startAnimating()
        videoCamera.capturePhotoAsImageProcessedUpToFilter(lastFilter, withCompletionHandler: { (image, error) -> Void in
            NSLog("saving %@", image)
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            self.indicator.stopAnimating()
        })
    }
    
    @IBAction func angleChanged(sender:UISlider) {
        rotateFilter.affineTransform = CGAffineTransformMakeRotation(sender.value / 180 * CGFloat(M_PI))
    }
    
    @IBAction func sepiaChanged(sender:UISlider) {
        sepiaFilter.intensity = sender.value
    }
    
    @IBAction func pickPanoramaFromLibrary() {
        let photoPicker = UIImagePickerController()
        photoPicker.sourceType = .PhotoLibrary
        photoPicker.delegate = self
        self.presentViewController(photoPicker, animated: true, completion: nil)
    }

    @IBAction func pickAdditionalFilter() {
        UIView.animateWithDuration(0.2, animations: {() -> Void in
            var dx:Float
            if (self.view.frame.origin.x > 0) {
                dx = -50
            } else {
                dx = 50
            }
            self.view.frame.offset(dx: dx, dy: 0)
        })
        // TODO
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        indicator.startAnimating()
        self.dismissViewControllerAnimated(true, completion: {() -> Void in
            if (image != nil) {
                let polarImageView = processImage(image: image, frame: self.view.frame, sepia: self.sepiaSlider.value, angle: self.angleSlider.value)
                self.view.addSubview(polarImageView)
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionCrossDissolve, animations: {() -> Void in
                    polarImageView.alpha = 1
                }, completion: {(success:Bool) -> Void in
                })
                
                UIView.animateWithDuration(0.5, delay: 4.5, options: .TransitionCrossDissolve, animations: {() -> Void in
                    polarImageView.alpha = 0
                    
                }, completion: {(success:Bool) -> Void in
                    self.videoCamera.startCameraCapture()
                    self.indicator.stopAnimating()
                    polarImageView.removeFromSuperview()
                    
                })
                
                
            }
        })
    }
    

    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: {() -> Void in
            self.videoCamera.startCameraCapture()
        })
    }
    
    
    
   
}

