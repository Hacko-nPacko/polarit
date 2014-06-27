//
//  IndicatorConfigurer.swift
//  polarit
//
//  Created by Atanas Balevsky on 6/26/14.
//  Copyright (c) 2014 Atanas Balevsky. All rights reserved.
//

import Foundation


func configureIndicator(indicator: TYMActivityIndicatorView) {
    indicator.hidesWhenStopped = true
    indicator.indicatorImage = UIImage(named: "indicator-spinner-large.png")
    indicator.backgroundImage = UIImage(named: "indicator-background-large.png")

}

func processImage(#image:UIImage, #frame:CGRect, #sepia:CFloat, #angle:CFloat) -> UIImageView {
    let gpuImage = GPUImagePicture(image: image)
    let filters = buildFilters(source: gpuImage, target: nil, originalSize: image.size, sepia: sepia, angle: angle)
    filters.lastFilter.useNextFrameForImageCapture()
    gpuImage.processImage()
    let polarImage = filters.lastFilter.imageFromCurrentFramebuffer()
    UIImageWriteToSavedPhotosAlbum(polarImage, nil, nil, nil)
    
    let polarImageView = UIImageView(image: polarImage)
    polarImageView.contentMode = .ScaleAspectFit
    polarImageView.frame = frame
    polarImageView.alpha = 0

    return polarImageView
}

func buildFilters(#source:GPUImageOutput, #target:GPUImageInput?, originalSize size:CGSize, #sepia:CFloat, #angle:CFloat) -> (lastFilter:GPUImageFilter!, effectFilter:GPUImageSepiaFilter!, rotateFilter:GPUImageTransformFilter!, polarFilter:PolarFilter!) {
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
    sepiaFilter.intensity = sepia
    
    let rotateFilter = GPUImageTransformFilter()
    rotateFilter.affineTransform = CGAffineTransformMakeRotation(angle / 180 * CGFloat(M_PI))
    
    let polarFilter = PolarFilter()
    
    source.addTarget(mirrorFilter)
    
    //if let customFilter = customFilterClass?() {
    //    mirrorFilter.addTarget(customFilter)
    //    customFilter.addTarget(scaleFilter)
    //} else {
    
    mirrorFilter.addTarget(scaleFilter)
    scaleFilter.addTarget(cropFilter)
    cropFilter.addTarget(sepiaFilter)
    sepiaFilter.addTarget(polarFilter)
    polarFilter.addTarget(rotateFilter)
    
    if let gpuTarget = target {
        rotateFilter.addTarget(gpuTarget)
    }
    
    return (rotateFilter, sepiaFilter, rotateFilter, polarFilter)
}