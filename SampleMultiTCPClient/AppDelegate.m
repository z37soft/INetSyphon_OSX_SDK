//
//  AppDelegate.m
//  SampleMultiTCPClient
//
//  Created by Nozomu MIURA on 2016/04/04.
//  Copyright © 2016年 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import "AppDelegate.h"


CVReturn displayLinkCallback(CVDisplayLinkRef displayLink,
                             const CVTimeStamp *inNow,
                             const CVTimeStamp *inOutputTime,
                             CVOptionFlags flagsIn,
                             CVOptionFlags *flagsOut,
                             void *displayLinkContext);



@interface AppDelegate ()
{
    NSArray*            mGLViews;
    NSArray*            mSyphons;
    
    
}

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
        NSArray* viewarray = @[ glView1, glView2, glView3, glView4 ];
        mGLViews = [viewarray retain];

        int i;
        
        i = 0;
        for ( GLView* view in viewarray )
        {
            NSOpenGLContext		*newCtx = [[[NSOpenGLContext alloc] initWithFormat:[self createGLPixelFormat] shareContext:sharedContext] autorelease];
            [view setOpenGLContext:newCtx];
            [newCtx setView:view];
            [view setup];
            [view reshape];
        }
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
    
    [self UpdatePopupMenu];
}


- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
    return YES;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    CVDisplayLinkStop( displayLink );
}


-(void)UpdatePopupMenu
{
    int i;
    NSArray* popuparray = @[ m_SyphonServers1, m_SyphonServers2, m_SyphonServers3, m_SyphonServers4 ];

    for ( NSPopUpButton* p in popuparray )
    {
        [p removeAllItems];
    }
    
    for ( NSDictionary* info in mSyphons )
    {
        for ( NSPopUpButton* p in popuparray )
        {
            [p addItemWithTitle:[info objectForKey:@"Name"]];
        }
    }
    
    i = 0;
    for ( GLView* view in mGLViews )
    {
        TL_INetTCPSyphonSDK_Client*    sdk = [view GetTCPSyphonSDKClient];
        if ( [[sdk GetConnectedTCPSyphonServerName] length] <= 0 )
        {
            if ( [mSyphons count] > 0 )
            {
                NSPopUpButton* p = popuparray[i];
                
                [sdk ConnectToTCPSyphonServerAtIndex:0];
                [p selectItemAtIndex:0];
            }
        }
        ++i;
    }
}


- (IBAction)ChangedSyphonServersPopup:(id)sender {
    NSInteger index = [sender tag];
    
    NSString*   selectedname = [sender titleOfSelectedItem];
    
    GLView* view = mGLViews[index];
    TL_INetTCPSyphonSDK_Client*    sdk = [view GetTCPSyphonSDKClient];
    [sdk ConnectToTCPSyphonServerByName:selectedname];    
}


- (void)OnNotify_ChangeTCPSyphonServerList:(NSNotification *)aNotification
{
    TL_INetTCPSyphonSDK_Client*    sdk = [aNotification object];
    
    NSArray*    servers = [sdk GetTCPSyphonServerInformation];
    if ( mSyphons != servers )
    {
        [mSyphons release];
        mSyphons = [servers retain];
    }
    
    [self UpdatePopupMenu];
}



- (void) renderCallback	{
    for ( GLView* view in mGLViews )
    {
        [view draw];
    }
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
