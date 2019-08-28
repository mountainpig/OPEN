//
//  BaseViewController.h
//  OPEN
//
//  Created by jing huang on 2019/8/27.
//  Copyright © 2019 jing huang. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "Util.h"
#import "AGLKVertexAttribArrayBuffer.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : GLKViewController
@property (nonatomic, strong) GLKBaseEffect *effect;
@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *colorBuffer;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *normalBuffer;
@end

NS_ASSUME_NONNULL_END
