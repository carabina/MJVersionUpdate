//
//  MJVersionUpdate.m
//  Tenric
//
//  Created by Tenric on 16/8/4.
//  Copyright © 2016年 Tenric. All rights reserved.
//

#import "MJVersionUpdate.h"
#import <UIKit/UIKit.h>

@interface MJAppChannel : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *infoUrl;

@property (nonatomic, copy) NSString *downloadUrl;

@property (nonatomic, copy) NSString *alertTitle;

@property (nonatomic, copy) NSString *alertMessage;

@end

@implementation MJAppChannel

@end


@interface MJVersionUpdate() <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableDictionary<NSString*, MJAppChannel*> *channels;

@end


@implementation MJVersionUpdate

- (instancetype)init {
    self = [super init];
    if (self) {
        self.channels = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addAppStoreChannelWithAppId:(NSString *)appId {
    
    MJAppChannel *appStoreChannel = [MJAppChannel new];
    appStoreChannel.name = @"AppStore";
    appStoreChannel.infoUrl = [NSString stringWithFormat:@"https://itunes.apple.com/cn/lookup?id=%@",appId];
    appStoreChannel.downloadUrl = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id/%@",appId];
    if ([MJVersionUpdate appName]) {
        appStoreChannel.alertTitle = [NSString stringWithFormat:@"%@有新版本了！",[MJVersionUpdate appName]];
    }
    appStoreChannel.alertMessage = @"若您选择忽略此版本，仍可以随时到appstore升级至最新。";
    
    self.channels[appStoreChannel.name] = appStoreChannel;
}

- (void)addFirChannelWithAppId:(NSString *)appId token:(NSString *)token downloadUrl:(NSString*)downloadUrl {
    
    MJAppChannel *firChannel = [MJAppChannel new];
    firChannel.name = @"Fir";
    firChannel.infoUrl = [NSString stringWithFormat:@"http://api.fir.im/apps/latest/%@?api_token=%@",appId,token];
    firChannel.downloadUrl = downloadUrl;
    if ([MJVersionUpdate appName]) {
        firChannel.alertTitle = [NSString stringWithFormat:@"%@有新版本了！",[MJVersionUpdate appName]];
    }
    firChannel.alertMessage = [NSString stringWithFormat:@"若您选择忽略此版本，仍可以随时到%@升级至最新。",downloadUrl];
    
    self.channels[firChannel.name] = firChannel;
}

- (void)checkUpdate {
    
    NSString *channelName = [MJVersionUpdate channelName];
    if (!channelName || self.channels[channelName] == nil) {
        return;
    }
    
    MJAppChannel *channel = self.channels[channelName];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 20;
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSURL *url = [NSURL URLWithString:channel.infoUrl];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [self.session finishTasksAndInvalidate];
        if (!data) {
            return;
        }
        
        if ([channel.name isEqualToString:@"AppStore"]) {
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *results = jsonDic[@"results"];
            if (results.count > 0) {
                NSDictionary * infoDic = results[0];
                NSString *version = infoDic[@"version"];
                if (version) {
                    [self handleRemoteVersion:version channel:channel];
                }
                
            }
        }
        else if([channel.name isEqualToString:@"Fir"]) {
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *version = jsonDic[@"versionShort"];
            if (version) {
                [self handleRemoteVersion:version channel:channel];
            }
        }
        
    }];
    
    [task resume];
    
}

- (void)handleRemoteVersion:(NSString *)version channel:(MJAppChannel *)channel {
    
    NSString *currentVersion = [MJVersionUpdate localVersion];
    if (!currentVersion) {
        return;
    }
    
    NSComparisonResult ret = [version compare:currentVersion];
    if (ret == NSOrderedAscending) {
        NSLog(@"服务器版本小于本地版本");
    }
    else if(ret == NSOrderedDescending) {
        NSLog(@"服务器版本大于本地版本");
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:channel.alertTitle message:channel.alertMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionUpdate = [UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:channel.downloadUrl]];
        }];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"忽略此版本" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:actionUpdate];
        [alertController addAction:actionCancel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            [viewController presentViewController:alertController animated:YES completion:nil];
        });
    }
    else {
        NSLog(@"服务器版本等于本地版本");
    }
}

+ (NSString *)localVersion {
    
    NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
    NSString *version = infoDic[@"CFBundleShortVersionString"];
    
    return version;
}


+ (NSString *)channelName {
    
    NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
    NSString *channelName = infoDic[@"Channel"];
    
    return channelName;
}


+ (NSString *)appName {
    
    NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
    NSString *appName = infoDic[@"CFBundleName"];
    
    return appName;
}

@end
