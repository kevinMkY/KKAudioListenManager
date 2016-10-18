//
//  KKMuteSwitchListener.h
//
//  Created by nice on 16/7/19.
//  Copyright © 2016年 kk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^KKMuteSwitchListenerBlock)(BOOL silent);

@interface KKMuteSwitchListener : NSObject

@property (nonatomic,readonly) BOOL isMute;
@property (nonatomic,copy) KKMuteSwitchListenerBlock muteListenerBlock;

@property (nonatomic, assign) BOOL shouldBreak;

+ (instancetype)shareInstance;

@end
