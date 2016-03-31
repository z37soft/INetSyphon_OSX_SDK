//
//  AppDelegate.h
//  SampleMultiTCPServer
//
//  Created by Nozomu MIURA on 2016/03/31.
//  Copyright © 2016年 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GLView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    CVDisplayLinkRef			displayLink;
    NSOpenGLContext				*sharedContext;
    
    IBOutlet NSWindow			*window;
    IBOutlet GLView				*glView1;
    IBOutlet GLView				*glView2;
    IBOutlet GLView				*glView3;
    IBOutlet GLView				*glView4;
}

- (NSOpenGLPixelFormat *) createGLPixelFormat;

@end

