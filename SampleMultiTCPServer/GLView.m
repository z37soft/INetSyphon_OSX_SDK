//
//  GLView.m
//  INetSyphon_OSX_SDK
//
//  Created by Nozomu MIURA on 2016/03/31.
//  Copyright © 2016年 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import "GLView.h"
#import <OpenGL/CGLMacro.h>

@implementation GLView


-(void)setup:(NSString*)name type:(int)type
{
    shape_type = type;
    
    m_TCPSyphonSDKServer = [[TL_INetTCPSyphonSDK_Server alloc] init];
    [m_TCPSyphonSDKServer SetRequestPort:0];//If you want to set a fixed port, you can set it at here. zero is default(choose automatically).
    [m_TCPSyphonSDKServer StartServer:name];
    
    [m_TCPSyphonSDKServer SetEncodeType:TCPUDPSyphonEncodeType_TURBOJPEG];
    [m_TCPSyphonSDKServer SetEncodeQuality:0.5f];
}


- (void)reshape
{
    needsReshape = YES;
}


- (void)update
{
    CGLLockContext([[self openGLContext] CGLContextObj]);
    [super update];
    CGLUnlockContext([[self openGLContext] CGLContextObj]);
}


-(void)AllocateTexture:(NSRect)rect
{
    GLenum target = GL_TEXTURE_RECTANGLE_EXT;
    GLuint tex;
    
    CGLContextObj cgl_ctx = [[self openGLContext] CGLContextObj];
    
    if ( m_SyphonCopyTexture )
    {
        glDeleteTextures( 1, &m_SyphonCopyTexture );
        m_SyphonCopyTexture = 0;
    }
    
    glGenTextures(1, &tex);
    glBindTexture(target, tex);
    glTexParameteri(target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    //supports GL_RGBA and GL_UNSIGNED_BYTE only.
    glTexImage2D(target, 0, GL_RGBA, rect.size.width, rect.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    m_SyphonCopyTexture = tex;
}


-(void)draw
{
    float cx, cy, radius;
    CGLContextObj cgl_ctx = [[self openGLContext] CGLContextObj];
    
    CGLLockContext(cgl_ctx);
    
    NSRect bounds = self.bounds;
    
    if (needsReshape)
    {
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_BLEND);
        glHint(GL_CLIP_VOLUME_CLIPPING_HINT_EXT, GL_FASTEST);
        
        glMatrixMode(GL_TEXTURE);
        glLoadIdentity();
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glViewport(0, 0, (GLsizei) bounds.size.width, (GLsizei) bounds.size.height);
        glOrtho(bounds.origin.x, bounds.origin.x+bounds.size.width, bounds.origin.y, bounds.origin.y+bounds.size.height, -1.0f, 1.0f);
        
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
        
        [self AllocateTexture:bounds];
        
        needsReshape = NO;
    }
    
    glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
    glClear( GL_COLOR_BUFFER_BIT );
    
    cx = bounds.size.width*0.5f;
    cy = bounds.size.height*0.5f;
    radius = cy * 0.8f;
    
    //old profile style
    glBegin( GL_TRIANGLES );
    glColor4f( 1,0,0, 1.0f );
    glVertex2f( cx + radius*cosf(rotationRad+0.0*2.0*M_PI/3.0), cy + radius*sinf(rotationRad+0.0*2.0*M_PI/3.0) );
    glColor4f( 0,1,0, 1.0f );
    glVertex2f( cx + radius*cosf(rotationRad+1.0*2.0*M_PI/3.0), cy + radius*sinf(rotationRad+1.0*2.0*M_PI/3.0) );
    glColor4f( 0,0,1, 1.0f );
    glVertex2f( cx + radius*cosf(rotationRad+2.0*2.0*M_PI/3.0), cy + radius*sinf(rotationRad+2.0*2.0*M_PI/3.0) );
    glEnd();
    
    rotationRad += (float)shape_type/60.0;
    
    glBindTexture( GL_TEXTURE_RECTANGLE_EXT, m_SyphonCopyTexture );
    //Copy from FRONT buffer
    glCopyTexSubImage2D( GL_TEXTURE_RECTANGLE_EXT, 0, 0, 0, 0, 0, bounds.size.width, bounds.size.height );
    
    //supports GL_RGBA, GL_UNSIGNED_BYTE and GL_TEXTURE_RECTANGLE_EXT only.
    [m_TCPSyphonSDKServer SetSendImageByGLTexture:cgl_ctx Texture:m_SyphonCopyTexture Width:bounds.size.width Height:bounds.size.height];
    
    glFlush();
    
    CGLUnlockContext(cgl_ctx);
}


@end
