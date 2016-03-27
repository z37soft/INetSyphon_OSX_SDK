//
//  GLView.h
//  INetSyphon_OSX_SDK
//
//  Created by Nozomu MIURA on 2015/12/06.
//  Copyright © 2015 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TL_INetSyphonSDK/TL_INetSyphonSDK.h"

@interface GLView : NSOpenGLView {
    BOOL                needsReshape;
    
    float               rotationRad;
    
    TL_INetTCPSyphonSDK_Server*    m_TCPSyphonSDKServer;
    GLuint                         m_SyphonCopyTexture;
}

-(void)setup;
-(void)draw;

@end
