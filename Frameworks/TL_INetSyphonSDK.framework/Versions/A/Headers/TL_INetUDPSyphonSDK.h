//
//  TL_INetUDPSyphonSDK.h
//  TL_INetSyphonSDK
//
//  Created by Nozomu MIURA on 2015/10/27.
//  Copyright © 2015年 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TL_INetSyphonSDK.h"


@interface TL_INetUDPSyphonSDK : NSObject

-(NSArray*)QueryNetworkInterface;

@end


@interface TL_INetUDPSyphonSDK_Server : TL_INetUDPSyphonSDK

//set parameters
//Default encode type: TCPUDPSyphon::EncodeType_TURBOJPEG
-(void)SetEncodeType:(TCPUDPSyphonEncodeType)encodetype;
//Default encode quality: 0.5 ( bad:0.0, good:1.0 )
-(void)SetEncodeQuality:(float)quality;

//Control server
-(void)StartServer:(UDPMethodType)type IPAddress:(NSString*)ip Port:(NSUInteger)port SourceIPAddress:(NSString*)sourceIPAddress;
-(void)StopServer;

//assign texture
-(BOOL)SetSendImageByGLTexture:(CGLContextObj)cgl_ctx Texture:(GLuint)texture Width:(int)width Height:(int)height;
-(BOOL)SetSendImageByNSData:(NSData*)data Width:(int)width Height:(int)height;

-(void)SetServerRequestFPS:(int)fps;

//get information
-(NSString*)GetServerAverageFPS;
-(unsigned int)GetServerSendingDataSize;

@end


@interface TL_INetUDPSyphonSDK_Client : TL_INetUDPSyphonSDK

//Control client
-(void)StartClient:(CGLContextObj)cgl_ctx Port:(NSUInteger)port MulticastGroup:(NSString*)multicastgroup SourceIPAddress:(NSString*)sourceIPAddress;
-(void)StopClient:(CGLContextObj)cgl_ctx;

-(void)ClientIdle:(CGLContextObj)cgl_ctx;
-(int)GetReceiveTextureFromUDPSyphonServer:(GLuint*)texture Resolution:(CGSize*)texturesize TextureTarget:(GLenum*)texturetarget;

//get information
-(NSString*)GetClientAverageFPS;
-(unsigned int)GetClientDropFrameCounter;

@end
