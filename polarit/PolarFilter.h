//
//  PolarFilter.h
//  polarit
//
//  Created by Atanas Balevsky on 6/19/14.
//  Copyright (c) 2014 Atanas Balevsky. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface PolarFilter : GPUImageFilter {
    GLint centerUniform;
}

/// The center about which to apply the distortion, with a default of (0.5, 0.5)
@property(readwrite, nonatomic) CGPoint center;



@end
