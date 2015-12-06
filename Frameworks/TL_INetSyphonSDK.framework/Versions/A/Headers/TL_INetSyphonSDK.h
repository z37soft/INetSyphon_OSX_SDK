//
//  TL_INetSyphonSDK.h
//  TL_INetSyphonSDK
//
//  Created by Nozomu MIURA on 2015/10/27.
//  Copyright © 2015年 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/CGLMacro.h>

//! Project version number for TL_INetSyphonSDK.
FOUNDATION_EXPORT double TL_INetSyphonSDKVersionNumber;

//! Project version string for TL_INetSyphonSDK.
FOUNDATION_EXPORT const unsigned char TL_INetSyphonSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TL_INetSyphonSDK/PublicHeader.h>


typedef NS_ENUM(NSInteger, TCPUDPSyphonEncodeType)
{
    TCPUDPSyphonEncodeType_JPEG          = 0,
    TCPUDPSyphonEncodeType_JPEGGLITCH    = 1,
    TCPUDPSyphonEncodeType_RAW           = 2,
    TCPUDPSyphonEncodeType_PNG           = 3,
    TCPUDPSyphonEncodeType_TURBOJPEG     = 4,
};
typedef NS_ENUM(NSInteger, UDPMethodType)
{
    UDPMethodType_Normal        = 0,
    UDPMethodType_Multicast     = 1,
    UDPMethodType_Broadcast     = 2,
};

#import "TL_INetTCPSyphonSDK.h"
#import "TL_INetUDPSyphonSDK.h"


