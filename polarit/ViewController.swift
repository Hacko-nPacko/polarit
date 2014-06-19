//
//  ViewController.swift
//  polarit
//
//  Created by Atanas Balevsky on 6/19/14.
//  Copyright (c) 2014 Atanas Balevsky. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        /*
GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc]
initWithSessionPreset:AVCaptureSessionPreset640x480
cameraPosition:AVCaptureDevicePositionBack];

        videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;

GPUImageFilter *filter = [[GPUImageLevelsFilter alloc] initWithFragmentShaderFromFile:@"CustomShader"];
[filter setRedMin:0.299 gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
[filter setGreenMin:0.587 gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
[filter setBlueMin:0.114 gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
[videoCamera addTarget:filter];

GPUImageView *filteredVideoView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
[filter addTarget:filteredVideoView];
[self.view addSubview:filteredVideoView];

[videoCamera startCameraCapture];
*/
        let videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset1280x720, cameraPosition: .Back)
        videoCamera.outputImageOrientation = .Portrait
        
        let filter = GPUImageLevelsFilter(fragmentShaderFromFile: "CustomShader")
        filter.setRedMin(0.299, gamma:1.0, max:1.0, minOut:0.0, maxOut:1.0)
        filter.setGreenMin(0.587, gamma:1.0, max:1.0, minOut:0.0, maxOut:1.0)
        filter.setBlueMin(0.114, gamma:1.0, max:1.0, minOut:0.0, maxOut:1.0)
        videoCamera.addTarget(filter)
        
        let filteredVideoView = GPUImageView(frame: self.view.bounds)
        filter.addTarget(filteredVideoView)
        view.addSubview(filteredVideoView)
        
        videoCamera.startCameraCapture()
    }

}

