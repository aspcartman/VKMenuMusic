//
//  VKMenuMusicAppDelegate.m
//  VKMenuMusic
//
//  Created by ASPCartman on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VKMenuMusicAppDelegate.h"
#import "AudioStreamer.h"

@implementation VKMenuMusicAppDelegate

@synthesize window,authBrowserWindow;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSURL *url = [NSURL URLWithString:@"http://api.vkontakte.ru/oauth/authorize?client_id=2377146&scope=friends,audio&redirect_uri=http://api.vkontakte.ru/blank.html&display=popup&response_type=token"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[authBrowserWindow mainFrame] loadRequest:request];
    menuController = [[[JGMenuWindowController alloc] initWithWindowNibName:@"JGMenuWindow"] retain];
    [menuController setHeaderView:customView];
	[menuController setMenuDelegate:self];
	[menuController setStatusItemTitle:@"V"];
  //  menuController.proMode=TRUE;
    

}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
    NSRange accessTokenStartRange=[[sender mainFrameURL] rangeOfString:@"access_token="];
    if (accessTokenStartRange.length>0) {
        
        NSString *accessToken=[[sender mainFrameURL] stringByReplacingCharactersInRange:NSMakeRange(0, accessTokenStartRange.location+accessTokenStartRange.length)
                                                                             withString:@""];
        NSRange accessTokenEndRange=[accessToken rangeOfString:@"&expires_in="];
        accessToken=[accessToken stringByReplacingCharactersInRange:NSMakeRange(accessTokenEndRange.location,[accessToken length]-accessTokenEndRange.location)
                                                         withString:@""];
        NSLog(@"Got accessToken=%@",accessToken);
        caller = [[VKAPICaller alloc] init];
        caller.accessTokenString=accessToken;
        caller.delegate=self;
        
        [caller getMusic];
        lastSearchQ=@"";
        [window close];
    }
}

-(void) gotList:(NSArray *)_list{
    list=[_list retain];
    NSMutableArray *menuItems = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dict in list) {
        if ([dict isKindOfClass:[NSDictionary class]]){
        [menuItems addObject:
         [[JGMenuItem alloc]initWithTitle:[NSString stringWithFormat:@"%@ - %@",
                                           [dict objectForKey:@"artist"],
                                           [dict objectForKey:@"title"]]
                                   target:self 
                                   action:@selector(play:)]];
        }
    }
    [menuController setMenuItems:menuItems];
}

-(void)play:(NSInteger) row{
    if ([lastSearchQ compare:@""]!=0)
    row+=1;
    [self createStreamerForURL:[NSURL URLWithString:[[list objectAtIndex:row]valueForKey:@"url"]]];
    
    [artistLabel setStringValue:[[list objectAtIndex:row] valueForKey:@"artist"]];
    [songLabel setStringValue:[[list objectAtIndex:row] valueForKey:@"title"]];
    NSPasteboard *clipboard = [NSPasteboard generalPasteboard];
    [clipboard clearContents];
    [clipboard setString:[[list objectAtIndex:row]valueForKey:@"url"] forType:NSPasteboardTypeString];
}



#pragma mark NSControlTextEditingDelegate

-(void)controlTextDidEndEditing:(NSNotification *)obj{
    NSString *searchQ=[(NSTextField*)[obj valueForKey:@"object"] stringValue];
    if ([searchQ compare:lastSearchQ]!=0){
        if ([searchQ compare:@""]!=0){
            [caller searchMusic: searchQ];
        }else [caller getMusic];
    }
    lastSearchQ=searchQ;
}

#pragma mark Streamer Shit
//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamerForURL:(NSURL*)url
{
    
	[self destroyStreamer];
	
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
	[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:streamer];
    progressUpdateTimer =
    [NSTimer
     scheduledTimerWithTimeInterval:0.1
     target:self
     selector:@selector(updateProgress:)
     userInfo:nil
     repeats:YES];
    [loadingSpin startAnimation:self];
    [streamer start];
    
}
//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];
		[loadingSpin stopAnimation:self];
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}


- (void)volumeSliderMoved:(NSSlider*)slider{
    if (streamer){
        [streamer setGain:[slider floatValue]];
    }
}

- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		[loadingSpin startAnimation:self];
	}
	else if ([streamer isPlaying])
	{
        [streamer setGain:[volumeSlider floatValue]];
		[loadingSpin stopAnimation:self];
	}
	else if ([streamer isIdle])
	{
		[self destroyStreamer];
		
	}
}

- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
		
		if (duration > 0)
		{
			
			[progressSlider setEnabled:YES];
			[progressSlider setDoubleValue:100 * progress / duration];
		}
		else
		{
			[progressSlider setEnabled:NO];
		}
	}
}

- (IBAction)sliderMoved:(NSSlider *)aSlider
{
	if (streamer.duration)
	{
		double newSeekTime = ([aSlider doubleValue] / 100.0) * streamer.duration;
		[streamer seekToTime:newSeekTime];
	}
}


- (IBAction)pause:(id)sender {
    if ([streamer isPlaying]){
        [streamer pause];
    }else if([streamer isPaused]){
        [streamer start];
    }
}
- (IBAction)stop:(id)sender{
    [streamer stop];
    [self destroyStreamer];
}

@end
