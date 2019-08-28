//
//  MagicCubeViewController.m
//  OPEN
//
//  Created by jing huang on 2019/8/27.
//  Copyright © 2019 jing huang. All rights reserved.
//

#import "MagicCubeViewController.h"

@interface MagicCubeViewController ()
{
    float one_width;
}
@property (nonatomic) GLKMatrixStackRef modelviewMatrixStack;
@property (nonatomic, assign) BOOL pause;
@end

@implementation MagicCubeViewController


OPTriangle triangles[12];

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.preferredFramesPerSecond = 100000;
    
    GLfloat   aspectRatio =
    (self.view.bounds.size.width) /
    (self.view.bounds.size.height);


    self.effect.transform.projectionMatrix =
    GLKMatrix4MakeFrustum(
                          -1.0 * aspectRatio,
                          1.0 * aspectRatio,
                          -1.0,
                          1.0,
                          1.0,
                          120.0);
    
    self.effect.transform.modelviewMatrix =
    GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0);
    
    
    self.modelviewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    
    GLKMatrixStackLoadMatrix4(self.modelviewMatrixStack,
                              self.effect.transform.modelviewMatrix);
    
    float rate = 1;
    float scale = 0.25;

    one_width = scale;
    
    OPVertex vertex1 = {{-0.5 * scale,  -0.5 * rate * scale, -0.5f* scale}, {1, 0.0, 0},{1, 0.0, 0}};
    OPVertex vertex2 = {{0.5f * scale, -0.5f * rate* scale, -0.5f* scale}, {1, 0, 0,},{1, 0.0, 0}};
    OPVertex vertex3 = {{0.5f * scale, 0.5f * rate* scale, -0.5f* scale}, {1, 0, 0},{1, 0.0, 0}};
    OPVertex vertex4 = {{-0.5f * scale, 0.5f * rate* scale, -0.5f* scale}, {1, 0, 0},{1, 0.0, 0}};
    OPVertex vertex5 = {{-0.5f * scale, -0.5f * rate* scale, 0.5f* scale}, {0, 0, 1},{1, 0.0, 0}};
    OPVertex vertex6 = {{0.5f * scale, -0.5f * rate* scale, 0.5f* scale}, {0, 0, 1},{1, 0.0, 0}};
    OPVertex vertex7 = {{0.5f * scale, 0.5f * rate* scale, 0.5f* scale}, {0, 0, 1},{1, 0.0, 0}};
    OPVertex vertex8 = {{-0.5f * scale, 0.5f * rate* scale, 0.5f* scale}, {0, 0, 1},{1, 0.0, 0}};
    
    triangles[0] = OPTriangleMake(vertex1, vertex2, vertex4); //前
    triangles[1] = OPTriangleMake(vertex4, vertex2, vertex3); //前
    triangles[0] = OPTrianglesUpdateFaceColor(triangles[0],GLKVector3Make(1.f, 0, 0));
    triangles[1] = OPTrianglesUpdateFaceColor(triangles[1],GLKVector3Make(1.f, 0, 0)); //红

    triangles[2] = OPTriangleMake(vertex5, vertex8, vertex6); //后
    triangles[3] = OPTriangleMake(vertex8, vertex7, vertex6); //后
    triangles[2] = OPTrianglesUpdateFaceColor(triangles[2],GLKVector3Make(0, 1, 0));
    triangles[3] = OPTrianglesUpdateFaceColor(triangles[3],GLKVector3Make(0, 1, 0));
    
    triangles[4] = OPTriangleMake(vertex1, vertex4, vertex5); //左
    triangles[5] = OPTriangleMake(vertex4, vertex8, vertex5); //左
    triangles[4] = OPTrianglesUpdateFaceColor(triangles[4],GLKVector3Make(0, 0, 1));
    triangles[5] = OPTrianglesUpdateFaceColor(triangles[5],GLKVector3Make(0, 0, 1));
    
    triangles[6] = OPTriangleMake(vertex2, vertex6, vertex3); //右
    triangles[7] = OPTriangleMake(vertex3, vertex6, vertex7); //右
    triangles[6] = OPTrianglesUpdateFaceColor(triangles[6],GLKVector3Make(1, 1, 1));
    triangles[7] = OPTrianglesUpdateFaceColor(triangles[7],GLKVector3Make(1, 1, 1));
    
    triangles[8] = OPTriangleMake(vertex4, vertex3, vertex8); //上
    triangles[9] = OPTriangleMake(vertex3, vertex7, vertex8); //上
    triangles[8] = OPTrianglesUpdateFaceColor(triangles[8],GLKVector3Make(1, 1, 0));
    triangles[9] = OPTrianglesUpdateFaceColor(triangles[9],GLKVector3Make(1, 1, 0));
    
    triangles[10] = OPTriangleMake(vertex1, vertex5, vertex2); //下
    triangles[11] = OPTriangleMake(vertex2, vertex5, vertex6); //下
    triangles[10] = OPTrianglesUpdateFaceColor(triangles[10],GLKVector3Make(1, 97.f/255.f, 0));
    triangles[11] = OPTrianglesUpdateFaceColor(triangles[11],GLKVector3Make(1, 97.f/255.f, 0));
  
    
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(OPVertex) numberOfVertices:sizeof(triangles)/sizeof(OPVertex) bytes:triangles usage:GL_DYNAMIC_DRAW];
    self.colorBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(OPVertex) numberOfVertices:sizeof(triangles)/sizeof(OPVertex) bytes:triangles usage:GL_DYNAMIC_DRAW];
    
}

- (void)update
{
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    /*
    if (self.pause) {
        return;
    }
     */
    NSLog(@"+++++++++++");
    self.pause = YES;
    glEnable(GL_DEPTH_TEST);
//    glEnable(GL_CULL_FACE);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    [self.vertexBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:offsetof(OPVertex, position)
     shouldEnable:YES];
    [self.colorBuffer
     prepareToDrawWithAttrib:GLKVertexAttribColor
     numberOfCoordinates:3
     attribOffset:offsetof(OPVertex, color)
     shouldEnable:YES];
    
    GLKMatrixStackPush(self.modelviewMatrixStack);
    GLKMatrixStackRotate(self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(10),
                         0.0, 1.0, 0.0);
    GLKMatrixStackRotate(self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(10),
                         1.0, 0.0, 0.0);
    self.effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 36);
    

    [self drawWithX:0 y:one_width z:0];
    [self drawWithX:one_width y:0 z:0];
    [self drawWithX:0 y:-one_width z:0];
    [self drawWithX:0 y:-one_width z:0];
    /*
    triangles[0] = OPTrianglesUpdateFaceColor(triangles[0],GLKVector3Make(0, 0, 0));
    triangles[1] = OPTrianglesUpdateFaceColor(triangles[1],GLKVector3Make(0, 0, 0)); //红
    [self.colorBuffer reinitWithAttribStride:sizeof(OPVertex) numberOfVertices:sizeof(triangles)/sizeof(OPVertex) bytes:triangles];
    */
     
    [self drawWithX:-one_width y:0 z:0];
    [self drawWithX:-one_width y:0 z:0];
    [self drawWithX:0 y:one_width z:0];
    [self drawWithX:0 y:one_width z:0];
 
    [self drawWithX:0 y:0 z:one_width];
    [self drawWithX:one_width y:0 z:0];
    [self drawWithX:one_width y:0 z:0];
    [self drawWithX:0 y:-one_width z:0];
    [self drawWithX:0 y:-one_width z:0];
    [self drawWithX:-one_width y:0 z:0];
    [self drawWithX:-one_width y:0 z:0];
    [self drawWithX:0 y:one_width z:0];
    [self drawWithX:one_width y:0 z:0];
    
    [self drawWithX:0 y:0 z:-one_width * 2];
    [self drawWithX:0 y:one_width z:0];
    [self drawWithX:one_width y:0 z:0];
    [self drawWithX:0 y:-one_width z:0];
    [self drawWithX:0 y:-one_width z:0];
    [self drawWithX:-one_width y:0 z:0];
    [self drawWithX:-one_width y:0 z:0];
    [self drawWithX:0 y:one_width z:0];
    [self drawWithX:0 y:one_width z:0];
  

    GLKMatrixStackPop(self.modelviewMatrixStack);
    self.effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    

}


- (void)drawWithX:(float)x y:(float)y z:(float)z
{
    [self drawWithX:x y:y z:z offset:0 count:36];
}

- (void)drawWithX:(float)x y:(float)y z:(float)z offset:(int)offset count:(int)count
{
    x *= 1.1;
    y *= 1.1;
    z *= 1.1;
//    y *= self.view.frame.size.width/self.view.frame.size.height;
    GLKMatrixStackTranslate(self.modelviewMatrixStack, x, y, z);
    self.effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

 
@end
