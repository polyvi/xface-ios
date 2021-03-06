
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
//  XConstants.h
//  xFace
//
//

// 本文件仅定义xFace全局常量
#define FILE_SEPARATOR                           @"/"
#define XFACE_WORKSPACE_FOLDER                   @"xface3" // under <Applilcation_Home>/Documents/
#define XFACE_BUNDLE_FOLDER                      @"xface3" // under <Application_Home>/xFace.app/
#define XFACE_PLAYER_WORKSPACE                   @"xface_player"
#define APPLICATION_INSTALLATION_FOLDER          @"apps"
#define APPLICATION_ICONS_FOLDER                 @"app_icons"
#define APPLICATION_CONFIG_FILE_NAME             @"app.xml"
#define PRE_SET_DIR_NAME                         @"pre_set"
#define ENCRYPT_CODE_DIR_NAME                    @"encrypt_code"
#define DEFAULT_APP_ID_FOR_PLAYER                @"helloxface"
#define DEFAULT_APP_START_PAGE                   @"index.html"
#define XFACE_JS_FILE_NAME                       @"xface.js"
#define XFACE_DATA_PLIST_NAME                    @"data.plist"
#define APP_WORKSPACE_FOLDER                     @"workspace"
#define JS_CORE_FOLDER                           @"js_core"
#define APP_DATA_DIR_FOLDER                      @"data"
#define APP_TYPE_XAPP                            @"xapp"
#define APP_TYPE_NAPP                            @"napp"
#define ZIP_PACKAGE_SUFFIX                       @".zip"
#define APP_PACKAGE_SUFFIX_XPA                   @".xpa"          //离散文件形式的web应用安装包
#define APP_PACKAGE_SUFFIX_NPA                   @".npa"          //描述native应用package
#define ENCRYPE_CODE_PACKAGE_NAME                @"jscore.zip"    //加密代码包的包名
#define APP_DATA_KEY_FOR_START_PARAMS            @"start_params"  //启动参数在xapp通讯数据中的key
#define NATIVE_APP_CUSTOM_URL_PARAMS_SEPERATOR   @"://"           //custom url中scheme与params之间的分隔符

// xFace.app下相关目录及资源命名
#define APP_DATA_PACKAGE_NAME_UNDER_WORKSPACE    @"workspace.zip"

// userApps.xml
#define USER_APPS_FILE_NAME                      @"userApps.xml"
#define TAG_APPLICATIONS                         @"applications"
#define APP_ROOT_PREINSTALLED                    @"preinstalled"
#define APP_ROOT_WORKSPACE                       @"workspace"
#define ATTR_NAME                                @"name"
#define ATTR_ID                                  @"id"
#define ATTR_VALUE                               @"value"

//tag in debug.xml
#define DEBUG_CONFIG_FILE                        @"debug.xml"
#define TAG_ROOT                                 @"config"
#define TAG_SOCKET                               @"socketlog"
#define ATTR_IP                                  @"hostip"

// config.xml中相关常量定义
#define SYSTEM_CONFIG_FILE_NAME                  @"config.xml"
#define TAG_APP_PACKAGE                          @"app_package"
#define TAG_PREFERENCE                           @"preference"
#define ENGINE_VERSION                           @"EngineVersion"
#define PERSISTENT_FILE_LOCATION                 @"iosPersistentFileLocation"
#define LIB_RUNNING_MODE                         @"LibRunningMode"
#define CUSTOM_LAUNCH_IMAGE_FILE                 @"CustomLaunchImageFile"
#define UMENG_APP_KEY                            @"UmengAppKey"
#define UMENG_REPORT_POLICY                      @"UmengReportPolicy"
#define UMENG_CHANNEL                            @"UmengChannel"

// notification name
#define XAPPLICATION_DID_FINISH_INSTALL_NOTIFICATION     @"XApplicationDidFinishInstallNotification"
#define XAPPLICATION_CLOSE_NOTIFICATION                  @"XApplicationCloseNotification"
#define XAPPLICATION_SEND_MESSAGE_NOTIFICATION           @"XApplicationSendMessageNotification"
#define XUIAPPLICATION_TIMEOUT_NOTIFICATION              @"XUIApplicationTimeoutNotification"
#define UPDATE_TIMEOUT_INTERVAL_NOTIFICATION             @"UpdateTimeoutIntervalNotification"
#define DOCUMENT_EVENT_NOTIFICATION                      @"DocumentEventNotification"


#define WILDCARDS               @"*"

#define kAppVersionUUIDKey      @"kAppVersionUUIDKey"


