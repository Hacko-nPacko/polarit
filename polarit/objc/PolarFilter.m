#import "PolarFilter.h"

NSString *const kPolarFragmentShaderString = SHADER_STRING
(
 
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 uniform mat4 transformMatrix;
 uniform mat4 orthographicMatrix;
 
 varying vec2 textureCoordinate;
 
 void main() {
     gl_Position = transformMatrix * vec4(position.xyz, 1.0) * orthographicMatrix;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 
);

@implementation PolarFilter

@synthesize center = _center;

@synthesize pixelSize = _pixelSize;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kPolarFragmentShaderString]))
    {
		return nil;
    }
    
    pixelSizeUniform = [filterProgram uniformIndex:@"pixelSize"];
    centerUniform = [filterProgram uniformIndex:@"center"];
    
    transformMatrixUniform = [filterProgram uniformIndex:@"transformMatrix"];
    orthographicMatrixUniform = [filterProgram uniformIndex:@"orthographicMatrix"];
    
    
    self.pixelSize = CGSizeMake(0.01, 0.01);
    self.center = CGPointMake(0.5, 0.5);
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    [super setInputRotation:newInputRotation atIndex:textureIndex];
    [self setCenter:self.center];
}

- (void)setPixelSize:(CGSize)pixelSize 
{
    _pixelSize = pixelSize;
    
    [self setSize:_pixelSize forUniform:pixelSizeUniform program:filterProgram];
}

- (void)setCenter:(CGPoint)newValue;
{
    _center = newValue;
    
    CGPoint rotatedPoint = [self rotatedPoint:_center forRotation:inputRotation];
    [self setPoint:rotatedPoint forUniform:centerUniform program:filterProgram];
}

@end
