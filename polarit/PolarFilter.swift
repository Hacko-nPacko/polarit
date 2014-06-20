//
//  PolarFilter.swift
//  polarit
//
//  Created by Atanas Balevsky on 6/19/14.
//  Copyright (c) 2014 Atanas Balevsky. All rights reserved.
//

import Foundation

class PolarFilter: GPUImageFilter {
    
    
//    var centerUniform:GLint
    
    var center = CGPointMake(0.5, 0.5)
    var size = CGSizeMake(0.5, 0.5)
    
    
    init() {
//        super.init(fragmentShaderFromString: kGPUImagePolarFragmentShaderString)
super.init()
    }
    
}