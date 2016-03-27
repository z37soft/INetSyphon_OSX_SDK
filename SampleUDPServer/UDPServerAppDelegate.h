//
//  UDPServerAppDelegate.h
//  SampleUDPServer
//
//  Created by Nozomu MIURA on 2015/12/12.
//  Copyright © 2015 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TL_INetSyphonSDK/TL_INetSyphonSDK.h"
#import "GLView.h"

@interface UDPServerAppDelegate : NSObject <NSApplicationDelegate>
{
    TL_INetUDPSyphonSDK_Server* m_UDPSyphonSDKServer;

    NSString*                   m_MyIPAddress;
    NSString*                   m_MyBroadcastAddress;
    
    CVDisplayLinkRef			displayLink;
    NSOpenGLContext				*sharedContext;
    
    IBOutlet NSWindow			*window;
    IBOutlet GLView				*glView;
    
    IBOutlet NSPopUpButton *m_SendMethodPopupButton;
    
    IBOutlet NSTextField *m_IPAddressTextField;
    IBOutlet NSTextField *m_PortTextField;
}

- (IBAction)ChangedSendMethod:(id)sender;

- (IBAction)ChangedIPAddressTextField:(id)sender;
- (IBAction)ChangedPortTextField:(id)sender;

- (NSOpenGLPixelFormat *) createGLPixelFormat;

-(TL_INetUDPSyphonSDK_Server*)GetUDPSyphonSDKServer;

@end

extern  UDPServerAppDelegate*   theApp;
