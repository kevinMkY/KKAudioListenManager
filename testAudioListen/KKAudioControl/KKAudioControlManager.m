//
//  KKAudioControlManager.m
//
//  Created by nice on 16/7/19.
//  Copyright © 2016年 kk. All rights reserved.
//

#import "KKAudioControlManager.h"
#import "KKVolumeProgressWindow.h"
#import "KKMuteSwitchListener.h"

#define defaultCenter [NSNotificationCenter defaultCenter]

NSString * const KKAudioControlVolumeBiggerNotification  = @"KKAudioControlVolumeBiggerNotification";
NSString * const KKAudioControlVolumeSmallerNotification = @"KKAudioControlVolumeSmallerNotification";
NSString * const KKAudioControlMuteTurnOnNotification    = @"KKAudioControlMuteTurnOnNotification";
NSString * const KKAudioControlMuteTurnOffNotification   = @"KKAudioControlMuteTurnOffNotification";

@interface KKAudioControlManager()<KKVolumeViewDelegate>

@property (nonatomic, strong) KKVolumeProgressWindow *volumeView;
@property (nonatomic, strong) KKMuteSwitchListener *muteListener;

@end

@implementation KKAudioControlManager

static KKAudioControlManager* _instance;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [KKAudioControlManager new];
    });
    return _instance;
}

- (KKVolumeProgressWindow *)volumeView
{
    if (!_volumeView) {
        _volumeView = [KKVolumeProgressWindow defaultVolumeView];
        _volumeView.delegate = self;
    }
    return _volumeView;
}

- (KKMuteSwitchListener *)muteListener
{
    if (!_muteListener) {
        _muteListener = [KKMuteSwitchListener shareInstance];
    }
    return _muteListener;
}

#pragma mark - volume

- (void)addVolumeListener
{
    self.volumeView.hidden = NO;
}

- (void)removeVolumeListener
{
    self.volumeView.hidden = YES;
    [self.volumeView removeAllAudioListen];
    _volumeView = nil;
}

#pragma mark - mute

- (void)addMuteListener
{
    __weak typeof (self) weakSelf = self;
    self.muteListener.muteListenerBlock = ^(BOOL isMute){
        if (isMute) {
            [weakSelf muteSwitchTurnOff];
        }else{
            [weakSelf muteSwitchTurnOn];
        }
    };
    self.muteListener.shouldBreak = NO;
}

- (void)removeMuteListener
{
    self.muteListener.muteListenerBlock = nil;
    self.muteListener.shouldBreak = YES;
}

#pragma mark - volumedelegate

- (void)volumeView:(KKVolumeProgressWindow *)volumeView willChangeValue:(CGFloat)value oldValue:(CGFloat)oldValue
{
    if (oldValue > value) {
        [defaultCenter postNotificationName:KKAudioControlVolumeSmallerNotification object:nil];
    }else if ( oldValue < value || value == 1){
        [defaultCenter postNotificationName:KKAudioControlVolumeBiggerNotification object:nil];
    }
}

- (void)volumeView:(KKVolumeProgressWindow *)volumeView didChangeValue:(CGFloat)value oldValue:(CGFloat)oldValue
{
    
}

- (void)muteSwitchTurnOn{
    [defaultCenter postNotificationName:KKAudioControlMuteTurnOnNotification object:nil];
}

- (void)muteSwitchTurnOff{
    [defaultCenter postNotificationName:KKAudioControlMuteTurnOffNotification object:nil];
}

@end
