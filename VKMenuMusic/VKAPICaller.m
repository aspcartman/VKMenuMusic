//
//  VKAPICaller.m
//  VKMenuMusic
//
//  Created by ASPCartman on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VKAPICaller.h"
#import "SBJSON.h"

@implementation VKAPICaller
@synthesize accessTokenString,delegate;

-(void) getMusic{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.vkontakte.ru/method/audio.get?access_token=%@",accessTokenString]];
    NSURLRequest *urlrequest=[NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:urlrequest delegate:self];
   
}

-(void) searchMusic:(NSString *)searchParam{
    NSLog(@"Searching for %@",searchParam);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.vkontakte.ru/method/audio.search?q=%@&access_token=%@",[searchParam stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],accessTokenString]];
    NSLog(@"URL is: %@",url);
    NSURLRequest *urlrequest=[NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:urlrequest delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *responce = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [[responce JSONValue] valueForKey:@"response"];
    NSLog(@"Did recieve data: %@",array);
    if ([delegate respondsToSelector:@selector(gotList:)]){
        [delegate gotList:array];
    }
}

- (void)dealloc
{
    [super dealloc];
}

@end
