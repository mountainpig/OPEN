//
//  TestView.m
//  OPEN
//
//  Created by jing huang on 2019/8/22.
//  Copyright © 2019 jing huang. All rights reserved.
//

#import "TestView.h"
#import <OpenGLES/ES2/gl.h>

@interface TestView()
@property (nonatomic,strong) CAEAGLLayer *myEagLayer;
@property (nonatomic,strong) EAGLContext *myContext;

@property (nonatomic,assign) GLuint myColorRenderBuffer;
@property (nonatomic,assign) GLuint myColorFrameBuffer;

@property (nonatomic,assign) GLuint myPrograme;

@property (nonatomic, strong) NSMutableArray *pointArray;


@property(nonatomic, assign) CGPoint location;
@property(nonatomic, assign) CGPoint previousLocation;

@property (nonatomic, strong) UIButton *clearButton;
@end

@implementation TestView


- (NSMutableArray *)pointArray
{
    if (!_pointArray) {
        _pointArray = [[NSMutableArray alloc] init];
    }
    return _pointArray;
}



+(Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews
{
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_clearButton setTitle:@"clear" forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(clearDraw) forControlEvents:UIControlEventTouchUpInside];
        _clearButton.frame = CGRectMake(0, 100, 60, 40);
        [self addSubview:_clearButton];
        
        UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [colorButton setTitle:@"color" forState:UIControlStateNormal];
        [colorButton addTarget:self action:@selector(colorChange) forControlEvents:UIControlEventTouchUpInside];
        colorButton.frame = CGRectMake(self.frame.size.width - 60, 100, 60, 40);
        [self addSubview:colorButton];
        
        [self setupLayer];
        [self setupContext];
        [self initBuffer];
        [self loadShader];
        [self setRender];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self draw];
        });
    }
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

- (void)loadShader
{
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
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

#pragma mark - 渲染

GLfloat brushColor[4];

- (void)setRender
{
    glClearColor(0,0,0,1);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [UIScreen mainScreen].scale;
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    glUseProgram(self.myPrograme);

    brushColor[0] = 0.33;
    brushColor[1] = 0;
    brushColor[2] = 0;
    brushColor[3] = 0.33;
    glUniform4fv(glGetUniformLocation(self.myPrograme, "positionColor"), 1, brushColor);
    glUniform1f(glGetUniformLocation(self.myPrograme, "pointSize"), 32);
    [self setupTexture:@"Particle.png"];
    glUniform1i(glGetUniformLocation(self.myPrograme, "colorMap"), 0);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}


static GLfloat* attrArr = NULL;
static NSUInteger vertexMax = 64;

- (void)drawPoint:(CGPoint)point toPoint:(CGPoint)nextPoint
{
    
    if(attrArr == NULL)
        attrArr = malloc(vertexMax * 3 * sizeof(GLfloat));
    
    
    float width = self.frame.size.width/2;
    float height = self.frame.size.height/2;

    CGPoint start = point;
    CGPoint end = nextPoint;
    
    NSUInteger vertexCount = 0,
    count,
    i;

    // Add points to the buffer so there are drawing points every X pixels
    count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y))), 1);
    for(i = 0; i < count; ++i) {
        if(vertexCount == vertexMax) {
            vertexMax = 2 * vertexMax;
            attrArr = realloc(attrArr, vertexMax * 3 * sizeof(GLfloat));
        }
        
        float x = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
        float y = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
        
        attrArr[3 * vertexCount + 0] = (x - width)/width;
        attrArr[3 * vertexCount + 1] = (y - height)/height;
        attrArr[3 * vertexCount + 2] = -1;
        vertexCount += 1;
    }

    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, vertexCount * 3 * sizeof(GLfloat), attrArr, GL_DYNAMIC_DRAW);
    GLuint position = glGetAttribLocation(self.myPrograme, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, 0, 0);
    
    glDrawArrays(GL_POINTS, 0, vertexCount);
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)draw
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"123" ofType:@""];
    NSArray *arr = [NSArray arrayWithContentsOfFile:path];
    for (int i = 0; i < arr.count; i+=2) {
        NSDictionary *dict1 = arr[i];
        NSDictionary *dict2 = arr[i + 1];
        [self drawPoint:CGPointMake([dict1[@"x"] floatValue], [dict1[@"y"] floatValue]) toPoint:CGPointMake([dict2[@"x"] floatValue], [dict2[@"y"] floatValue])];
    }

}


#pragma mark - 点击

- (void)clearDraw
{
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}
/*
- (NSString*)filePath:(NSString*)fileName {
    NSArray* myPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* myDocPath = [myPaths objectAtIndex:0];
    NSString* filePath = [myDocPath stringByAppendingPathComponent:fileName];
    return filePath;
}
*/
- (void)colorChange
{
    int r = arc4random() % 255;
    int g = arc4random() % 255;
    int b = arc4random() % 255;
    
    brushColor[0] = ((float)r)/255.0 * 0.33;
    brushColor[1] = ((float)g)/255.0 * 0.33;
    brushColor[2] = ((float)b)/255.0 * 0.33;
    brushColor[3] = 0.33;
    glUniform4fv(glGetUniformLocation(self.myPrograme, "positionColor"), 1, brushColor);
}


#pragma mark - touch
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[[event touchesForView:self] anyObject] locationInView:self];
    location.y = self.bounds.size.height - location.y;
    CGPoint previousLocation = [[[event touchesForView:self] anyObject] previousLocationInView:self];
    previousLocation.y = self.bounds.size.height - previousLocation.y;
    [self drawPoint:previousLocation toPoint:location];
}

@end
