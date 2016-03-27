//
//  UDPServerAppDelegate.m
//  SampleUDPServer
//
//  Created by Nozomu MIURA on 2015/12/12.
//  Copyright © 2015 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import "UDPServerAppDelegate.h"


UDPServerAppDelegate*   theApp;

CVReturn displayLinkCallback(CVDisplayLinkRef displayLink,
                             const CVTimeStamp *inNow,
                             const CVTimeStamp *inOutputTime,
                             CVOptionFlags flagsIn,
                             CVOptionFlags *flagsOut,
                             void *displayLinkContext);


@interface UDPServerAppDelegate ()

@end


@implementation UDPServerAppDelegate


- (id) init	{
    self = [super init];
    if (self!=nil)	{
        NSArray*    interfaces;
        
        theApp = self;
        
        displayLink = NULL;
        sharedContext = [[NSOpenGLContext alloc] initWithFormat:[self createGLPixelFormat] shareContext:nil];
        
        m_UDPSyphonSDKServer = [[TL_INetUDPSyphonSDK_Server alloc] init];
        
        [m_UDPSyphonSDKServer SetEncodeType:TCPUDPSyphonEncodeType_TURBOJPEG];
        [m_UDPSyphonSDKServer SetEncodeQuality:0.75f];
        [m_UDPSyphonSDKServer SetServerRequestFPS:10];
        
        interfaces = [m_UDPSyphonSDKServer QueryNetworkInterface];
        for (NSDictionary* inf in interfaces) NSLog( @"%@", inf );
        
        //At least we must choose 1 ip-address.
        m_MyIPAddress = [[interfaces[0] objectForKey:@"Address"] copy];
        m_MyBroadcastAddress = [[interfaces[0] objectForKey:@"Broadaddr"] copy];
    }
    return self;
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
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
    
    [self RebuildServerSession];
}


- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
    return YES;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    CVDisplayLinkStop( displayLink );
    
    [m_UDPSyphonSDKServer StopServer];
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
        [(UDPServerAppDelegate *)displayLinkContext renderCallback];
    }
    
    return kCVReturnSuccess;
}


-(void)RebuildServerSession
{
    NSInteger methodType = [m_SendMethodPopupButton indexOfSelectedItem];
    NSString*   ip = [m_IPAddressTextField stringValue];
    NSInteger   port = [m_PortTextField integerValue];
    
    if ( port <= 0 || port > 65535 )
    {
        NSLog( @"Invalidate port." );
        return;
    }
    
    switch ( methodType )
    {
        case UDPMethodType_Broadcast:
            //You should set your broadcast address via [m_UDPSyphonSDK QueryNetworkInterface]
            ip = m_MyBroadcastAddress;
            [m_IPAddressTextField setEnabled:NO];
            break;
        default:
            [m_IPAddressTextField setEnabled:YES];
            break;
    }
    
    [m_UDPSyphonSDKServer StartServer:(UDPMethodType)methodType IPAddress:ip Port:port  SourceIPAddress:m_MyIPAddress];
}


- (IBAction)ChangedSendMethod:(id)sender {
    [self RebuildServerSession];
}


- (IBAction)ChangedIPAddressTextField:(id)sender {
    [self RebuildServerSession];
}

- (IBAction)ChangedPortTextField:(id)sender {
    [self RebuildServerSession];
}



-(TL_INetUDPSyphonSDK_Server*)GetUDPSyphonSDKServer
{
    return  m_UDPSyphonSDKServer;
}


@end
