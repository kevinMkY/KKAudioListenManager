//
//  KKAudioControlManager.h
//
//  Created by nice on 16/7/19.
//  Copyright © 2016年 kk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KKAudioControlManager : NSObject

+ (instancetype)shareInstance;

- (void)addVolumeListener;
- (void)removeVolumeListener;

- (void)addMuteListener;
- (void)removeMuteListener;

@end
