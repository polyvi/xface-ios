
/*
 This file was modified from or inspired by Apache Cordova.

 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.
*/

//
//  XRuntime.h
//  xFace
//
//

#import <UIKit/UIKit.h>
#import "XAmsDelegate.h"
#import "XSystemBootstrap.h"

@class XViewController;

@protocol XPushHandler <NSObject>

- (void)fire:(NSString *)pushString;

@end

@interface XRuntime : NSObject <XAmsDelegate, XSystemBootstrapDelegate>

@property (assign, nonatomic) id <XPushHandler> pushDelegate;

/**
 所有正在运行的应用对应的controller
 */
@property (strong) NSMutableArray *activeViewControllers;

/**
 应用视图控制器.
 */
@property (strong, nonatomic) XViewController *viewController;

@property (nonatomic, strong) IBOutlet UIWindow* window;

/**
    处理启动参数
 */
-(void) handleOpenURL:(NSString *)url;

/**
    对Apple Push Service注册成功的情况进行处理
 */
-(void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;

@end