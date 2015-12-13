//
//  AppDelegate.h
//  UDPClientSampleUDPClient
//
//  Created by Nozomu MIURA on 2015/12/12.
//  Copyright © 2015 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TL_INetSyphonSDK/TL_INetSyphonSDK.h"
#import "GLView.h"


@interface UDPClientAppDelegate : NSObject <NSApplicationDelegate>
{
    TL_INetUDPSyphonSDK*        m_UDPSyphonSDK;
    
    int                         m_TargetPort;
    
    NSString*                   m_MyIPAddress;

    CVDisplayLinkRef			displayLink;
    NSOpenGLContext				*sharedContext;

    IBOutlet NSWindow			*window;
    IBOutlet GLView				*glView;

    IBOutlet NSTextField *m_PortTextField;
    IBOutlet NSPopUpButton *m_ReceiveMethodPopupButton;
    IBOutlet NSTextField *m_MulticastGroupEditBox;
}

- (IBAction)ChangedReceiveMethodPopupButton:(id)sender;
- (IBAction)ChangedMulticastTextField:(id)sender;

- (IBAction)ChangedPortTextField:(id)sender;

-(TL_INetUDPSyphonSDK*)GetUDPSyphonSDK;

@end

extern  UDPClientAppDelegate*   theApp;
