//
//  ViewController.swift
//  polarit
//
//  Created by Atanas Balevsky on 6/19/14.
//  Copyright (c) 2014 Atanas Balevsky. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ASValueTrackingSliderDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let videoCamera:GPUImageStillCamera
    
    var customFilterClass:GPUImageFilter.Type?
    var polarFilter:PolarFilter!
    var sepiaFilter:GPUImageSepiaFilter!
    var rotateFilter:GPUImageTransformFilter!
    var lastFilter:GPUImageFilter!
    
    @IBOutlet var gpuImageView:GPUImageView
    @IBOutlet var angleSlider:ASValueTrackingSlider
    @IBOutlet var sepiaSlider:ASValueTrackingSlider
    
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
        gpuImageView.setInputRotation(kGPUImageNoRotation, atIndex: 0)

        (lastFilter, sepiaFilter, rotateFilter, polarFilter) = buildFilters(videoCamera, target: gpuImageView, originalSize: CGSizeMake(720, 1280))
        
        angleSlider.setMaxFractionDigitsDisplayed(0)
        angleSlider.dataSource = self
        
        // GPUImageAmatorkaFilter
        // GPUImageMissEtikateFilter

        
    }
    
    override func viewWillAppear(animated: Bool) {
        videoCamera.startCameraCapture()
    }

    override func viewWillDisappear(animated: Bool) {
        videoCamera.stopCameraCapture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func savePicture() {
        videoCamera.capturePhotoAsImageProcessedUpToFilter(lastFilter, withCompletionHandler: { (image, error) -> Void in
            NSLog("saving %@", image)
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        })
    }
    
    @IBAction func angleChanged(sender:UISlider) {
        rotateFilter.affineTransform = CGAffineTransformMakeRotation(sender.value / 180 * CGFloat(M_PI))
    }
    
    @IBAction func sepiaChanged(sender:UISlider) {
        sepiaFilter.intensity = sender.value
    }
    
    func slider(slider: ASValueTrackingSlider!, stringForValue value: CFloat) -> String! {
        if (slider == angleSlider) {
            return NSString(format:"%@°", slider.numberFormatter.stringFromNumber(value))
        }
        return slider.numberFormatter.stringFromNumber(value)
    }
    
    @IBAction func pickPanoramaFromLibrary() {
        videoCamera.stopCameraCapture()
        let photoPicker = UIImagePickerController()
        photoPicker.sourceType = .PhotoLibrary
        photoPicker.delegate = self
        self.presentViewController(photoPicker, animated: true, completion: nil)
    }

    @IBAction func pickAdditionalFilter() {
        UIView.animateWithDuration(0.1, animations: {() -> Void in
            var dx:Float
            if (self.view.frame.origin.x > 0) {
                dx = -50
            } else {
                dx = 50
            }
            self.view.frame.offset(dx: dx, dy: 0)
        })
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        self.dismissViewControllerAnimated(true, completion: {() -> Void in
            if (image != nil) {
                let gpuImage = GPUImagePicture(image: image)
                let filters = self.buildFilters(gpuImage, target: nil, originalSize: image.size)
                filters.lastFilter.useNextFrameForImageCapture()
                gpuImage.processImage()
                let polarImage = filters.lastFilter.imageFromCurrentFramebuffer()
                UIImageWriteToSavedPhotosAlbum(polarImage, nil, nil, nil)
            }
            self.videoCamera.startCameraCapture()

        })
    }

    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: {() -> Void in
            self.videoCamera.startCameraCapture()
        })
    }
    
    func buildFilters(source:GPUImageOutput, target:GPUImageInput?, originalSize size:CGSize) -> (lastFilter:GPUImageFilter!, effectFilter:GPUImageSepiaFilter!, rotateFilter:GPUImageTransformFilter!, polarFilter:PolarFilter!) {
        var scale:CGAffineTransform
        var crop: CGRect
        if (size.height < size.width) {
            scale = CGAffineTransformMakeScale(size.height/size.width, 1)
            crop = CGRectMake((size.width - size.height)/2/size.width, 0, size.height/size.width, 1)
        } else {
            scale = CGAffineTransformMakeScale(1, size.width/size.height)
            crop = CGRectMake(0, (size.height - size.width)/2/size.height, 1, size.width/size.height)
        }

        let mirrorFilter = GPUImageTransformFilter()
        mirrorFilter.affineTransform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        
        let scaleFilter = GPUImageTransformFilter()
        scaleFilter.affineTransform = scale
        
        let cropFilter = GPUImageCropFilter(cropRegion: crop)
        
        let sepiaFilter = GPUImageSepiaFilter()
        sepiaFilter.intensity = sepiaSlider.value
        
        let rotateFilter = GPUImageTransformFilter()
        rotateFilter.affineTransform = CGAffineTransformMakeRotation(angleSlider.value / 180 * CGFloat(M_PI))
        
        let polarFilter = PolarFilter()
        
        source.addTarget(mirrorFilter)
        
        if let customFilter:GPUImageFilter = customFilterClass?() {            
            mirrorFilter.addTarget(customFilter)
            customFilter.addTarget(scaleFilter)
        } else {
            mirrorFilter.addTarget(scaleFilter)
        }
        scaleFilter.addTarget(cropFilter)
        cropFilter.addTarget(sepiaFilter)
        sepiaFilter.addTarget(polarFilter)
        polarFilter.addTarget(rotateFilter)
        
        if let gpuTarget = target {
            rotateFilter.addTarget(gpuTarget)
        }
        
        return (rotateFilter, sepiaFilter, rotateFilter, polarFilter)
    }
    
   
}

