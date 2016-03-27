//
//  UDPClientAppDelegate.m
//  SampleUDPClient
//
//  Created by Nozomu MIURA on 2015/12/12.
//  Copyright © 2015 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import "UDPClientAppDelegate.h"


UDPClientAppDelegate*   theApp;


CVReturn displayLinkCallback(CVDisplayLinkRef displayLink,
                             const CVTimeStamp *inNow,
                             const CVTimeStamp *inOutputTime,
                             CVOptionFlags flagsIn,
                             CVOptionFlags *flagsOut,
                             void *displayLinkContext);


@interface UDPClientAppDelegate ()

@end

@implementation UDPClientAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSArray*    interfaces;
    
    theApp = self;
    
    displayLink = NULL;
    sharedContext = [[NSOpenGLContext alloc] initWithFormat:[self createGLPixelFormat] shareContext:nil];

    m_UDPSyphonSDKClient = [[TL_INetUDPSyphonSDK_Client alloc] init];
    
    interfaces = [m_UDPSyphonSDKClient QueryNetworkInterface];
    for (NSDictionary* inf in interfaces) NSLog( @"%@", inf );

    //At least we must choose 1 ip-address.
    m_MyIPAddress = [[interfaces[0] objectForKey:@"Address"] copy];
    
    @synchronized (self)	{
        NSOpenGLContext		*newCtx = [[[NSOpenGLContext alloc] initWithFormat:[self createGLPixelFormat] shareContext:sharedContext] autorelease];
        [glView setOpenGLContext:newCtx];
        [newCtx setView:glView];
        [glView setup];
        [glView reshape];
    }
    
    CVReturn				err = kCVReturnSuccess;
    CGOpenGLDisplayMask		totalDisplayMask = 0;
    GLint					virtualScreen = 0;
    GLint					displayMask = 0;
    NSOpenGLPixelFormat		*format = [self createGLPixelFormat];
    
    for (virtualScreen=0; virtualScreen<[format numberOfVirtualScreens]; ++virtualScreen)	{
        [format getValues:&displayMask forAttribute:NSOpenGLPFAScreenMask forVirtualScreen:virtualScreen];
        totalDisplayMask |= displayMask;
    }
    err = CVDisplayLinkCreateWithOpenGLDisplayMask(totalDisplayMask, &displayLink);
    if (err)	{
        NSLog(@"\t\terr %d creating display link in %s",err,__func__);
        displayLink = NULL;
    }
    else	{
        CVDisplayLinkSetOutputCallback(displayLink, displayLinkCallback, self);
        CVDisplayLinkStart(displayLink);
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    CVDisplayLinkStop( displayLink );
    [m_UDPSyphonSDKClient StopClient:[glView GetGLContextObj]];
}


- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
    return YES;
}



- (IBAction)ChangedReceiveMethodPopupButton:(id)sender {
    int isel = (int)[m_ReceiveMethodPopupButton indexOfSelectedItem];
    if ( isel != 0 )
        [m_MulticastGroupEditBox setEnabled:YES];
    else
        [m_MulticastGroupEditBox setEnabled:NO];
    [self RebuildClientSession];
}


- (IBAction)ChangedMulticastTextField:(id)sender {
    [self RebuildClientSession];
}


- (IBAction)ChangedPortTextField:(id)sender {
    [self RebuildClientSession];
}



-(void)RebuildClientSession
{
    int method = (int)[m_ReceiveMethodPopupButton indexOfSelectedItem];
    NSString*   multicastgroup = [m_MulticastGroupEditBox stringValue];
    NSInteger   port = [m_PortTextField integerValue];
    
    if ( method == 1 )
    {
        if ( [multicastgroup length] <= 0 )
        {
            NSLog( @"Invalidate multicast group." );
            return;
        }
    }
    else
        multicastgroup = nil;
    
    if ( port <= 0 || port > 65535 )
    {
        NSLog( @"Invalidate port." );
        return;
    }
    
    [m_UDPSyphonSDKClient StartClient:[glView GetGLContextObj] Port:port MulticastGroup:multicastgroup SourceIPAddress:m_MyIPAddress];
}


- (void) renderCallback	{
    
    [glView draw];
}


- (NSOpenGLPixelFormat *) createGLPixelFormat	{
    GLuint				glDisplayMaskForAllScreens = 0;
    CGDirectDisplayID	displays[10];
    CGDisplayCount		count = 0;
    if (CGGetActiveDisplayList(10,displays,&count)==kCGErrorSuccess)	{
        for (int i=0; i<count; ++i)
            glDisplayMaskForAllScreens |= CGDisplayIDToOpenGLDisplayMask(displays[i]);
    }
    
    NSOpenGLPixelFormatAttribute	attrs[] = {
        NSOpenGLPFAAccelerated,
        NSOpenGLPFAScreenMask,glDisplayMaskForAllScreens,
        NSOpenGLPFANoRecovery,
        NSOpenGLPFAAllowOfflineRenderers,
        0};
    return [[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs] autorelease];
}


CVReturn displayLinkCallback(CVDisplayLinkRef displayLink,
                             const CVTimeStamp *inNow,
                             const CVTimeStamp *inOutputTime,
                             CVOptionFlags flagsIn,
                             CVOptionFlags *flagsOut,
                             void *displayLinkContext)
{
    @autoreleasepool {
        [(UDPClientAppDelegate *)displayLinkContext renderCallback];
    }
    
    return kCVReturnSuccess;
}


-(TL_INetUDPSyphonSDK_Client*)GetUDPSyphonSDKClient
{
    return  m_UDPSyphonSDKClient;
}

@end
