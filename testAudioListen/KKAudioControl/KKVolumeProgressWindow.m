//
//  KKVolumeView.m
//
//  Created by nice on 16/7/19.
//  Copyright © 2016年 kk. All rights reserved.
//

#import "KKVolumeProgressWindow.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFAudio.h>

const CGFloat height = 2;
const CGFloat StatusHeight = 20;
const CGFloat SidePadding = 10;

@interface KKVolumeProgressWindow(){
    CGFloat _lastOldVolume;
}

@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *backColorView;
@property (nonatomic, strong) UIView *BGView;
@property (nonatomic, assign) CGFloat volumeLevel;

@end

@implementation KKVolumeProgressWindow

- (void)dealloc
{
    [self removeAllAudioListen];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

#pragma mark - default

+ (instancetype)defaultVolumeView
{
    KKVolumeProgressWindow *volume = [[KKVolumeProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    volume.frame = CGRectMake(0, 0, volume.frame.size.width, StatusHeight);
    volume.animationType = KKVolumeViewAnimationFade;
    volume.progressBarTintColor = [UIColor blackColor];
    volume.progressBarBackgroundColor = [UIColor whiteColor];
    volume.volumeStatusBackgroundColor = [UIColor lightGrayColor];
    return volume;
}

- (void)setup
{
    [self regVolumeActive:YES];
    
    self.backgroundColor   = [UIColor clearColor];
    self.windowLevel = UIWindowLevelStatusBar + 10.0f;
    self.userInteractionEnabled = NO;
    self.rootViewController = [[UIViewController alloc] init];
    self.rootViewController.view.backgroundColor = [UIColor clearColor];
    
    [self.volumeView setVolumeThumbImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    self.volumeView.showsRouteButton = NO;
    self.BGView.backgroundColor = self.volumeStatusBackgroundColor?self.volumeStatusBackgroundColor : [UIColor whiteColor];
    self.backColorView.backgroundColor = self.progressBarBackgroundColor?self.progressBarBackgroundColor : [UIColor blackColor];
    self.overlayView.backgroundColor = self.progressBarTintColor?self.progressBarTintColor : [UIColor grayColor];
    
    [self addApplicationStatusListen];
    [self updateVolume:[AVAudioSession sharedInstance].outputVolume animated:NO];
}

#pragma mark - ui

- (CGFloat)maxWidth
{
    static CGFloat maxWidth = 0;
    if (maxWidth == 0) {
        maxWidth = [UIScreen mainScreen].bounds.size.width - SidePadding * 2;
    }
    return maxWidth;
}

- (MPVolumeView *)volumeView
{
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectZero];
        [self.rootViewController.view addSubview:_volumeView];
    }
    return _volumeView;
}

- (UIView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[UIView alloc] initWithFrame:self.backColorView.bounds];
        [self.backColorView addSubview:_overlayView];
    }
    return _overlayView;
}

- (UIView *)backColorView
{
    if (!_backColorView) {
        _backColorView = [[UIView alloc] initWithFrame:CGRectMake(SidePadding, (StatusHeight - height) * 0.5, [self maxWidth], height)];
        [self.BGView addSubview:_backColorView];
    }
    return _backColorView;
}

- (UIView *)BGView
{
    if (!_BGView) {
        _BGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, StatusHeight)];
        [self.rootViewController.view addSubview:_BGView];
        _BGView.transform = CGAffineTransformMakeTranslation(0, -StatusHeight);
    }
    return _BGView;
}

- (void)setAnimationType:(KKVolumeViewAnimation)animationType
{
    _animationType = animationType;
    [self updateVolume:self.volumeLevel animated:NO];
}

- (void)setProgressBarTintColor:(UIColor *)progressBarTintColor
{
    _progressBarTintColor = progressBarTintColor;
    self.overlayView.backgroundColor = progressBarTintColor;
}

- (void)setProgressBarBackgroundColor:(UIColor *)progressBarBackgroundColor
{
    _progressBarBackgroundColor = progressBarBackgroundColor;
    self.backColorView.backgroundColor = progressBarBackgroundColor;
}

- (void)setVolumeStatusBackgroundColor:(UIColor *)volumeStatusBackgroundColor
{
    _volumeStatusBackgroundColor = volumeStatusBackgroundColor;
    self.BGView.backgroundColor = volumeStatusBackgroundColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateVolumeViewWidth];
}

- (void)updateVolumeViewWidth
{
    CGRect rect = self.overlayView.frame;
    rect = CGRectMake(rect.origin.x, rect.origin.y, [self maxWidth] * self.volumeLevel, rect.size.height);
    self.overlayView.frame = rect;
}

#pragma mark - method

- (void)updateVolume:(CGFloat)volumeLevel animated:(BOOL)animated{
    
    if ([self.delegate respondsToSelector:@selector(volumeView:willChangeValue:oldValue:)]) {
        [self.delegate volumeView:self willChangeValue:volumeLevel oldValue:self.volumeLevel];
    }
    _lastOldVolume = self.volumeLevel;
    self.volumeLevel = volumeLevel;
    
    [UIView animateWithDuration:animated?0.1:0 animations:^{
        [self updateVolumeViewWidth];
    }];
    
    [UIView animateKeyframesWithDuration:animated ? 2 : 0 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0 animations:^{
            switch (self.animationType) {
                case KKVolumeViewAnimationNone:
                    break;
                case KKVolumeViewAnimationFade:
                    self.alpha = 1;
                case KKVolumeViewAnimationSlideDown:
                    self.BGView.transform = CGAffineTransformIdentity;
                    break;
            }
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
            switch (self.animationType) {
                case KKVolumeViewAnimationNone:
                    break;
                case KKVolumeViewAnimationFade:
                    self.alpha = 0.0001;
                    break;
                case KKVolumeViewAnimationSlideDown:
                    self.BGView.transform = CGAffineTransformMakeTranslation(0, -StatusHeight);
                    break;
            }
        }];
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(volumeView:didChangeValue:oldValue:)]) {
            [self.delegate volumeView:self didChangeValue:volumeLevel oldValue:_lastOldVolume];
        }
    }];
}

#pragma mark - audioListenValueChange

- (void)volumeChanged:(NSNotification *)notification
{
    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    
    NSString *str1 = [[notification userInfo]objectForKey:@"AVSystemController_AudioCategoryNotificationParameter"];
    NSString *str2 = [[notification userInfo]objectForKey:@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
    
    if (([str1 isEqualToString:@"Audio/Video"] || [str1 isEqualToString:@"Ringtone"]) && ([str2 isEqualToString:@"ExplicitVolumeChange"]))
    {
        [self updateVolume:volume animated:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == [AVAudioSession sharedInstance] && [keyPath isEqualToString:@"outputVolume"]) {
        float new = [change[@"new"] floatValue];
        
        [self updateVolume:new animated:YES];
    }
}

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
    NSError *activeError,*categoryError;
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
//                                     withOptions:AVAudioSessionCategoryOptionMixWithOthers
//                                           error:&categoryError];
//    [[AVAudioSession sharedInstance] setActive:isActive error:&activeError];
    
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
