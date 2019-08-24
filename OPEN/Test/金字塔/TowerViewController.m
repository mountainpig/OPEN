//
//  TowerViewController.m
//  OPEN
//
//  Created by 黄 敬 on 2019/8/24.
//  Copyright © 2019年 jing huang. All rights reserved.
//

#import "TowerViewController.h"

@interface TowerViewController ()
{
    EAGLContext *context;
    GLKBaseEffect *cEffect;
}
@property (nonatomic) GLfloat yDegrees;
@property (nonatomic) GLKMatrixStackRef modelviewMatrixStack;
@end

@implementation TowerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpConfig];
    [self setUpEffect];
    [self setUpVertexData];
}

-(void)setUpConfig
{
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glClearColor(0, 0, 0, 1.0);

}

- (void)setUpEffect
{
    cEffect = [[GLKBaseEffect alloc] init];
    [self configureLight];

    GLfloat   aspectRatio =
    (self.view.bounds.size.width) /
    (self.view.bounds.size.height);
    /*
    cEffect.transform.projectionMatrix =
    GLKMatrix4MakeFrustum(
                          -1.0 * aspectRatio,
                          1.0 * aspectRatio,
                          -1.0,
                          1.0,
                          2.0,
                          120.0);
    
    cEffect.transform.modelviewMatrix =
    GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0);
 */
    
}

- (void)configureLight
{
    /*
    cEffect.light0.enabled = GL_TRUE;
    cEffect.light0.diffuseColor = GLKVector4Make(1,1,1,1);// Alpha
    cEffect.light0.position = GLKVector4Make(1,0,0.8,0);
    cEffect.light0.ambientColor = GLKVector4Make(0.2,0.2,0.2,1);// Alpha
     */
}




- (void)setUpVertexData
{
    
    self.modelviewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    GLKMatrixStackLoadMatrix4(self.modelviewMatrixStack,
                              cEffect.transform.modelviewMatrix);
    
    GLfloat attrArr[] =
    {
        0, 0.5f, 0.0f,           1, 0, 0,
        0.5f, -0.5f, 0.5f,       0, 1, 0,
        0.5f, -0.5f, -0.5f,     0, 0, 1,
        -0.5f, -0.5f, -0.5f,     0, 1, 0,
        -0.5f, -0.5f, 0.5f,     0, 0, 1,
    };
    
    GLuint indices[] =
    {
        0, 1, 2,
        0, 2, 3,
        0, 3, 4,
        0, 4, 1,
        2, 4, 3,
        2, 1, 4,
    };
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_DYNAMIC_DRAW);

    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (float *)NULL);
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (float *)NULL + 3);
    
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    
    GLKMatrixStackPush(self.modelviewMatrixStack);

    self.yDegrees += 6;
    
    GLKMatrixStackRotate(self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.yDegrees),
                         0.0, 1.0, 0.0);
    
    cEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    

    [cEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, 18, GL_UNSIGNED_INT, 0);
    
    GLKMatrixStackPop(self.modelviewMatrixStack);
    cEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
}

@end
