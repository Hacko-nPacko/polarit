//
//  PolarFilter.m
//  polarit
//
//  Created by Atanas Balevsky on 6/19/14.
//  Copyright (c) 2014 Atanas Balevsky. All rights reserved.
//

#import "PolarFilter.h"

NSString *const kVertexShader = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 varying vec2 textureCoordinate;

 
 void main() {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

NSString *const kFragmentShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 const highp float PI = 3.1415926535897932384626433832795;
 const highp vec2 center = vec2(0.5);

 void main() {
     highp vec4 color;
     highp vec2 calcPoint = textureCoordinate - center;
     
     if (pow(abs(calcPoint.x), 2.0) + pow(abs(calcPoint.y), 2.0) <= pow(0.5, 2.0)) {
         highp float rad = length(calcPoint) * 2.0;
         highp float thita = ((atan(calcPoint.y, calcPoint.x)/ PI) + 1.0) / 2.0;
         highp vec2 polar = vec2(thita, rad);
         color = texture2D(inputImageTexture, polar);
     } else {
         color = vec4(0.0);
     }
     gl_FragColor = color;
 }
 );


@implementation PolarFilter
- (id)init {
    if (!(self = [super initWithVertexShaderFromString:kVertexShader fragmentShaderFromString:kFragmentShader])) {
        return nil;
    }
    return self;
}

@end
