#import "JshareFlutterPlugin.h"
#import "JSHAREService.h"
#import <AdSupport/AdSupport.h>

#define JSLog(fmt, ...) NSLog((@"| JSHARE | iOS | - " fmt), ##__VA_ARGS__)

/// 错误码
static NSString *const j_code_key = @"code";
/// 回调的提示信息，统一返回 flutter 为 message
static NSString *const j_msg_key = @"message";
// 成功
static NSString *j_success_code = @"success";
// 取消
static NSString *j_cancel_code = @"cancel";
// 失败
static NSString *j_fail_code = @"fail";

@implementation JshareFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"jshare_flutter_plugin" binaryMessenger:[registrar messenger]];
    
    JshareFlutterPlugin* instance = [[JshareFlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar addApplicationDelegate:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    JSLog(@"Action - handleMethodCall: %@",call.method);

    NSString *methodName = call.method;
    if ([methodName isEqualToString:@"getPlatformVersion"]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([methodName isEqualToString:@"setup"]) {
        [self setup:call];
    } else if ([methodName isEqualToString:@"isClientValid"]) {
        [self isClientValid:call result:result];
    } else if ([methodName isEqualToString:@"shareMessage"]) {
        [self shareMessage:call result:result];
    } else if ([methodName isEqualToString:@"authorize"]) {
        [self authorize:call result:result];
    } else if ([methodName isEqualToString:@"isPlatformAuth"]) {
        [self isPlatformAuth:call result:result];
    } else if ([methodName isEqualToString:@"cancelPlatformAuth"]) {
        [self cancelPlatformAuth:call result:result];
    } else if ([methodName isEqualToString:@"getUserInfo"]) {
        [self getUserInfo:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}
- (void)setup:(FlutterMethodCall *)call {
    JSHARELaunchConfig *config = [[JSHARELaunchConfig alloc] init];
    NSString *appKey = call.arguments[@"appKey"];
    if (appKey) {
        config.appKey = appKey;
    }
    NSString *weChatAppId = call.arguments[@"weChatAppId"];
    if (weChatAppId) {
        config.WeChatAppId = weChatAppId;
    }
    NSString *weChatAppSecret = call.arguments[@"weChatAppSecret"];
    if (weChatAppSecret) {
        config.WeChatAppSecret = weChatAppSecret;
    }
    NSString *universallink = call.arguments[@"universalLink"];
    if (universallink) {
        config.universalLink = universallink;
    }
    
    NSString *qqAppId = call.arguments[@"qqAppId"];
    if (qqAppId) {
        config.QQAppId = qqAppId;
    }
    
    NSString *qqAppKey = call.arguments[@"qqAppKey"];
    if (qqAppKey) {
        config.QQAppKey = qqAppKey;
    }
    
    NSString *sinaWeiboAppKey = call.arguments[@"sinaWeiboAppKey"];
    if (sinaWeiboAppKey) {
        config.SinaWeiboAppKey = sinaWeiboAppKey;
    }
    NSString *sinaWeiboAppSecret = call.arguments[@"sinaWeiboAppSecret"];
    if (sinaWeiboAppSecret) {
        config.SinaWeiboAppSecret = sinaWeiboAppSecret;
    }
    NSString *sinaRedirectUri = call.arguments[@"sinaRedirectUri"];
    if (sinaRedirectUri) {
        config.SinaRedirectUri = sinaRedirectUri;
    }
    NSString *facebookAppID = call.arguments[@"facebookAppID"];
    if (facebookAppID) {
        config.FacebookAppID = facebookAppID;
    }
    
    NSString *facebookDisplayName = call.arguments[@"facebookDisplayName"];
    if (facebookDisplayName) {
        config.FacebookDisplayName = facebookDisplayName;
    }
    
    NSString *twitterConsumerKey = call.arguments[@"twitterConsumerKey"];
    if (twitterConsumerKey) {
        config.TwitterConsumerKey = twitterConsumerKey;
    }
    NSString *twitterConsumerSecret = call.arguments[@"twitterConsumerSecret"];
    if (twitterConsumerSecret) {
        config.TwitterConsumerSecret = twitterConsumerSecret;
    }
    
    config.isSupportWebSina = YES;
    
    NSString *channel = call.arguments[@"channel"];
    if (channel) {
        config.channel = channel;
    }
    NSNumber *isProduction = call.arguments[@"isProduction"];
    if (isProduction) {
        config.isProduction = [isProduction boolValue];
    }
    NSNumber *isAdvertisinId = call.arguments[@"isAdvertisinId"];
    if ([isAdvertisinId boolValue]) {
        NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        config.advertisingId = advertisingId;
    }
    
    [JSHAREService setupWithConfig:config];
    
    NSNumber *isDebug = call.arguments[@"isDebug"];
    [JSHAREService setDebug:[isDebug boolValue]];
}

- (void)isClientValid:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *platformName = call.arguments[@"platform"];
    JSHAREPlatform platform  = [self getSharePlatform:platformName];
    BOOL isValid = NO;
    switch (platform) {
        case JSHAREPlatformWechatSession:
        case JSHAREPlatformWechatTimeLine:
        case JSHAREPlatformWechatFavourite:
            isValid = [JSHAREService isWeChatInstalled];
            break;
        case JSHAREPlatformQQ:
        case JSHAREPlatformQzone:
            isValid = [JSHAREService isQQInstalled];
            break;
        case JSHAREPlatformSinaWeibo:
        case JSHAREPlatformSinaWeiboContact:
            isValid = [JSHAREService isSinaWeiBoInstalled];
            break;
        case JSHAREPlatformFacebook:
            isValid = [JSHAREService isFacebookInstalled];
            break;
        case JSHAREPlatformFacebookMessenger:
            isValid = [JSHAREService isFacebookMessengerInstalled];
            break;
        case JSHAREPlatformTwitter:
            isValid = [JSHAREService isTwitterInstalled];
            break;
            
        default:
            break;
    }
    
    NSDictionary *dict = @{j_code_key:isValid?j_success_code:j_fail_code,
                           j_msg_key:@""};
    dispatch_async(dispatch_get_main_queue(), ^{
        result(dict);
    });
}
- (void)shareMessage:(FlutterMethodCall *)call result:(FlutterResult)result {
    
    // 分享内容
    JSHAREMessage *message = [self message:call.arguments];
    if (!message) {
        return ;
    }
    
    [JSHAREService share:message handler:^(JSHAREState state, NSError *error) {
        
        NSString *stateStr = nil;
        NSString *desc = @"";
        if (state == JSHAREStateSuccess) {
            stateStr = j_success_code;
            desc = @"分享成功";
        }else if (state == JSHAREStateFail){
            stateStr = j_fail_code;
            desc = error.description;
        }else if (state == JSHAREStateCancel){
            stateStr = j_cancel_code;
            desc = @"取消分享";
        }else{
            stateStr = j_fail_code;
            desc = @"未知错误";
        }
        NSDictionary *dict = @{j_code_key:stateStr,
                               j_msg_key:desc};
        dispatch_async(dispatch_get_main_queue(), ^{
            result(dict);
        });
    }];
}

- (void)authorize:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *platformName = call.arguments[@"platform"];
    JSHAREPlatform platform  = [self getSharePlatform:platformName];
    [self getInfoWithPlatform:platform isAuthorize:YES result:result];
}

- (void)isPlatformAuth:(FlutterMethodCall *)call result:(FlutterResult)result{
    NSString *platformName = call.arguments[@"platform"];
    JSHAREPlatform platform  = [self getSharePlatform:platformName];
    BOOL isAuth = [JSHAREService isPlatformAuth:platform];
    
    NSDictionary *dict = @{j_code_key:isAuth?j_success_code:j_fail_code,
                           j_msg_key:isAuth?@"已授权":@"未授权"};
    dispatch_async(dispatch_get_main_queue(), ^{
        result(dict);
    });
}

- (void)cancelPlatformAuth:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *platformName = call.arguments[@"platform"];
    JSHAREPlatform platform  = [self getSharePlatform:platformName];
    BOOL isCancel = [JSHAREService cancelAuthWithPlatform:platform];
    
    NSDictionary *dict = @{j_code_key:isCancel?j_success_code:j_fail_code,
                           j_msg_key:isCancel?@"取消授权成功":@"取消授权失败"};
    dispatch_async(dispatch_get_main_queue(), ^{
        result(dict);
    });
}

- (void)getUserInfo:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *platformName = call.arguments[@"platform"];
    JSHAREPlatform platform  = [self getSharePlatform:platformName];
    [self getInfoWithPlatform:platform isAuthorize:NO result:result];
}
/// 授权和获取用户信息
- (void)getInfoWithPlatform:(JSHAREPlatform)platform isAuthorize:(BOOL)isAuthorize result:(FlutterResult)result {
    [JSHAREService getSocialUserInfo:platform handler:^(JSHARESocialUserInfo *userInfo, NSError *error) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if (error) {
            dict[j_code_key] = j_fail_code;
            dict[j_msg_key] = isAuthorize?@"授权失败":@"无法获取到用户信息";
        }else{
            dict = [self analysisSocialUserInfo:userInfo];
            dict[j_code_key] = j_success_code;
            dict[j_msg_key] = isAuthorize?@"授权成功":@"获取用户信息成功";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                result(dict);
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            result(dict);
        });
    }];
}
- (NSMutableDictionary *)analysisSocialUserInfo:(JSHARESocialUserInfo *)userInfo {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (userInfo.name) {
        dict[@"name"] = userInfo.name;
    }
    if (userInfo.iconurl) {
        dict[@"imageUrl"] = userInfo.iconurl;
    }
    if (userInfo.gender) {
        dict[@"gender"] = [NSNumber numberWithInteger:userInfo.gender];
    }
    if (userInfo.openid) {
        dict[@"openid"] = userInfo.openid;
    }
    if (userInfo.accessToken) {
        dict[@"token"] = userInfo.accessToken;
    }
    if (userInfo.refreshToken) {
        dict[@"refreshToken"] = userInfo.refreshToken;
    }
    if (userInfo.expiration) {
        dict[@"expiration"] = [NSString stringWithFormat:@"%@",@(userInfo.expiration)];
    }
    if (userInfo.userOriginalResponse) {
        dict[@"originData"] = [self toJsonString:userInfo.userOriginalResponse];
    }
    if (userInfo.oauthOriginalResponse) {
        dict[@"originData"] = [self toJsonString:userInfo.oauthOriginalResponse];
    }
    return dict;
}
- (NSString *)toJsonString:(NSDictionary *)dic{
  NSError  *error;
  NSData   *data       = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
  NSString *jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
  return jsonString;
}
- (JSHAREMessage *)message:(NSDictionary *)arguments {
    NSString *platformName = arguments[@"platform"];
    NSString *shareTypeName = arguments[@"mediaType"];
    
    if (!platformName) {
        return nil;
    }
    JSHAREPlatform platform = [self getSharePlatform:platformName];
    if (!shareTypeName) {
        return nil;
    }
    JSHAREMediaType mediaType = [self getShareType:shareTypeName];
    JSHAREMessage *message = [[JSHAREMessage alloc] init];
    message.platform = platform;
    message.mediaType = mediaType;
    
    NSString *title = arguments[@"title"];
    if (title) {
        message.title = title;
    }
    NSString *text = arguments[@"text"];
    if (text) {
        message.text = text;
    }
    NSString *url = arguments[@"url"];
    if (url) {
        message.url = url;
    }
    NSString *imagePath = arguments[@"imagePath"];
    NSString *videoPath = arguments[@"videoPath"];
    NSString *musicDataUrl = arguments[@"musicDataUrl"];
    NSString *extInfo =  arguments[@"extInfo"];
    NSString *fileDataPath = arguments[@"fileDataPath"];
    NSString *fileExt = arguments[@"fileExt"];
    NSString *sinaObjectID = arguments[@"sinaObjectID"];
    NSString *emoticonDataPath = arguments[@"emoticonDataPath"];
    NSString *miniProgramUserName = arguments[@"miniProgramUserName"];
    NSString *miniProgramPath = arguments[@"miniProgramPath"];
    NSNumber *miniProgramType = arguments[@"miniProgramType"];
    
    NSData *imageData = nil;
    if (imagePath) {
        imageData = [NSData dataWithContentsOfFile:imagePath];
        if (platform == JSHAREPlatformFacebook || platform == JSHAREPlatformFacebookMessenger) {
            message.images = @[imageData];
        }else{
            message.image = imageData;
        }
    }
    if (musicDataUrl) {
        message.mediaDataUrl = musicDataUrl;
    }
    
    //wechat、qq、 qz(url 和本地视频) fb、fbm(本地)、tw(data)
    if (videoPath) {
        if (platform == JSHAREPlatformTwitter) {
            message.videoData = [NSData dataWithContentsOfFile:videoPath];
        } else {
            //qz、fb、fbm 要传 ALAsset的ALAssetPropertyAssetURL
            // videoPath 转换成 ALAsset
            message.videoAssetURL = videoPath;
        }
    }
    
    switch (mediaType) {
        case JSHARELink:
        case JSHAREAudio:
        case JSHAREVideo: {
            //缩略图
            if (imageData) {
                message.thumbnail = imageData;
            }
        }
            break;
        case JSHAREApp:
            break;
        case JSHAREFile:
            break;
        case JSHAREEmoticon:
            break;
        case JSHAREMiniProgram:
            break;
            
        default:
            break;
    }

    if (extInfo) {
        message.extInfo = extInfo;
    }
    if (fileDataPath) {
        message.fileData = [NSData dataWithContentsOfFile:fileDataPath];
    }
    if (fileExt) {
        message.fileExt = fileExt;
    }
    if (emoticonDataPath) {
        message.emoticonData = [NSData dataWithContentsOfFile:emoticonDataPath];
    }
    if (sinaObjectID) {
        message.sinaObjectID = sinaObjectID;
    }
    
    if (miniProgramUserName) {
        message.userName = miniProgramUserName;
    }
    if (miniProgramPath) {
        message.path = miniProgramPath;
    }
    if (miniProgramType) {
        message.miniProgramType = [miniProgramType intValue];
    }
    if (arguments[@"miniProgramWithShareTicket"]) {
        message.withShareTicket = [arguments[@"miniProgramWithShareTicket"] boolValue];
    }
    
    return message;
}
- (JSHAREPlatform)getSharePlatform:(NSString *)platformName {
    JSHAREPlatform platform = JSHAREPlatformWechatSession;
    
    if ([platformName isEqualToString:@"wechatSession"]) {
        platform = JSHAREPlatformWechatSession;
    }else if ([platformName isEqualToString:@"wechatTimeLine"]) {
        platform = JSHAREPlatformWechatTimeLine;
    }else if ([platformName isEqualToString:@"wechatFavourite"]) {
        platform = JSHAREPlatformWechatFavourite;
    }else if ([platformName isEqualToString:@"qq"]) {
        platform = JSHAREPlatformQQ;
    }else if ([platformName isEqualToString:@"qZone"]) {
        platform = JSHAREPlatformQzone;
    }else if ([platformName isEqualToString:@"sinaWeibo"]) {
        platform = JSHAREPlatformSinaWeibo;
    }else if ([platformName isEqualToString:@"sinaWeiboContact"]) {
        platform = JSHAREPlatformSinaWeiboContact;
    }else if ([platformName isEqualToString:@"facebook"]) {
        platform = JSHAREPlatformFacebook;
    }else if ([platformName isEqualToString:@"facebookMessenger"]) {
        platform = JSHAREPlatformFacebookMessenger;
    }else if ([platformName isEqualToString:@"twitter"]) {
        platform = JSHAREPlatformTwitter;
    }else {
        platform = JSHAREPlatformWechatSession;
    }
    return platform;
}
- (JSHAREMediaType)getShareType:(NSString *)typeName {
    JSHAREMediaType type = JSHAREUndefined;
    if ([typeName isEqualToString:@"text"]) {
        type = JSHAREText;
    }else if ([typeName isEqualToString:@"image"]) {
        type = JSHAREImage;
    }else if ([typeName isEqualToString:@"link"]) {
        type = JSHARELink;
    }else if ([typeName isEqualToString:@"audio"]) {
        type = JSHAREAudio;
    }else if ([typeName isEqualToString:@"video"]) {
        type = JSHAREVideo;
    }else if ([typeName isEqualToString:@"app"]) {
        type = JSHAREApp;
    }else if ([typeName isEqualToString:@"file"]) {
        type = JSHAREFile;
    }else if ([typeName isEqualToString:@"emoticon"]) {
        type = JSHAREEmoticon;
    }else if ([typeName isEqualToString:@"miniProgram"]) {
        type = JSHAREMiniProgram;
    }else{
        type = JSHAREUndefined;
    }
    return type;
}

+ (void)handleOpenUrl:(NSURL *)url {
    [JSHAREService handleOpenUrl:url];
}
#pragma mark - UIApplication delegate
//目前适用所有 iOS 系统
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    [JSHAREService handleOpenUrl:url];
    return YES;
}

//仅支持 iOS9 以上系统，iOS8 及以下系统不会回调
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    [JSHAREService handleOpenUrl:url];
    return YES;
}
@end
