//
//  TL_INetTCPSyphonSDK.h
//  TL_INetSyphonSDK
//
//  Created by Nozomu MIURA on 2015/10/27.
//  Copyright © 2015年 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TL_INetSyphonSDK.h"

#define TL_INetSyphonSDK_ChangeTCPSyphonServerListNotification   @"TL_INetSyphonSDK_ChangeTCPSyphonServerListNotification"


@interface TL_INetTCPSyphonSDK_Server : NSObject

//Control server
-(void)StartServer:(NSString*)appname;
-(void)StopServer;

//assign texture
//supports GL_RGBA, GL_UNSIGNED_BYTE and GL_TEXTURE_RECTANGLE_EXT only.
-(BOOL)SetSendImageByGLTexture:(CGLContextObj)cgl_ctx Texture:(GLuint)texture Width:(int)width Height:(int)height;
-(BOOL)SetSendImageByNSData:(NSData*)data Width:(int)width Height:(int)height;

//set parameters
//Default encode type: TCPUDPSyphon::EncodeType_TURBOJPEG
-(void)SetEncodeType:(TCPUDPSyphonEncodeType)encodetype;
//Default encode quality: 0.5 ( bad:0.0, good:1.0 )
-(void)SetEncodeQuality:(float)quality;
//If you want to set a fixed network port, then you should use this method. 0 is default(choose automatically).
-(void)SetRequestPort:(int)port;

//get information
-(NSDictionary*)GetSyphonServerInformation;
-(NSArray*)GetTCPSyphonClientInformation;
-(unsigned int)GetSendingDataSize;
-(NSString*)GetServerAverageFPS;

@end



@interface TL_INetTCPSyphonSDK_Client : NSObject

//Control client
-(void)StartClient;
-(void)StopClient:(CGLContextObj)cgl_ctx;

//Connect,Disconnect
-(void)ConnectToTCPSyphonServerAtIndex:(int)index;
-(int)ConnectToTCPSyphonServerByName:(NSString*)name;
-(void)DisconnectToTCPSyphonServer;
-(NSString*)GetConnectedTCPSyphonServerName;

-(NSString*)GetClientAverageFPS;

-(void)ClientIdle:(CGLContextObj)cgl_ctx;
-(int)GetReceiveTextureFromTCPSyphonServer:(GLuint*)texture Resolution:(NSSize*)texturesize TextureTarget:(GLenum*)texturetarget;

-(NSArray*)GetTCPSyphonServerInformation;

@end

