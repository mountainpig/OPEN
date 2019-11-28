//
//  BaseView.h
//  OPEN
//
//  Created by jing huang on 2019/8/23.
//  Copyright © 2019 jing huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseView : UIView
@property (nonatomic,assign) GLuint myPrograme;
@property (nonatomic,strong) EAGLContext *myContext;
- (GLuint)setupTexture:(NSString *)fileName;
@end

NS_ASSUME_NONNULL_END
