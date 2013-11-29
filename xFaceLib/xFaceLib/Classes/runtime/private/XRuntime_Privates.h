
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
//  XRuntime_Privates.h
//  xFaceLib
//
//

#import "XRuntime.h"

@class XExtensionManager;
@class XAppManagement;
@class XJavaScriptEvaluator;
@class XSystemBootstrap;
@class XSystemEventHandler;

@interface XRuntime ()

/**
    所有与正在运行的应用关联的view controller
 */
@property (strong) NSMutableArray *activeViewControllers;

/**
	应用管理器.
 */
@property (strong, nonatomic) XAppManagement *appManagement;

/**
	负责资源部署，安装预置应用, 启动系统等.
 */
@property (strong, nonatomic) id <XSystemBootstrap> systemBootstrap;

/**
    负责处理系统事件，如resume, pause等
 */
@property (strong, nonatomic) XSystemEventHandler *sysEventHandler;

/**
    启动参数
 */
@property (strong, readwrite, nonatomic) NSString *bootParams;

/**
    显示错误提示框
    @param error error具体信息
 */
- (void) showErrorAlert:(NSError *)error;

@end
