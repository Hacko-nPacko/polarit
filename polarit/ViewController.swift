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
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Back)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(coder aDecoder: NSCoder!) {
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Back)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoCamera.outputImageOrientation = .Portrait
        videoCamera.horizontallyMirrorFrontFacingCamera = false
        videoCamera.horizontallyMirrorRearFacingCamera = false
                
        //let sepiaFilter = GPUImageSepiaFilter()
        let polarFilter = PolarFilter()
        videoCamera.addTarget(polarFilter)
//        sepiaFilter.addTarget(polarFilter)
        polarFilter.addTarget(view as GPUImageView)
        videoCamera.startCameraCapture()
        
        lastFilter = polarFilter
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        var orient:UIInterfaceOrientation = .Portrait
        switch (UIDevice.currentDevice().orientation) {
        case .LandscapeLeft:
            orient = .LandscapeLeft
        case .LandscapeRight:
            orient = .LandscapeRight
        case .Portrait:
            orient = .Portrait
        case .PortraitUpsideDown:
            orient = .PortraitUpsideDown
        default:
            orient = fromInterfaceOrientation
        }
        videoCamera.outputImageOrientation = orient;

    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    @IBAction func savePicture() {
        videoCamera.capturePhotoAsImageProcessedUpToFilter(lastFilter, withCompletionHandler: { (image, error) -> Void in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        })
    }
}

