//
//  KKAudioLongPressListener.m
//  KKShopping
//
//  Created by nice on 16/8/24.
//  Copyright © 2016年 nice. All rights reserved.
//

#import "KKAudioLongPressListener.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFAudio.h>
#define defaultCenterPostNotification(notificationName) [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil]

const NSTimeInterval longPressNeedContinuationMinTimerInterval = 0.15f;
const NSTimeInterval longPressNeedRecognizeMinTimerInterval = 0.8f;

NSString *const KKAudioShortClickNotification = @"KKAudioShortClickNotification";
NSString *const KKAudioLongPressStartNotification = @"KKAudioLongPressStartNotification";
NSString *const KKAudioLongPressEndNotification = @"KKAudioLongPressEndNotification";

@interface KKAudioLongPressListener(){
    NSDate *_lastLongPressDate;
    BOOL _effectiveClick;
}

@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, weak)   NSTimer *activeTimer;
@property (nonatomic, weak)   NSTimer *longPressEndTimer;

@end

@implementation KKAudioLongPressListener

static KKAudioLongPressListener *_longPressListen;

+ (void)beginListen
{
    _longPressListen = [[KKAudioLongPressListener alloc] init];
    [[UIApplication sharedApplication].keyWindow addSubview:_longPressListen];
}

+ (void)stopListen
{
    [_longPressListen removeAllAudioListen];
    [_longPressListen reset];
    [_longPressListen removeFromSuperview];
    _longPressListen = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.volumeView];
        [self regVolumeActive:YES];
        [self addApplicationStatusListen];
    }
    return self;
}

- (MPVolumeView *)volumeView
{
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-500, 0, 1, 1)];
    }
    return _volumeView;
}

#pragma mark - audioListenValueChange

- (void)volumeChanged:(NSNotification *)notification
{
    NSString *str1 = [[notification userInfo]objectForKey:@"AVSystemController_AudioCategoryNotificationParameter"];
    NSString *str2 = [[notification userInfo]objectForKey:@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
    
    if (([str1 isEqualToString:@"Audio/Video"] || [str1 isEqualToString:@"Ringtone"]) && ([str2 isEqualToString:@"ExplicitVolumeChange"]))
    {
        NSDate *now = [NSDate date];
        if (!_lastLongPressDate) {
            _lastLongPressDate = now;
            if (!self.activeTimer) {
                self.activeTimer = [NSTimer scheduledTimerWithTimeInterval:longPressNeedRecognizeMinTimerInterval target:self selector:@selector(check) userInfo:nil repeats:NO];
            }
            return;
        }
        NSTimeInterval interval = [now timeIntervalSinceDate:_lastLongPressDate];
        _lastLongPressDate = now;
        NSLog(@"------------------------------>%f",interval);
        
        
        //前一次识别为长按,但本次间隔时间过长,则让长按识别自动结束
        if (interval > longPressNeedContinuationMinTimerInterval && _effectiveClick) {
            _effectiveClick = NO;
            return;
        }

        //两次按键间隔小于长按所需间隔即为连续长按
        if (interval < longPressNeedContinuationMinTimerInterval) {
            _effectiveClick = YES;
            self.longPressEndTimer = [NSTimer scheduledTimerWithTimeInterval:longPressNeedContinuationMinTimerInterval target:self selector:@selector(endLongPress) userInfo:nil repeats:NO];
        }else{  //短按
            _effectiveClick = NO;
            if (!self.activeTimer) {
                self.activeTimer = [NSTimer scheduledTimerWithTimeInterval:longPressNeedRecognizeMinTimerInterval target:self selector:@selector(check) userInfo:nil repeats:NO];
            }
        }
    }
}

- (void)setLongPressEndTimer:(NSTimer *)longPressEndTimer
{
    if (_longPressEndTimer) {
        [_longPressEndTimer invalidate];
        _longPressEndTimer = nil;
    }
    _longPressEndTimer = longPressEndTimer;
    
    if (_longPressEndTimer) {
        [[NSRunLoop mainRunLoop] addTimer:_longPressEndTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)check
{
    if (_effectiveClick) {
        NSLog(@"音量键-----------------------------长按开始");
        defaultCenterPostNotification(KKAudioLongPressStartNotification);
    }else{
        NSLog(@"音量键-----------------------------短按");
        defaultCenterPostNotification(KKAudioShortClickNotification);
        self.longPressEndTimer = nil;
    }
    [self reset];
}

- (void)endLongPress
{
    NSLog(@"音量键-----------------------------长按结束");
    defaultCenterPostNotification(KKAudioLongPressEndNotification);
    self.longPressEndTimer = nil;
    [self reset];
}

- (void)reset
{
    [self.activeTimer invalidate];
    self.activeTimer = nil;
    _effectiveClick = NO;
}

#pragma mark - notification

- (void)didEnterBackground:(NSNotification *)noti
{
    [self regVolumeActive:NO];
}

- (void)willReturnToForeground:(NSNotification *)noti
{
    [self regVolumeActive:YES];
}

- (void)willResignActive:(NSNotification *)noti
{
    [self regVolumeActive:NO];
}

- (void)didBecomeActive:(NSNotification *)noti
{
    [self regVolumeActive:YES];
}

- (void)regVolumeActive:(BOOL)isActive
{
    NSError *activeError;
    [[AVAudioSession sharedInstance] setActive:isActive error:&activeError];
    
    if (!activeError) {
        if (isActive) {
            [self addVolumeListen];
        }else{
            [self removeVolumeListen];
        }
    }
}

#pragma mark - add || remove Listen

- (void)removeVolumeListen
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                  object:nil];
}

- (void)addVolumeListen
{
    [self removeVolumeListen];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)
                                                 name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
}

- (void)addApplicationStatusListen
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willReturnToForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)removeAllAudioListen
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
