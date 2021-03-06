
/*
 Copyright 2012-2013, Polyvi Inc. (http://polyvi.github.io/openxface)
 This program is distributed under the terms of the GNU General Public License.

 This file is part of xFace.

 xFace is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 xFace is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with xFace.  If not, see <http://www.gnu.org/licenses/>.
*/

//
//  XUtils.m
//  xFace
//
//

#import "XUtils.h"
#import "ZipArchive+XZipArchive.h"
#import "XConstants.h"
#import "XConfiguration.h"
#import "APXML.h"
#import "XUtils_Privates.h"
#import "XAppXMLParser.h"
#import "XAppXMLParserFactory.h"
#import "XRuntime.h"
#import "XSystemConfigInfo.h"
#import "XAppInfo.h"
#import "iToast.h"
#import "XFileUtils.h"
#import "XViewController.h"
#import "XRootViewController.h"
#import "XAppWebView.h"

#import <Cordova/CDVWebViewDelegate.h>

#define APP_VERSION_FOUR_SEQUENCE (4)
#define BACKSLASH       @"\\"

@implementation XUtils

static XUtils* sSelPerformer = nil;

+ (void)initialize
{
    sSelPerformer = [[XUtils alloc] init];
}

+ (NSInteger) generateRandomId
{
    return arc4random();
}

+ (BOOL) unpackPackageAtPath:(NSString *)srcPath toPath:(NSString *)dstPath
{
    BOOL ret = NO;
    if ((0 == [srcPath length]) || (0 == [dstPath length]))
    {
        return ret;
    }

    ZipArchive *za = [[ZipArchive alloc] init];
    if ([za UnzipOpenFile:srcPath])
    {
        ret = [za UnzipFileTo:dstPath overWrite:YES];
        [za UnzipCloseFile];
    }

    if(ret)
    {
        DLog(@"unpack application package successfully!");
    } else
    {
        ALog(@"Failed to unpack application package!");
    }
    return ret;
}

+ (BOOL) parseXMLFileAtPath:(NSString *)path withDelegate:(id <NSXMLParserDelegate>)delegate
{
    BOOL ret = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (ret)
    {
        NSData *xmlData = [[NSFileManager defaultManager] contentsAtPath:path];
        ret = [XUtils parseXMLData:xmlData withDelegate:delegate];
    }
    return ret;
}

+ (BOOL) parseXMLData:(NSData *)data withDelegate:(id <NSXMLParserDelegate>)delegate
{
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    [xmlParser setDelegate:delegate];
    BOOL ret = [xmlParser parse];
    return ret;
}

+ (NSData *) readFile:(NSString *)fileName inPackage:(NSString *)packagePath
{
    NSAssert((0 != [fileName length]), nil);

    ZipArchive *za = [[ZipArchive alloc] init];

    BOOL ret = [za UnzipOpenFile:packagePath];
    if (!ret)
    {
        return nil;
    }

    NSData *data = nil;
    ret = [za locateFileInZip:fileName];
    if (ret)
    {
        data = [za readCurrentFileInZip];
    }

    [za UnzipCloseFile];
    return data;
}

+ (XAppInfo *) getAppInfoFromAppXMLData:(NSData *)xmlData
{
    id<XAppXMLParser> appXMLParser = [XAppXMLParserFactory createAppXMLParserWithXMLData:xmlData];
    if (appXMLParser)
    {
        XAppInfo *appInfo = [appXMLParser parseAppXML];
        if ([appInfo.appId length] <= 0 || appInfo.entry <= 0) {
             [[[[iToast makeText:@"Failed to get app config from app.xml, please set app id and content properly!"]
                setGravity:iToastGravityCenter] setDuration:iToastDurationLong] show];
            return nil;
        }
        return appInfo;
    }

    //如果app.xml是不能识别的，会返回一个为nil 的appxml parser
    ALog(@"can't parse app.xml");
    return nil;
}

+ (XAppInfo *) getAppInfoFromAppPackage:(NSString *)appPackagePath
{
    NSData *xmlData = [XUtils readFile:APPLICATION_CONFIG_FILE_NAME inPackage:appPackagePath];
    if (xmlData)
    {
        // 解析获取到的应用配置文件数据
        XAppInfo *appInfo = [XUtils getAppInfoFromAppXMLData:xmlData];
        return appInfo;
    }
    return nil;
}

+ (XAppInfo *) getAppInfoFromConfigFileAtPath:(NSString *)appConfigFilePath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:appConfigFilePath])
    {
        NSData *xmlData = [fileMgr contentsAtPath:appConfigFilePath];
        XAppInfo *appInfo = [XUtils getAppInfoFromAppXMLData:xmlData];
        return appInfo;
    }
    ALog(@"app.xml at path:%@ not found!", appConfigFilePath);
    return nil;
}

+ (NSString *) resolvePath:(NSString *)path usingWorkspace:(NSString *)workspace
{
    NSAssert([workspace isAbsolutePath], @"Error:path:%@ is not absolute path", workspace);

    if (0 == [path length])
    {
        return workspace;
    }

    path = [path stringByReplacingOccurrencesOfString:BACKSLASH withString:FILE_SEPARATOR];

    NSString *resolvedPath = [workspace stringByAppendingPathComponent:path];
    resolvedPath = [resolvedPath stringByStandardizingPath];

    // 转换后的path要求在workspace下
    NSString *resolvedTempPath = resolvedPath;
    if (![resolvedPath hasSuffix:FILE_SEPARATOR])
    {
        resolvedTempPath = [resolvedPath stringByAppendingString:FILE_SEPARATOR];
    }
    if(![workspace hasSuffix:FILE_SEPARATOR])
    {
        workspace = [workspace stringByAppendingString:FILE_SEPARATOR];
    }

    BOOL ret = [resolvedTempPath hasPrefix:workspace];
    if (ret)
    {
        return resolvedPath;
    }
    else
    {
        ALog(@"Error:path:%@ is not authorized", resolvedPath);
        return nil;
    }
}

+ (NSString *) generateAppIconPathUsingAppId:(NSString *)appId relativeIconPath:(NSString *)relativeIconPath
{
    // 生成的应用图标最终放置的目标路径形如：<Application_Home>/Documents/xface3/app_icons/appId/icon.png
    NSAssert((nil != appId), nil);

    NSString *iconRoot = [[XConfiguration getInstance] appIconsDir];
    iconRoot = [iconRoot stringByAppendingFormat:@"%@", appId];

    NSString *iconPath = [self resolvePath:relativeIconPath usingWorkspace:iconRoot];
    return iconPath;
}

+ (BOOL) saveDoc:(APDocument *)doc toFile:(NSString *)filePath
{
    NSString *xmlStr = [doc prettyXML];
    NSData *xmlData=[xmlStr dataUsingEncoding:NSUTF8StringEncoding];
    BOOL ret = [xmlData writeToFile:filePath atomically:YES];
    if (!ret)
    {
        ALog(@"Error:writting configuration failed and file path is: %@", filePath);
    }
    return ret;
}

+ (id) getPreferenceForKey:(NSString *)keyName
{
    XSystemConfigInfo *systemConfigInfo = [[XConfiguration getInstance] systemConfigInfo];
    id preference = [[systemConfigInfo settings] objectForKey:keyName];
    return preference;
}

+ (id) getValueFromDataForKey:(id)key
{
    NSString *systemWorkspace = [[XConfiguration getInstance] systemWorkspace];
    NSString *plistPath = [systemWorkspace stringByAppendingPathComponent:XFACE_DATA_PLIST_NAME];
    NSDictionary *configDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    if (configDic) {
        return [configDic valueForKey:key];
    }
    return nil;
}

+ (void) setValueToDataForKey:(id)key value:(id)value
{
    NSString *systemWorkspace = [[XConfiguration getInstance] systemWorkspace];
    NSString *plistPath = [systemWorkspace stringByAppendingPathComponent:XFACE_DATA_PLIST_NAME];
    NSMutableDictionary *configDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    if (nil == configDic)
    {
        configDic = [[NSMutableDictionary alloc] init];
    }

    [configDic setObject:value forKey:key];
    [configDic writeToFile:plistPath atomically:YES];
}

+ (void)performSelectorInBackgroundWithTarget:(id)target selector:(SEL)aSelector withObject:(id)anObject
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
            target, KEY_TARGET,
            [NSValue valueWithPointer:aSelector], KEY_SELECTOR,
            anObject, KEY_OBJECT,
            nil];

    [sSelPerformer performSelectorInBackground:@selector(performWithArgs:) withObject:args];
}

- (void) performWithArgs:(NSDictionary *)args
{
    @autoreleasepool
    {
        id target = [args objectForKey:KEY_TARGET];
        id anObj = [args objectForKey:KEY_OBJECT];
        SEL selector = [[args objectForKey:KEY_SELECTOR] pointerValue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:selector withObject:anObj];
#pragma clang diagnostic pop
    }
}

+ (NSString*) getIpFromDebugConfig
{
    //读取配置信息
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString* xmlFile = [documentDirectory stringByAppendingFormat:@"%@%@", FILE_SEPARATOR, DEBUG_CONFIG_FILE];
    NSError* __autoreleasing error;
    NSString *xmlStr = [[NSString alloc] initWithContentsOfFile:xmlFile encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        return nil;
    }
    APDocument* doc = [APDocument documentWithXMLString:xmlStr];
    APElement *rootElem = [doc rootElement];
    APElement *socketElem = [rootElem firstChildElementNamed:TAG_SOCKET];
    NSString* ip = [socketElem valueForAttributeNamed:ATTR_IP];
    return ip;
}

+ (NSString*) getWorkDir
{
    XConfiguration *config = [XConfiguration getInstance];
    return [config systemWorkspace];
}

+ (NSString *)buildConfigFilePathWithAppId:(NSString *)appId
{
    // 应用配置文件所在路径形如：~/Documents/xface3/apps/appId/app.xml
    NSAssert(([appId length] > 0), nil);
    NSString *appInstallationPath = [[XConfiguration getInstance] appInstallationDir];
    NSString *appConfigFilePath = [appInstallationPath stringByAppendingFormat:@"%@%@%@", appId, FILE_SEPARATOR, APPLICATION_CONFIG_FILE_NAME];

    return appConfigFilePath;
}

+ (NSString *) buildPreinstalledAppSrcPath:(NSString *)appId
{
    // 构造预装应用源码所在绝对路径，路径形如：<Application_Home>/xFace.app/xface3/appId/
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSString *preinstalledAppsPath = [mainBundle pathForResource:XFACE_BUNDLE_FOLDER ofType:nil inDirectory:nil];
    if (![preinstalledAppsPath length])
    {
        return nil;
    }

    NSAssert([appId length], nil);
    NSString *appSrcPath = [preinstalledAppsPath stringByAppendingFormat:@"%@%@%@", FILE_SEPARATOR, appId, FILE_SEPARATOR];
    return appSrcPath;
}

+ (NSString *)buildWorkspaceAppSrcPath:(NSString *)appId
{
    NSString *appSrcPath = [[XConfiguration getInstance] appInstallationDir];

    // 工作空间下应用安装路径形如：<Application_Home>/Documents/xface3/apps/appId/
    NSAssert([appId length], nil);
    appSrcPath = [appSrcPath stringByAppendingFormat:@"%@%@", appId, FILE_SEPARATOR];
    return appSrcPath;
}

+ (BOOL)copyJsCore
{
    //拷贝xface.js,cordova_plugins.js,plugins目录到<Application_Home>/Library/xface3/js_core下
    //同时支持离散以及单文件方式
    BOOL ret = YES;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *destRoot = [[paths objectAtIndex:0] stringByAppendingFormat:@"%@%@%@%@", FILE_SEPARATOR, XFACE_WORKSPACE_FOLDER, FILE_SEPARATOR, JS_CORE_FOLDER];

    NSAssert([[[XConfiguration getInstance] preinstallApps] count], @"Can't get js core src!");
    NSString *defaultAppId = [[XConfiguration getInstance] preinstallApps][0];
    NSString *srcRoot = [XUtils buildPreinstalledAppSrcPath:defaultAppId];

    //NOTE:文件命名需要与cli对应
    NSArray *jsCoreNames = [[NSArray alloc] initWithObjects:XFACE_JS_FILE_NAME,
                          @"cordova_plugins.js",
                          @"plugins",
                          nil];
    for (NSString *name in jsCoreNames)
    {
        NSString *srcPath = [srcRoot stringByAppendingPathComponent:name];
        if ([[NSFileManager defaultManager] fileExistsAtPath:srcPath])
        {
            NSString *destPath = [destRoot stringByAppendingPathComponent:name];

            ret &= [XFileUtils copyItemAtPath:srcPath toPath:destPath error:nil];
        }
        else if ([name isEqualToString:XFACE_JS_FILE_NAME])
        {
            ALog("Failed to copy file %@ from %@ to %@!", name, srcRoot, destRoot);
            return NO;
        }
    }

    return ret;
}

+ (UIViewController *)topViewController
{
    return [XUtils topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootVC
{
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController*)rootVC;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController*)rootVC;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootVC.presentedViewController) {
        UIViewController *presentedViewController = rootVC.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootVC;
    }
}

+ (BOOL)isDefaultAppWebView:(UIWebView *)theWebView
{
    NSAssert([theWebView isKindOfClass:[XAppWebView class]], nil);
    NSAssert([[theWebView delegate] isKindOfClass:[CDVWebViewDelegate class]], nil);

    CDVWebViewDelegate *delegate = (CDVWebViewDelegate *)[theWebView delegate];
    id obj = [delegate valueForKey:@"_delegate"];

    BOOL ret = ([obj isKindOfClass:[XRootViewController class]]);
    return ret;
}

+ (NSString *)persistentRoot
{
    NSString *persistentRoot = nil;
    NSString *location = [[XUtils getPreferenceForKey:PERSISTENT_FILE_LOCATION] lowercaseString];
    if (location == nil) {
        // Compatibilty by default if the config preference is not set
        location = @"compatibility";
    }

    if ([location isEqualToString:@"library"]) {
        // Get the Library directory path
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        persistentRoot = [paths objectAtIndex:0];
    } else if ([location isEqualToString:@"compatibility"]) {
        /*
         *  Fall-back to compatibility mode -- this is the logic implemented in
         *  earlier versions of xface, and should be maintained here so
         *  that apps which were originally deployed with older versions of xface
         *  can continue to provide access to files stored under those
         *  versions.
         */
        // Get the Documents directory path
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        persistentRoot = [paths objectAtIndex:0];
    } else {
        NSAssert(false,
                 @"Persistent file location configuration error: Please set iosPersistentFileLocation in config.xml to one of \"library\" (for new applications) or \"compatibility\" (for compatibility with previous versions)");
    }

    // 路径形如：<Applilcation_Home>/Documents或者<Applilcation_Home>/Library
    return persistentRoot;
}

+ (BOOL)isOptimizedLibRunningMode
{
    //LibRunningMode取值如下：
    //1) normal: 兼容xFace v3.1, 在库模式下，runtime可以被创建多次，每次退出xFace时销毁runtime；
    //2) optimized: runtime只被创建一次，且在XRootViewController的view已经加载的情况下，可以通过postNotification启动xFace默认应用

    //注意：
    //1）只有添加xface-extra-lib插件时才需配置LibRunningMode，非库模式下无需配置此项，即xFace按照normal的方式启动
    //2）LibRunningMode的取值应根据第三方集成xFaceLib的使用场景决定.具体请参考xFace库模式使用手册
    NSString *libRunningMode = [[XUtils getPreferenceForKey:LIB_RUNNING_MODE] lowercaseString];
    BOOL ret = [libRunningMode isEqualToString:@"optimized"] ? YES : NO;
    return ret;
}

//TODO:可以考虑定义一个专门用于处理路径的工具类
+ (BOOL) isAbsolute:(NSString *)path
{
    //如果以"/"开头或为file协议URL,则处理为绝对路径
    if ([path hasPrefix:@"/"])
    {
        return YES;
    }

    NSURL *newUri = [NSURL URLWithString:path];
    if (!newUri && [path hasPrefix:@"file://"])
    {
        path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        newUri = [NSURL URLWithString:path];
    }
    return [newUri isFileURL];
}

+ (NSString*) getAbsolutePath:(NSString *)path
{
    if ([path hasPrefix:@"/"])
    {
        return [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    else
    {
        //仅处理file协议URL
        NSURL* newUri = [NSURL URLWithString:path];
        if (!newUri && [path hasPrefix:@"file://"])
        {
            path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            newUri = [NSURL URLWithString:path];
        }
        if ([newUri isFileURL])
        {
            return [newUri path];
        }
        return nil;
    }
}

@end
