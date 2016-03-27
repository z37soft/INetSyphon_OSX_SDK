//
//  GLView.m
//  INetSyphon_OSX_SDK
//
//  Created by Nozomu MIURA on 2015/12/12.
//  Copyright © 2015年 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import "UDPClientAppDelegate.h"
#import "GLView.h"
#import <OpenGL/CGLMacro.h>


@implementation GLView


-(void)setup
{
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


-(void)draw
{
    GLuint  texture;
    NSSize  texturesize;
    GLenum  texturetarget;
    CGLContextObj cgl_ctx = [[self openGLContext] CGLContextObj];
    
    CGLLockContext(cgl_ctx);
    
    TL_INetUDPSyphonSDK_Client*    sdk = [theApp GetUDPSyphonSDKClient];

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
        glOrtho(bounds.origin.x, bounds.origin.x+bounds.size.width, bounds.origin.y, bounds.origin.y+bounds.size.height, -1.0, 1.0);
        
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
        
        needsReshape = NO;
    }
    
    glClearColor(0.0,0.0,0.0,0.0);
    glClear( GL_COLOR_BUFFER_BIT );
    
    [sdk ClientIdle:cgl_ctx];
    
    if ( ![sdk GetReceiveTextureFromUDPSyphonServer:&texture Resolution:&texturesize TextureTarget:&texturetarget] )
    {
        glColor4f( 1,1,1, 1.0f );
        
        glActiveTexture( GL_TEXTURE0 );
        glEnable( texturetarget );
        glBindTexture( texturetarget, texture );
        
        //Always fit
        glBegin( GL_QUADS );
        glTexCoord2f( 0, 0 );
        glVertex2f( 0, 0 );
        
        glTexCoord2f( texturesize.width, 0 );
        glVertex2f( bounds.size.width, 0 );
        
        glTexCoord2f( texturesize.width, texturesize.height );
        glVertex2f( bounds.size.width, bounds.size.height );
        
        glTexCoord2f( 0, texturesize.height );
        glVertex2f( 0, bounds.size.height );
        glEnd();
        
        glDisable( GL_TEXTURE_RECTANGLE_EXT );
        glDisable( GL_BLEND );
    }
    
    glFlush();
    
    CGLUnlockContext(cgl_ctx);
}


-(CGLContextObj)GetGLContextObj
{
    return [[self openGLContext] CGLContextObj];
}


@end
