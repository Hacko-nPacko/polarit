//
//  ViewController.swift
//  polarit
//
//  Created by Atanas Balevsky on 6/19/14.
//  Copyright (c) 2014 Atanas Balevsky. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let videoCamera:GPUImageStillCamera
    let lastFilter:PolarFilter
    @IBOutlet var gpuImageView:GPUImageView
    @IBOutlet var angleSlider:ASValueTrackingSlider
    @IBOutlet var effectSlider:ASValueTrackingSlider
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPreset1280x720, cameraPosition: .Back)
        lastFilter = PolarFilter()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(coder aDecoder: NSCoder!) {
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPreset1280x720, cameraPosition: .Back)
        lastFilter = PolarFilter()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoCamera.outputImageOrientation = .Portrait
        gpuImageView.setInputRotation(kGPUImageNoRotation, atIndex: 0)

        let mirrorFilter = GPUImageTransformFilter()
        mirrorFilter.affineTransform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        videoCamera.addTarget(mirrorFilter)
        
        let scaleFilter = GPUImageTransformFilter()
        scaleFilter.affineTransform = CGAffineTransformMakeScale(1, 720/1280)
        mirrorFilter.addTarget(scaleFilter)
                
        
        let cropFilter = GPUImageCropFilter(cropRegion: CGRectMake(0, (1280-720)/2/1280, 1, 720/1280))
        scaleFilter.addTarget(cropFilter)
        
        cropFilter.addTarget(lastFilter)
        lastFilter.addTarget(gpuImageView)
        
        angleSlider.setMaxFractionDigitsDisplayed(0)

        //angleSlider.dataSource = self
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
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        })
    }
    
    @IBAction func angleChanged(sender:UISlider) {
        lastFilter.angle = (sender.value / 2) / 180 / CGFloat(M_PI)
        NSLog("%f", lastFilter.angle);
        
    }
    
    @IBAction func effectChanged(sender:UISlider) {
        NSLog("%f", lastFilter.angle);
        
    }
    
}

