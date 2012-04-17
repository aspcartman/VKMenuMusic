//
//  VKMenuMusicAppDelegate.h
//  VKMenuMusic
//
//  Created by ASPCartman on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "JGMenuWindowController.h"
#import "VKAPICaller.h"
@class AudioStreamer;
@interface VKMenuMusicAppDelegate : NSObject <NSApplicationDelegate,JGMenuWindowDelegate> {
@private
    NSWindow *window;
    IBOutlet WebView *authBrowserWindow;
    IBOutlet NSView *customView;
    IBOutlet NSSlider *progressSlider;
    NSTimer *progressUpdateTimer;
    VKAPICaller *caller;
    JGMenuWindowController *menuController;
    AudioStreamer *streamer;
    NSArray *list;
    NSString *lastSearchQ;
    IBOutlet NSProgressIndicator *loadingSpin;
    IBOutlet NSTextField *artistLabel;
    IBOutlet NSTextField *songLabel;
    IBOutlet NSSlider *volumeSlider;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *authBrowserWindow;


- (void)play:(NSInteger) row;
- (IBAction)stop:(id)sender;
- (IBAction)sliderMoved:(NSSlider *)aSlider;
- (IBAction)pause:(id)sender;
- (IBAction)volumeSliderMoved:(NSSlider*)slider;
- (IBAction)exit:(id)sender;

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame;
-(void) gotList:(NSArray *)_list;
- (void)createStreamerForURL:(NSURL*)url;
- (void)destroyStreamer;
@end
