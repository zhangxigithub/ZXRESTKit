//
//  ZXRESTKit.h
//  ZXRESTKit
//
//  Created by 张 玺 on 12-7-6.
//  Copyright (c) 2012年 张玺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"




@protocol ZXRESTKitDelegate


@optional

- (void)zxRequestStarted:(ASIHTTPRequest *)request;
- (void)zxRequest:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders;
- (void)zxRequest:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL;
- (void)zxRequestFinished:(ASIHTTPRequest *)request;
- (void)zxRequestFailed:(ASIHTTPRequest *)request;
- (void)zxRequestRedirected:(ASIHTTPRequest *)request;

@end




@interface ZXRESTKit : NSObject<ASIHTTPRequestDelegate>
{
    CJSONDeserializer *deserializer;
    id<ZXRESTKitDelegate> __unsafe_unretained delegate;
}
@property(unsafe_unretained)id<ZXRESTKitDelegate> delegate;

@property(nonatomic,strong) NSString *baseURL;




//获取到数据之后返回给delegate
-(void)get:(NSString *)operation withParams:(NSDictionary *)params;
-(void)post:(NSString *)operation withParams:(NSDictionary *)params;




//获取到数据之后发送notification通知
//修改ASIHTTPRequest ，添加一个notificationName 属性，返回时判断如果不为空，则发送通知，不在调用delegate。

-(void)get:(NSString *)operation withParams:(NSDictionary *)params forNotification:(NSString *)notification;
-(void)post:(NSString *)operation withParams:(NSDictionary *)params forNotification:(NSString *)notification;



//不通过baseURL 直接请求完整的地址，方便临时性拼接URL请求

-(void)getWithURL:(NSString *)operation withParams:(NSDictionary *)params;
-(void)postWithURL:(NSString *)operation withParams:(NSDictionary *)params;
-(void)getWithURL:(NSString *)operation withParams:(NSDictionary *)params forNotification:(NSString *)notification;
-(void)postWithURL:(NSString *)operation withParams:(NSDictionary *)params forNotification:(NSString *)notification;


+(ZXRESTKit *)sharedKit;


//Tools

-(NSString *)NSStirngFromNSDictionary:(NSDictionary *)dic;


@end








