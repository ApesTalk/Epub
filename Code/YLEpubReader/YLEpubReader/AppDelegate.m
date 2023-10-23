//
//  AppDelegate.m
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/1.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//

#import "AppDelegate.h"
#import "YLNavigationController.h"
#import "YLBookShelfController.h"
#import "ViewController.h"
#import "SVProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface BluetoothAudioRecorder : NSObject


@property (nonatomic, assign) AudioUnit audioUnit;
@property (nonatomic, strong) AVAudioFile *audioFile;

- (void)startRecording;
- (void)stopRecording;

@end



@implementation BluetoothAudioRecorder


static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    BluetoothAudioRecorder *audioRecorder = (__bridge BluetoothAudioRecorder *)inRefCon;
    
    // 将音频数据写入文件
    NSLog(@"ioData=%@", ioData);
    if (audioRecorder.audioFile != nil && ioData != NULL) {
        AudioBuffer buffer = ioData->mBuffers[0];
        NSData *data = [NSData dataWithBytes:buffer.mData length:buffer.mDataByteSize];
        [audioRecorder.audioFile writeFromBuffer:data error:nil];
    }
    
    return noErr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupAudioSession];
        [self setupAudioUnit];
    }
    return self;
}

- (void)setupAudioSession {
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord

                                     withOptions:AVAudioSessionCategoryOptionAllowBluetooth|AVAudioSessionCategoryOptionMixWithOthers

                                           error:&error];
    if (error) {
        NSLog(@"Failed to set up audio session: %@", error);
    }
    
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"Failed to activate audio session: %@", error);
    }
}

- (void)setupAudioUnit {
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AudioComponent comp = AudioComponentFindNext(NULL, &desc);
    AudioComponentInstanceNew(comp, &_audioUnit);
    
    AURenderCallbackStruct input;
    input.inputProc = recordingCallback;
    input.inputProcRefCon = (__bridge void *)self;
    AudioUnitSetProperty(_audioUnit,
                         kAudioOutputUnitProperty_SetInputCallback,
                         kAudioUnitScope_Global,
                         1,
                         &input,
                         sizeof(input));
    
    UInt32 flag = 1;
    AudioUnitSetProperty(_audioUnit,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Input,
                         1,
                         &flag,
                         sizeof(flag));
    
    AudioUnitInitialize(_audioUnit);
}

- (void)startRecording {
    // 创建音频文件保存路径

    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"recordedAudio.caf"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    // 配置音频文件的格式和设置

    NSDictionary *settings = @{
        AVFormatIDKey: @(kAudioFormatAppleIMA4),
        AVSampleRateKey: @(44100.0),
        AVNumberOfChannelsKey: @(2),
        AVLinearPCMBitDepthKey: @(16),
        AVLinearPCMIsBigEndianKey: @(NO),
        AVLinearPCMIsFloatKey: @(NO)
    };
    
    // 创建AVAudioFile对象

    NSError *error = nil;
    self.audioFile = [[AVAudioFile alloc] initForWriting:fileURL settings:settings error:&error];
    if (error) {
        NSLog(@"Failed to create audio file: %@", error);
        return;
    }
    
    AudioOutputUnitStart(_audioUnit);
}

- (void)stopRecording {
    AudioOutputUnitStop(_audioUnit);
    self.audioFile = nil;
}

@end






@interface AppDelegate ()
@property (nonatomic, strong) AVAudioRecorder *recorderTool;
@property (nonatomic, assign) NSInteger c;

@property (nonatomic, strong) BluetoothAudioRecorder *recorder;

@end

static const CGFloat kMaxDuration = 100;

@implementation AppDelegate

- (AVAudioRecorder *)recorderTool {
    if (!_recorderTool) {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test111.caf"];
        NSURL *url = [NSURL URLWithString:path];
        
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init] ;
        [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        //采样率
        [recordSetting setValue :[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey];//44100.0
        //通道数
        [recordSetting setValue :[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        //音频质量,采样质量
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
        
        _recorderTool = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:nil];
    }
    return _recorderTool;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    AVAudioSession *config = [AVAudioSession sharedInstance];
//    [config setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionAllowBluetooth|AVAudioSessionCategoryOptionDefaultToSpeaker error:NULL];
//    [self.recorderTool prepareToRecord];
//    [self.recorderTool record];
//    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        self.c++;
//        if(self.c >= kMaxDuration){
//            [self.recorderTool stop];
//            [t invalidate];
//        }
//    }];
//    [[NSRunLoop currentRunLoop] addTimer:t forMode:NSRunLoopCommonModes];
    
    
    
    _recorder = [[BluetoothAudioRecorder alloc] init];
    [_recorder startRecording];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [_recorder stopRecording];
//    });

    
//    return YES;
    [SVProgressHUD setMaximumDismissTimeInterval:1];
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    
    //在375*667的尺寸上运行demo
//    ViewController *vc = [[ViewController alloc]init];
//    _window.rootViewController = vc;
    
    YLBookShelfController *bookShelf = [[YLBookShelfController alloc]init];
    YLNavigationController *nav = [[YLNavigationController alloc]initWithRootViewController:bookShelf];
    _window.rootViewController = nav;
    [_window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
