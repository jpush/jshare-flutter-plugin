import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class JShare {
  final String flutterLog = "| JSHARE | Flutter | ";

  final MethodChannel _channel;

  factory JShare() => _instance;

  @visibleForTesting
  JShare.private(MethodChannel channel) : _channel = channel;
  static final _instance =
      new JShare.private(const MethodChannel("jshare_flutter_plugin"));

  /// 初始化
  void setup({JShareConfig? config}) {
    print(flutterLog + "setup：");

    if (config == null) {
      return;
    }

    if (config.appKey == null) {
      print(flutterLog + "JIGUANG appkey can not be null");
      return;
    }
    Map map = config.toJsonMap();
    _channel.invokeListMethod("setup", map);
  }

  /// 分享，
  Future<JShareResponse> shareMessage({required JShareMessage message}) async {
    print(flutterLog + "shareMessage：" + message.toJsonMap().toString());

    Map map = message.toJsonMap();
    Map<dynamic, dynamic>? resultMap = await (_channel.invokeMapMethod("shareMessage", map));
    JShareResponse response = JShareResponse.fromJson(resultMap);

    return response;
  }

  /// 授权
  Future<JShareSocial> authorize({required JSharePlatform platform}) async {
    print(flutterLog + "authorize：");

    Map map = Map();
    map["platform"] = getStringFromEnum(platform);
    Map<dynamic, dynamic>? resultMap = await (_channel.invokeMapMethod("authorize", map));

    JShareSocial social = JShareSocial.fromJson(resultMap);

    print(flutterLog + "authorize callback：" + social.toJsonMap().toString());

    return social;
  }

  /// 判断是否授权
  Future<JShareResponse> isPlatformAuth(
      {required JSharePlatform platform}) async {
    print(flutterLog + "isPlatformAuth：");

    Map map = Map();
    map["platform"] = getStringFromEnum(platform);
    Map<dynamic, dynamic>? resultMap =
        await (_channel.invokeMapMethod("isPlatformAuth", map));
    return JShareResponse.fromJson(resultMap);
  }

  /// 取消授权
  Future<JShareResponse> cancelPlatformAuth(
      {required JSharePlatform platform}) async {
    print(flutterLog + "cancelPlatformAuth：");

    Map map = Map();
    map["platform"] = getStringFromEnum(platform);
    Map<dynamic, dynamic>? resultMap =
        await (_channel.invokeMapMethod("cancelPlatformAuth", map));
    return JShareResponse.fromJson(resultMap);
  }

  /// 获取个人信息
  Future<JShareUserInfo> getUserInfo({required JSharePlatform platform}) async {
    print(flutterLog + "getUserInfo：");

    Map map = Map();
    map["platform"] = getStringFromEnum(platform);
    Map<dynamic, dynamic>? resultMap =
        await (_channel.invokeMapMethod("getUserInfo", map));
    JShareUserInfo userInfo = JShareUserInfo.fromJson(resultMap);

    print(
        flutterLog + "getUserInfo callback：" + userInfo.toJsonMap().toString());
    return userInfo;
  }

  /// 判断某平台分享是否有效
  Future<bool> isClientValid({required JSharePlatform platform}) async {
    print(flutterLog + "isClientValid：");

    Map map = Map();
    map["platform"] = getStringFromEnum(platform);
    Map<dynamic, dynamic>? resultMap = await (_channel.invokeMapMethod("isClientValid", map));
    JShareResponse response = JShareResponse.fromJson(resultMap);
    if (response.code == JShareCode.success) {
      return true;
    } else {
      return false;
    }
  }
}

/// 初始化配置
class JShareConfig {
  bool isDebug = false;
  String? channel;
  bool isAdvertisinId = false;
  bool isProduction = false;
  String? appKey; // 极光平台 AppKey
  String? weChatAppId;
  String? weChatAppSecret;
  String? qqAppId;
  String? qqAppKey;
  String? sinaWeiboAppKey;
  String? sinaWeiboAppSecret;
  String? sinaRedirectUri;
  String? facebookAppID;
  String? facebookDisplayName;
  String? twitterConsumerKey;
  String? twitterConsumerSecret;
  String? universalLink;

  JShareConfig({required String appKey}) {
    this.appKey = appKey;
  }

  Map toJsonMap() {
    return {
      "isDebug": isDebug,
      "channel": channel ??= null,
      "isAdvertisinId": isAdvertisinId,
      "isProduction": isProduction,
      "appKey": appKey ??= null,
      "weChatAppId": weChatAppId ??= null,
      "weChatAppSecret": weChatAppSecret ??= null,
      "qqAppId": qqAppId ??= null,
      "qqAppKey": qqAppKey ??= null,
      "sinaWeiboAppKey": sinaWeiboAppKey ??= null,
      "sinaWeiboAppSecret": sinaWeiboAppSecret ??= null,
      "sinaRedirectUri": sinaRedirectUri ??= null,
      "facebookAppID": facebookAppID ??= null,
      "facebookDisplayName": facebookDisplayName ??= null,
      "twitterConsumerKey": twitterConsumerKey ??= null,
      "twitterConsumerSecret": twitterConsumerSecret ??= null,
      "universalLink": universalLink ??= null,
    }..removeWhere((key, value) => value == null);
  }
}

class JShareResponse {
  JShareCode? code;

  /// 状态码
  String? message;

  /// 返回提示

  JShareResponse();

  JShareResponse.fromJson(Map<dynamic, dynamic>? json)
      : code = getEnumFromString(JShareCode.values, json?["code"]),
        message = json?["message"];

  Map toJsonMap() {
    return {
      "code": getStringFromEnum(code),
      "message": message ??= null,
    }..removeWhere((key, value) => value == null);
  }
}

class JShareSocial extends JShareResponse {
  String? openid;
  String? token;
  String? refreshToken;
  String? expiration;
  Map? originData;

  JShareSocial.fromJson(Map<dynamic, dynamic>? jsonMap)
      : openid = jsonMap?["openid"],
        token = jsonMap?["token"],
        refreshToken = jsonMap?["refreshToken"],
        expiration = jsonMap?["expiration"],
        originData = jsonMap?["originData"] != null
            ? json.decode(jsonMap?["originData"])
            : null,
        super.fromJson(jsonMap);

  Map toJsonMap() {
    Map map = super.toJsonMap();
    map.addAll({
      "openid": openid ??= null,
      "token": token ??= null,
      "refreshToken": refreshToken ??= null,
      "expiration": expiration ??= null,
      "originData": originData ??= null,
    });
    return map..removeWhere((key, value) => value == null);
  }
}

class JShareUserInfo extends JShareSocial {
  String? name;
  String? imageUrl;
  int? gender;

  JShareUserInfo.fromJson(Map<dynamic, dynamic>? json)
      : name = json?["name"],
        imageUrl = json?["imageUrl"],
        gender = json?["gender"],
        super.fromJson(json);

  Map toJsonMap() {
    Map map = super.toJsonMap();
    map.addAll({
      "openid": openid ??= null,
      "token": token ??= null,
      "refreshToken": refreshToken ??= null,
      "expiration": expiration ??= null,
      "originData": originData ??= null,
      "name": name ??= null,
      "imageUrl": imageUrl ??= null,
      "gender": gender,
    });
    return map..removeWhere((key, value) => value == null);
  }
}

class JShareMessage {
  /// 标题：长度每个平台的限制而不同
  String? title;

  /// 文本：文本内容，长度每个平台的限制而不同。在分享非文本类型时，此字段作为分享内容的描述使用
  String? text;

  /// 链接：根据媒体类型填入链接，长度每个平台的限制不同。分享非文本及非图片类型时，必要！(音乐跳转url、视频url、网页url)
  String? url;

  /// 图片路径
  String? imagePath;

  /// 本地视频：仅支持 QZone、Twitter、Facebook、Facebook Messenger, iOS 端要传 ALAsset的ALAssetPropertyAssetURL; 其他平台通过 url 分享视频
  String? videoPath;

  /// 分享 music 类型至微信平台或QQ平台时，音乐数据源url，点击可直接播放。
  String? musicDataUrl;

  /// 分享 App 类型至微信平台时，第三方程序自定义的简单数据，only for ios
  String? extInfo;

  /// 分享 File 或者 App 类型时，对应的File数据以及App数据，最大 10 M
  String? fileDataPath;

  /// 分享 File 类型至微信平台时，对应的文件后缀名，分享文件必填，否则会导致分享到微信平台出现不一致的文件类型,最大 64 字符，only for ios
  String? fileExt;

  /// 分享 Emoticon 类型至微信平台时，对应的表情数据，最大 10 M
  String? emoticonDataPath;

  /// 分享至新浪微博平台时，分享参数的一个标识符，默认为 “objectId”。最大 255 字符
  String? sinaObjectID;

  /// 微信小程序: 小程序username,如"gh_d43f693ca31f"
  String? miniProgramUserName;

  /// 微信小程序: 小程序页面路径,如"pages/page10000/page10000"
  String? miniProgramPath;

  /// 微信小程序: 小程序版本类型。 0正式版，1开发版，2体验版。默认0，正式版
  int miniProgramType = 0;

  /// 微信小程序: 是否使用带 shareTicket 的转发。默认false,不使用带 shareTicket 的转发
  bool miniProgramWithShareTicket = false;

  /// 分享的媒体类型。必要！
  JShareType? mediaType;

  /// 分享的目标平台。必要！
  JSharePlatform? platform;

  Map toJsonMap() {
    return {
      "title": title ??= null,
      "text": text ??= null,
      "url": url ??= null,
      "videoPath": videoPath ??= null,
      "imagePath": imagePath ??= null,
      "musicDataUrl": musicDataUrl ??= null,
      "extInfo": extInfo ??= null,
      "fileDataPath": fileDataPath ??= null,
      "fileExt": fileExt ??= null,
      "emoticonDataPath": emoticonDataPath ??= null,
      "sinaObjectID": sinaObjectID ??= null,
      "miniProgramUserName": miniProgramUserName ??= null,
      "miniProgramPath": miniProgramPath,
      "miniProgramType": miniProgramType,
      "miniProgramWithShareTicket": miniProgramWithShareTicket,
      "mediaType": getStringFromEnum(mediaType),
      "platform": getStringFromEnum(platform),
    }..removeWhere((key, value) => value == null);
  }
}

enum JSharePlatform {
  wechatSession,
  wechatTimeLine,
  wechatFavourite,
  qq,
  qZone,
  sinaWeibo,
  sinaWeiboContact,
  facebook,
  facebookMessenger,
  twitter
}

/// 接口的状态码，
enum JShareCode {
  /// 成功
  success,

  /// 取消
  cancel,

  /// 失败
  fail
}

enum JShareType {
  text,
  image,
  link,
  audio,
  video,
  app,
  file,
  emoticon,
  miniProgram,
}

String? getStringFromEnum<T>(T) {
  if (T == null) {
    return null;
  }

  return T.toString().split('.').last;
}

T? getEnumFromString<T>(Iterable<T> values, String? str) {
  return values.firstWhereOrNull((f) => f.toString().split('.').last == str);
}
