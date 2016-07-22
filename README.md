# KKAudioListenManager
iOS - 监听音量按键及监听静音按键,自定义音量条

1.自定义音量条,覆盖在电池栏上方
2.监听音量按键的增大/减小,即使当前处于100%音量,按+依然可以调用
3.监听静音按键的开/关

# 预览图

注意看点1.状态栏自定义音量条
注意看点2.切换物理静音开关,button文案自动切换

![](http://7xn5aw.com1.z0.glb.clouddn.com/AudioListenerlisten.gif) 

看不到图点这个 > http://7xn5aw.com1.z0.glb.clouddn.com/AudioListenerlisten.gif

# 使用方法
## 1.导入头文件
```
#import "KKAudioControlManager.h"
```

## 2.开启音量/静音监控

```
[[KKAudioControlManager shareInstance] addVolumeListener];
[[KKAudioControlManager shareInstance] addMuteListener];
```

## 3.注册通知监听


```
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
    NSLog(@"mute on ");
}
- (void)audioControlMuteTurnOff
{
    NSLog(@"mute off ");
}

```

## 4.移除监听

```
[[KKAudioControlManager shareInstance] removeMuteListener];
[[KKAudioControlManager shareInstance] removeVolumeListener];
```
