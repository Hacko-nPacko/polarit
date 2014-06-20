#import "GPUImageFilter.h"

@interface PolarFilter : GPUImageFilter {
    GLint centerUniform, pixelSizeUniform;
    GLint transformMatrixUniform, orthographicMatrixUniform;
    GPUMatrix4x4 orthographicMatrix;
}

// The center about which to apply the distortion, with a default of (0.5, 0.5)
@property(readwrite, nonatomic) CGPoint center;
// The amount of distortion to apply, from (-2.0, -2.0) to (2.0, 2.0), with a default of (0.05, 0.05)
@property(readwrite, nonatomic) CGSize pixelSize;

// You can either set the transform to apply to be a 2-D affine transform or a 3-D transform. The default is the identity transform (the output image is identical to the input).
@property(readwrite, nonatomic) CGAffineTransform affineTransform;

// This applies the transform to the raw frame data if set to YES, the default of NO takes the aspect ratio of the image input into account when rotating
@property(readwrite, nonatomic) BOOL ignoreAspectRatio;

// sets the anchor point to top left corner
@property(readwrite, nonatomic) BOOL anchorTopLeft;

@end
