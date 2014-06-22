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
    var lastFilter:GPUImageFilter!
    var prevFilter:GPUImageFilter!
    @IBOutlet var gpuImageView:GPUImageView
    
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
        
        let mirrorFilter = GPUImageTransformFilter()
        mirrorFilter.affineTransform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        videoCamera.addTarget(mirrorFilter)
        
        let scaleFilter = GPUImageTransformFilter() //
        scaleFilter.affineTransform = CGAffineTransformMakeScale(1, 720/1280)
        mirrorFilter.addTarget(scaleFilter)
                
        
        let cropFilter = GPUImageCropFilter(cropRegion: CGRectMake(0, (1280-720)/2/1280, 1, 720/1280))
        scaleFilter.addTarget(cropFilter)
        
        let polarFilter = PolarFilter()
        cropFilter.addTarget(polarFilter)
        polarFilter.addTarget(gpuImageView)
        videoCamera.startCameraCapture()
        
        prevFilter = cropFilter
        lastFilter = polarFilter
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    @IBAction func savePicture() {
        videoCamera.capturePhotoAsImageProcessedUpToFilter(lastFilter, withCompletionHandler: { (image, error) -> Void in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        })
    }
    
    @IBAction func savePrevPicture() {
        videoCamera.capturePhotoAsImageProcessedUpToFilter(prevFilter, withCompletionHandler: { (image, error) -> Void in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        })
    }
}

