//
//  GLView.h
//  INetSyphon_OSX_SDK
//
//  Created by Nozomu MIURA on 2016/03/31.
//  Copyright © 2016年 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TL_INetSyphonSDK/TL_INetSyphonSDK.h"

@interface GLView : NSOpenGLView {
    BOOL                needsReshape;
    
    int                 shape_type;
    float               rotationRad;
    
    TL_INetTCPSyphonSDK_Server*    m_TCPSyphonSDKServer;
    GLuint                         m_SyphonCopyTexture;
}

-(void)setup:(NSString*)name type:(int)type;
-(void)draw;

@end
