/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

#import "WXVideoComponent.h"
#import "WXHandlerFactory.h"
#import "WXURLRewriteProtocol.h"
#import "WXSDKEngine.h"

#import <AVFoundation/AVPlayer.h>
#import <AVKit/AVPlayerViewController.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import <AVFoundation/AVPlayerItem.h>

@interface WXPlayer : NSObject

@end

@implementation WXPlayer

@end

@interface WXVideoView()

@property (nonatomic, strong) UIViewController* playerViewController;
@property (nonatomic, strong) AVPlayerItem* playerItem;
@property (nonatomic, strong) WXSDKInstance* weexSDKInstance;

@end

@implementation WXVideoView

- (id)init
{
    if (self = [super init]) {
        if ([self greater8SysVer]) {
            _playerViewController = [AVPlayerViewController new];
            
        } else {
            _playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:nil];
            MPMoviePlayerViewController *MPVC = (MPMoviePlayerViewController*)_playerViewController;
            MPVC.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
            MPVC.moviePlayer.shouldAutoplay = NO;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playFinish)
                                                         name:MPMoviePlayerPlaybackDidFinishNotification
                                                       object:MPVC.moviePlayer];
            [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerPlaybackStateDidChangeNotification object:MPVC.moviePlayer queue:nil usingBlock:^(NSNotification *notification)
             {
                 if (MPVC.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
                     if (_playbackStateChanged)
                         _playbackStateChanged(WXPlaybackStatePlaying);
                 }
                 if (MPVC.moviePlayer.playbackState == MPMoviePlaybackStateStopped) {
                     //stopped
                 } if (MPVC.moviePlayer.playbackState == MPMoviePlaybackStatePaused) {
                     //paused
                     if (_playbackStateChanged) {
                         _playbackStateChanged(WXPlaybackStatePaused);
                     }
                 } if (MPVC.moviePlayer.playbackState == MPMoviePlaybackStateInterrupted) {
                     //interrupted
                 } if (MPVC.moviePlayer.playbackState == MPMoviePlaybackStateSeekingForward) {
                     //seeking forward
                 } if (MPVC.moviePlayer.playbackState == MPMoviePlaybackStateSeekingBackward) {
                     //seeking backward
                 }
             }];
        }
        
        [self addSubview:_playerViewController.view];
    }
    return self;
}

- (void)dealloc
{
    _weexSDKInstance = nil;
    if ([self greater8SysVer]) {
        AVPlayerViewController *AVVC = (AVPlayerViewController*)_playerViewController;
        [AVVC.player removeObserver:self forKeyPath:@"rate"];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object: _playerItem];
    }
    else {
        MPMoviePlayerViewController *MPVC = (MPMoviePlayerViewController*)_playerViewController;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:MPVC.moviePlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:MPVC.moviePlayer];
    }
}

- (BOOL)greater8SysVer
{
    //return NO;
    NSString *reqSysVer = @"8.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    return [currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"rate"]) {
        float rate = [change[NSKeyValueChangeNewKey] floatValue];
        if (rate == 0.0) {
            if (_playbackStateChanged)
                _playbackStateChanged(WXPlaybackStatePaused);
        } else if (rate == 1.0) {
            if (_playbackStateChanged)
                _playbackStateChanged(WXPlaybackStatePlaying);
        } else if (rate == -1.0) {
            // Reverse playback
        }
    } else if ([keyPath isEqualToString:@"status"]) {
        NSInteger status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerStatusFailed) {
            if (_playbackStateChanged)
                _playbackStateChanged(WXPlaybackStateFailed);
        }
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGRect videoFrame = frame;
    videoFrame.origin.x = 0;
    videoFrame.origin.y = 0;
    [_playerViewController.view setFrame:videoFrame];
}

- (void)setURL:(NSURL *)URL
{
    NSString *newURL = [URL.absoluteString copy];
    WX_REWRITE_URL(URL.absoluteString, WXResourceTypeVideo, self.weexSDKInstance)
    
    if (!newURL) {
        return;
    }
    NSURL *videoNewURL = [NSURL URLWithString:newURL];
    if ([self greater8SysVer]) {
        
        AVPlayerViewController *AVVC = (AVPlayerViewController*)_playerViewController;
        if (AVVC.player && _playerItem) {
            [_playerItem removeObserver:self forKeyPath:@"status"];
            [AVVC.player removeObserver:self forKeyPath:@"rate"];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object: _playerItem];
        }
        _playerItem = [[AVPlayerItem alloc] initWithURL:videoNewURL];
        AVPlayer *player = [AVPlayer playerWithPlayerItem: _playerItem];
        AVVC.player = player;
        
        [player addObserver:self
                 forKeyPath:@"rate"
                    options:NSKeyValueObservingOptionNew
                    context:NULL];
        
        [_playerItem addObserver:self
                     forKeyPath:@"status"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish) name:AVPlayerItemDidPlayToEndTimeNotification object: _playerItem];
    }
    else {
        MPMoviePlayerViewController *MPVC = (MPMoviePlayerViewController*)_playerViewController;
        [MPVC moviePlayer].contentURL = videoNewURL;
    }
}

- (void)playFinish
{
    if (_playbackStateChanged)
        _playbackStateChanged(WXPlaybackStatePlayFinish);
    if ([self greater8SysVer]) {
        AVPlayerViewController *AVVC = (AVPlayerViewController*)_playerViewController;
        [[AVVC player] seekToTime:CMTimeMultiply([AVVC player].currentTime, 0)];
    } else {
        MPMoviePlayerViewController *MPVC = (MPMoviePlayerViewController*)_playerViewController;
        [[MPVC moviePlayer] stop];
    }
}

- (void)play
{
    if ([self greater8SysVer]) {
        AVPlayerViewController *AVVC = (AVPlayerViewController*)_playerViewController;

        [[AVVC player] play];
    } else {
        MPMoviePlayerViewController *MPVC = (MPMoviePlayerViewController*)_playerViewController;
        [[MPVC moviePlayer] play];
    }
}

- (void)pause
{
    if ([self greater8SysVer]) {
        AVPlayerViewController *AVVC = (AVPlayerViewController*)_playerViewController;
        [[AVVC player] pause];
    } else {
        MPMoviePlayerViewController *MPVC = (MPMoviePlayerViewController*)_playerViewController;
        [[MPVC moviePlayer] pause];
    }
}

@end

@interface WXVideoComponent()

@property (nonatomic, weak) WXVideoView *videoView;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic) BOOL autoPlay;
@property (nonatomic) BOOL playStatus;

@end

@implementation WXVideoComponent

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance {
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {
        if (attributes[@"src"]) {
            _videoURL = [NSURL URLWithString: attributes[@"src"]];
        }
        if (attributes[@"autoPlay"]) {
            _autoPlay = [attributes[@"autoPlay"] boolValue];
        }
        if ([attributes[@"playStatus"] compare:@"play" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            _playStatus = true;
        }
        if ([attributes[@"playStatus"] compare:@"pause" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            _playStatus = false;
        }
    }
    return self;
}

-(UIView *)loadView
{
    WXVideoView* videoView = [[WXVideoView alloc] init];
    videoView.weexSDKInstance = self.weexInstance;
    
    return videoView;
}

-(void)viewDidLoad
{
    _videoView = (WXVideoView *)self.view;
    [_videoView setURL:_videoURL];
    if (_playStatus) {
        [_videoView play];
    } else {
        [_videoView pause];
    }
    if (_autoPlay) {
        [_videoView play];
    }
    __weak __typeof__(self) weakSelf = self;
    _videoView.playbackStateChanged = ^(WXPlaybackState state) {
        NSString *eventType = nil;
        switch (state) {
            case WXPlaybackStatePlaying:
                eventType = @"start";
                break;
            case WXPlaybackStatePaused:
                eventType = @"pause";
                break;
            case WXPlaybackStatePlayFinish:
                eventType = @"finish";
                break;
            case WXPlaybackStateFailed:
                eventType = @"fail";
                break;
                
            default:
                NSCAssert(NO, @"");
                break;
        }
        [weakSelf fireEvent:eventType params:nil];
    };
}

-(void)updateAttributes:(NSDictionary *)attributes
{
    if (attributes[@"src"]) {
        _videoURL = [NSURL URLWithString: attributes[@"src"]];
        [_videoView setURL:_videoURL];
    }
    if (attributes[@"autoPlay"]) {
        _autoPlay = [attributes[@"autoPlay"] boolValue];
        [_videoView play];
    }
    if ([attributes[@"playStatus"] compare:@"play" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        _playStatus = true;
        [_videoView play];
    }
    if ([attributes[@"playStatus"] compare:@"pause" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        _playStatus = false;
        [_videoView pause];
    }
}

@end
