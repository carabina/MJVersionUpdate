//
//  MJVersionUpdate.h
//  Tenric
//
//  Created by Tenric on 16/8/4.
//  Copyright © 2016年 Tenric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJVersionUpdate : NSObject

- (void)addAppStoreChannelWithAppId:(NSString *)appId;

- (void)addFirChannelWithAppId:(NSString *)appId token:(NSString *)token downloadUrl:(NSString*)downloadUrl;

- (void)checkUpdate;

@end
