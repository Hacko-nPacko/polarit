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
 uniform highp vec2 center;
 
 void main()
 {
     float len = length(position);
     float thita = atan(position.x, position.y);
     float radius = 0.5;
//     gl_Position = vec4(len * thita * radius + center.x, len * thita * radius + center.y, position.z, position.w) ;//position + ;
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

NSString *const kFragmentShader = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 void main() {
     gl_FragColor = color;
 }
 );


@implementation PolarFilter
- (id)init {
    if (!(self = [super initWithVertexShaderFromString:kVertexShader fragmentShaderFromString:kGPUImagePassthroughFragmentShaderString])) {
        return nil;
    }
    
    centerUniform = [filterProgram uniformIndex:@"center"];
    self.center = CGPointMake(0.5, 0.5);
    return self;
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    [super setInputRotation:newInputRotation atIndex:textureIndex];
    [self setCenter:self.center];
}

- (void)setCenter:(CGPoint)newValue {
    _center = newValue;
    
    CGPoint rotatedPoint = [self rotatedPoint:_center forRotation:inputRotation];
    [self setPoint:rotatedPoint forUniform:centerUniform program:filterProgram];
}
@end