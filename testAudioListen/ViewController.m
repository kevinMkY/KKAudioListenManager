//
//  ViewController.m
//
//  Created by nice on 16/7/19.
//  Copyright © 2016年 kk. All rights reserved.
//

#import "ViewController.h"
#import "KKAudioControlManager.h"

extern NSString * KKAudioControlVolumeBiggerNotification;
extern NSString * KKAudioControlVolumeSmallerNotification;
extern NSString * KKAudioControlMuteTurnOnNotification;
extern NSString * KKAudioControlMuteTurnOffNotification;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *button;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self regNotifi];

    [[KKAudioControlManager shareInstance] addVolumeListener];
    [[KKAudioControlManager shareInstance] addMuteListener];
}

#pragma mark - audio

- (void)audioControlVolumeBigger
{
    NSLog(@"volume ++ ");
}

- (void)audioControlVolumeSmaller
{
    NSLog(@"volume -- ");
}

- (void)audioControlMuteTurnOn
{
    [self.button setTitle:@"mute on" forState:UIControlStateNormal];
}
- (void)audioControlMuteTurnOff
{
    [self.button setTitle:@"mute off" forState:UIControlStateNormal];
}

- (void)regNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioControlVolumeBigger)
                                                 name:KKAudioControlVolumeBiggerNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioControlVolumeSmaller)
                                                 name:KKAudioControlVolumeSmallerNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioControlMuteTurnOn)
                                                 name:KKAudioControlMuteTurnOnNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioControlMuteTurnOff)
                                                 name:KKAudioControlMuteTurnOffNotification
                                               object:nil];
}

@end
