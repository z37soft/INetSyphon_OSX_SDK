//
//  AppDelegate.m
//  SampleMultiTCPServer
//
//  Created by Nozomu MIURA on 2016/03/31.
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
    NSArray*    mGLViews;
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
    @synchronized (self)	{
        NSArray* viewarray = @[ glView1, glView2, glView3, glView4 ];
        mGLViews = [viewarray retain];
        
        int i;
        
        i = 0;
        for ( GLView* view in viewarray )
        {
            NSString* name;
            
            name = [NSString stringWithFormat:@"MultiTCPServer%d", i+1];
            
            NSOpenGLContext		*newCtx = [[[NSOpenGLContext alloc] initWithFormat:[self createGLPixelFormat] shareContext:sharedContext] autorelease];
            [view setOpenGLContext:newCtx];
            [newCtx setView:view];
            [view setup:name type:i+1];
            [view reshape];
            
            ++i;
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
}


- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
    return YES;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    CVDisplayLinkStop( displayLink );
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

@end
