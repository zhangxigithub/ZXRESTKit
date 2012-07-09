//
//  ZXRESTKit.m
//  ZXRESTKit
//
//  Created by 张 玺 on 12-7-6.
//  Copyright (c) 2012年 张玺. All rights reserved.
//

#import "ZXRESTKit.h"

@implementation ZXRESTKit

@synthesize delegate;
@synthesize baseURL;



static ZXRESTKit *kit;

+(ZXRESTKit *)sharedKit
{
    if(kit == Nil) kit = [[ZXRESTKit alloc] init];
    return kit;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        // deserializer = [[CJSONDeserializer alloc] init];
        deserializer = [CJSONDeserializer deserializer];
    }
    
    
    
    return self;
}



#pragma -mark 使用baseURL的请求

-(void)get:(NSString *)operation withParams:(NSDictionary *)params
{
    [self get:operation withParams:params forNotification:Nil];
}
-(void)post:(NSString *)operation withParams:(NSDictionary *)params
{
    [self post:operation withParams:params forNotification:Nil];
}


-(void)get:(NSString *)operation withParams:(NSDictionary *)params forNotification:(NSString *)notification
{
    //根据baseURL拼接请求字符串
    NSString *urlStr = [baseURL stringByAppendingFormat:@"%@",operation];
   
    [self getWithURL:urlStr withParams:params forNotification:notification];
}

-(void)post:(NSString *)operation withParams:(NSDictionary *)params forNotification:(NSString *)notification
{
    NSString *urlStr = [baseURL stringByAppendingString:operation];
    [self postWithURL:urlStr withParams:params forNotification:notification];
}

#pragma -mark 不使用baseURL的请求

-(void)getWithURL:(NSString *)operation withParams:(NSDictionary *)params
{
    [self getWithURL:operation withParams:params forNotification:Nil];
}
-(void)postWithURL:(NSString *)operation withParams:(NSDictionary *)params
{
    [self postWithURL:operation withParams:params forNotification:Nil];
}
-(void)getWithURL:(NSString *)operation withParams:(NSDictionary *)params forNotification:(NSString *)notification
{
    NSString *paramStr = [self NSStirngFromNSDictionary:params];
    NSString *urlStr = [operation stringByAppendingFormat:@"/?%@",paramStr];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSLog(@"url:%@",[url absoluteString]);
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    request.delegate = self;
    request.requestMethod = @"GET";
    request.userInfo = params;
    request.notificationName = notification;
    [request startAsynchronous];
}
-(void)postWithURL:(NSString *)operation withParams:(NSDictionary *)params forNotification:(NSString *)notification
{
    NSURL *url = [NSURL URLWithString:operation];
    NSLog(@"url:%@",[url absoluteString]);
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    request.delegate = self;
    request.requestMethod = @"POST";
    request.userInfo = params;
    request.notificationName = notification;
    for(NSString *key in [params allKeys])
    {
        [request setPostValue:[params objectForKey:key] forKey:key];
    }
    
    [request startAsynchronous];
}









#pragma -mark ASIHTTPRequest Delegate

- (void)requestStarted:(ASIHTTPRequest *)request
{    
    
    if(request.notificationName != Nil)
    {
        NSString *name = [request.notificationName stringByAppendingFormat:@"Started"];
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:request];
    }
    else {
        id obj = delegate;
        if([obj respondsToSelector:@selector(zxRequestStarted:)])
            [delegate zxRequestStarted:request];
    }
}
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    if(request.notificationName != Nil)
    {
        NSString *name = [request.notificationName stringByAppendingFormat:@"Response"];
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:request];
    }
    else {
        id obj = delegate;
        if([obj respondsToSelector:@selector(zxRequest:didReceiveResponseHeaders:)])
            [delegate zxRequest:request didReceiveResponseHeaders:responseHeaders];
    }
}
- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL
{
    if(request.notificationName != Nil)
    {
        NSString *name = [request.notificationName stringByAppendingFormat:@"Redirect"];
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:request];
    }
    else {
        id obj = delegate;
        if([obj respondsToSelector:@selector(zxRequest:willRedirectToURL:)])
            [delegate zxRequest:request willRedirectToURL:newURL];
    }
}
- (void)requestFinished:(ASIHTTPRequest *)request
{

    NSError *error = Nil;
    if(request.responseData == Nil)
    {
        NSLog(@"NIL");
    }
    
    NSDictionary *result;
    
    @try {
        result = [deserializer deserializeAsDictionary:request.responseData error:&error];
        if(error != Nil)
        {
            NSLog(@"error:%@",error);
            //return ;
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"NSException : %@",[exception description]);
    }


    request.result  = result;

    
    
    
    if(request.notificationName != Nil)
    {
        NSString *name = [request.notificationName stringByAppendingFormat:@"Finished"];
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:request];
    }
    else {
        id obj = delegate;
        if([obj respondsToSelector:@selector(zxRequestFinished:)])
            [delegate zxRequestFinished:request];
    }
    
    
    
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(request.notificationName != Nil)
    {
        NSString *name = [request.notificationName stringByAppendingFormat:@"Failed"];
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:request];
    }
    else {
        id obj = delegate;
        if([obj respondsToSelector:@selector(zxRequestFailed:)])
            [delegate zxRequestFailed:request];
    }
}
- (void)requestRedirected:(ASIHTTPRequest *)request
{
    if(request.notificationName != Nil)
    {
        NSString *name = [request.notificationName stringByAppendingFormat:@"Redirected"];
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:request];
    }
    else {
        id obj = delegate;
        if([obj respondsToSelector:@selector(zxRequestRedirected:)])
            [delegate zxRequestRedirected:request];
    }
}






#pragma -mark Tools
-(NSString *)NSStirngFromNSDictionary:(NSDictionary *)dic
{
    ASIFormDataRequest *formDataRequest = [ASIFormDataRequest requestWithURL:nil]; 

    NSString *result = [[NSString alloc] init];
    
    for(NSString *key in [dic allKeys])
    {
        NSString *encodedValue = [formDataRequest encodeURL:[dic objectForKey:key]]; 
        result = [result stringByAppendingFormat:@"%@=%@&",key,encodedValue];
    }
    if(result.length > 0)
    {
        result = [result substringWithRange:NSMakeRange(0, result.length-1)];
    }
    //result = [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return result;
}


@end
