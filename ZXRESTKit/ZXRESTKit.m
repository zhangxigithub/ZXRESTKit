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
#pragma -mark Method

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
    NSString *paramStr = [self NSStirngFromNSDictionary:params];
    
    NSURL *url = [NSURL URLWithString:[baseURL stringByAppendingFormat:@"%@/?%@",operation,paramStr]];
    NSLog(@"url:%@",[url absoluteString]);
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    request.delegate = self;
    request.requestMethod = @"GET";
    request.userInfo = params;
    request.notificationName = notification;
    [request startAsynchronous];
}

-(void)post:(NSString *)operation withParams:(NSDictionary *)params forNotification:(NSString *)notification
{
    NSURL *url = [NSURL URLWithString:[baseURL stringByAppendingString:operation]];
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
    
    NSDictionary *result = [deserializer deserializeAsDictionary:request.responseData error:&error];
    if(error != Nil)
    {
        NSLog(@"%@",[error description]);
        //return ;
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
    NSString *result = [[NSString alloc] init];
    
    for(NSString *key in [dic allKeys])
    {
        result = [result stringByAppendingFormat:@"%@=%@&",key,[dic objectForKey:key]];
    }
    if(result.length > 0)
    {
        result = [result substringWithRange:NSMakeRange(0, result.length-1)];
    }
    result = [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return result;
}


@end
