//
//  AppDelegate.m
//  SampleTCPClient
//
//  Created by Nozomu MIURA on 2015/12/06.
//  Copyright © 2015 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import "AppDelegate.h"


CVReturn displayLinkCallback(CVDisplayLinkRef displayLink,
                             const CVTimeStamp *inNow,
                             const CVTimeStamp *inOutputTime,
                             CVOptionFlags flagsIn,
                             CVOptionFlags *flagsOut,
                             void *displayLinkContext);



@interface AppDelegate ()

@end


@implementation AppDelegate


- (id) init	{
    self = [super init];
    if (self!=nil)	{
        displayLink = NULL;
        sharedContext = [[NSOpenGLContext alloc] initWithFormat:[self createGLPixelFormat] shareContext:nil];
    }
    return self;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSNotificationCenter*	nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(OnNotify_ChangeTCPSyphonServerList:) name:TL_INetSyphonSDK_ChangeTCPSyphonServerListNotification object:nil];
    
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


- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
    return YES;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    CVDisplayLinkStop( displayLink );
}


- (void)OnNotify_ChangeTCPSyphonServerList:(NSNotification *)aNotification
{
    NSMenuItem* menu;
    int i;
    
    [m_TCPSyphonServerPopupButton removeAllItems];
    TL_INetTCPSyphonSDK_Client*    sdk = [glView GetTCPSyphonSDKClient];
    
    i = 0;
    NSArray*    servers = [sdk GetTCPSyphonServerInformation];
    NSLog( @"Changed TCPSyphonServers--------------" );
    for (NSDictionary* info in servers)
    {
        [m_TCPSyphonServerPopupButton addItemWithTitle:[info objectForKey:@"Name"]];
        menu = [m_TCPSyphonServerPopupButton lastItem];
        [menu setTag:i];
        
        NSLog( @"%@", info );
        ++i;
    }
    NSLog( @"---" );
    
    //If no connection, then try connecting first one.
    if ( [[sdk GetConnectedTCPSyphonServerName] length] <= 0 )
    {
        if ( [servers count] > 0 )
        {
            [sdk ConnectToTCPSyphonServerAtIndex:0];
            [m_TCPSyphonServerPopupButton selectItemAtIndex:0];
        }
    }
}


- (IBAction)ChangedTCPSyphonServerPopupButton:(id)sender {
    NSString*   selectedname = [sender titleOfSelectedItem];
    
    TL_INetTCPSyphonSDK_Client*    sdk = [glView GetTCPSyphonSDKClient];
    [sdk ConnectToTCPSyphonServerByName:selectedname];
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


@end


CVReturn displayLinkCallback(CVDisplayLinkRef displayLink,
                             const CVTimeStamp *inNow,
                             const CVTimeStamp *inOutputTime,
                             CVOptionFlags flagsIn,
                             CVOptionFlags *flagsOut,
                             void *displayLinkContext)
{
    @autoreleasepool {
        [(AppDelegate *)displayLinkContext renderCallback];
    }

    return kCVReturnSuccess;
}

