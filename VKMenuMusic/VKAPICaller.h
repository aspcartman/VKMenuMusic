//
//  VKAPICaller.h
//  VKMenuMusic
//
//  Created by ASPCartman on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VKAPICaller : NSObject  {
    NSString *accessTokenString;
    NSMutableData *recieviedData;
    id delegate;
}
@property (retain) NSString *accessTokenString;
@property (assign) id delegate;
-(void) getMusic;
-(void) searchMusic:(NSString *)searchParam;

@end
