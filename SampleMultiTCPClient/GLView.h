//
//  GLView.h
//  INetSyphon_OSX_SDK
//
//  Created by Nozomu MIURA on 2016/04/04.
//  Copyright © 2016年 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TL_INetSyphonSDK/TL_INetSyphonSDK.h"

@interface GLView : NSOpenGLView
{
    BOOL                            m_NeedsReshape;
    
    TL_INetTCPSyphonSDK_Client*     m_TCPSyphonSDKClient;
}

-(void)setup;
-(void)draw;

-(TL_INetTCPSyphonSDK_Client*)GetTCPSyphonSDKClient;

@end
