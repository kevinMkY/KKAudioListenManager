//
//  KKVolumeView.h
//
//  Created by nice on 16/7/19.
//  Copyright © 2016年 kk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KKVolumeProgressWindow;

typedef NS_ENUM(NSInteger,KKVolumeViewAnimation){
    KKVolumeViewAnimationNone = 0,
    KKVolumeViewAnimationFade,
    KKVolumeViewAnimationSlideDown
};

@protocol KKVolumeViewDelegate <NSObject>

- (void)volumeView:(KKVolumeProgressWindow *)volumeView willChangeValue:(CGFloat)value oldValue:(CGFloat)oldValue;
- (void)volumeView:(KKVolumeProgressWindow *)volumeView didChangeValue:(CGFloat)value oldValue:(CGFloat)oldValue;

@optional
- (void)volumeViewDidMuteOn:(KKVolumeProgressWindow *)volumeView;
- (void)volumeViewDidMuteOff:(KKVolumeProgressWindow *)volumeView;

@end

@interface KKVolumeProgressWindow : UIWindow

@property (nonatomic, assign) KKVolumeViewAnimation animationType;
@property (nonatomic, strong) UIColor *progressBarBackgroundColor;
@property (nonatomic, strong) UIColor *progressBarTintColor;
@property (nonatomic, strong) UIColor *volumeStatusBackgroundColor;
@property (nonatomic, weak) id<KKVolumeViewDelegate> delegate;

+ (instancetype)defaultVolumeView;
- (void)removeAllAudioListen;

@end
