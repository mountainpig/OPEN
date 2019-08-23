//
//  BaseView.m
//  OPEN
//
//  Created by jing huang on 2019/8/23.
//  Copyright © 2019 jing huang. All rights reserved.
//

#import "BaseView.h"


@interface BaseView()
@property (nonatomic,strong) CAEAGLLayer *myEagLayer;

@property (nonatomic,assign) GLuint myColorRenderBuffer;
@property (nonatomic,assign) GLuint myColorFrameBuffer;


@end


@implementation BaseView

+(Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews
{
    [self setupLayer];
    [self setupContext];
    [self initBuffer];
    [self loadShader];
    [self setRender];
}

- (void)setupLayer
{
    self.myEagLayer = (CAEAGLLayer *)self.layer;
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    self.myEagLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:[NSNumber numberWithBool:YES],kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
}

- (void)setupContext
{
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    self.myContext = context;
}

- (void)initBuffer
{
    glDeleteBuffers(1, &_myColorRenderBuffer);
    glDeleteBuffers(1, &_myColorFrameBuffer);
    
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.myColorRenderBuffer = buffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
    
    GLuint buffer2;
    glGenFramebuffers(1, &buffer2);
    self.myColorFrameBuffer = buffer;
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}

- (NSString *)shaderName
{
    return @"shader";
}

- (void)loadShader
{
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:[self shaderName] ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:[self shaderName] ofType:@"fsh"];
    GLuint verShader, fragShader;
    GLint program = glCreateProgram();
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vertFile];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragFile];
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    self.myPrograme = program;
    glLinkProgram(self.myPrograme);
    GLint linkStatus;
    glGetProgramiv(self.myPrograme, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        NSLog(@"link fail");
    } else {
        NSLog(@"link success");
    }
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar *)[content UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source,NULL);
    glCompileShader(*shader);
    
}


- (void)setRender
{
    glClearColor(0,0,0,1);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [UIScreen mainScreen].scale;
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    glUseProgram(self.myPrograme);
    [self render];
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)render
{

    
}

#pragma mark - texture
//从图片中加载纹理
- (GLuint)setupTexture:(NSString *)fileName {
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(spriteContext, rect, spriteImage);
    CGContextRelease(spriteContext);
    glBindTexture(GL_TEXTURE_2D, 0);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    free(spriteData);
    return 0;
}

@end
