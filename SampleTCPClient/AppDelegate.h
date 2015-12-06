//
//  AppDelegate.h
//  SampleTCPClient
//
//  Created by Nozomu MIURA on 2015/12/06.
//  Copyright © 2015 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GLView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    CVDisplayLinkRef			displayLink;
    NSOpenGLContext				*sharedContext;
    
    IBOutlet NSWindow			*window;
    IBOutlet GLView				*glView;
    
    IBOutlet NSPopUpButton *m_TCPSyphonServerPopupButton;
}

- (NSOpenGLPixelFormat *) createGLPixelFormat;

- (IBAction)ChangedTCPSyphonServerPopupButton:(id)sender;

@end

