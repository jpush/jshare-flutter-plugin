## 接口文档

#### 初始化

```
JShare jShare = new JShare();
JShareConfig shareConfig = new JShareConfig(appKey: "ef4be2a0dec95dfd22402d45");
shareConfig.channel = "channel";
shareConfig.isDebug = true;
shareConfig.isAdvertisinId = true;
shareConfig.isProduction = true;

shareConfig.weChatAppId = "wxc40e16f3ba6ebabc";
shareConfig.weChatAppSecret = "dcad950cd0633a27e353477c4ec12e7a";

shareConfig.qqAppId = "100424468";
shareConfig.qqAppKey = "glFYjkHQGSOCJHMC";

shareConfig.sinaWeiboAppKey = "374535501";
shareConfig.sinaWeiboAppSecret = "baccd12c166f1df96736b51ffbf600a2";
shareConfig.sinaRedirectUri = "https://www.jiguang.cn";

shareConfig.facebookAppID = "1847959632183996";
shareConfig.facebookDisplayName = "JShareDemo";

shareConfig.twitterConsumerKey = "4hCeIip1cpTk9oPYeCbYKhVWi";
shareConfig.twitterConsumerSecret =
    "DuIontT8KPSmO2Y1oAvby7tpbWHJimuakpbiAUHEKncbffekmC";

jShare.setup(config: shareConfig);

```

#### 分享

```
JShareMessage message = new JShareMessage();
message.mediaType = JShareType.text;
message.platform = JSharePlatform.wechatSession;
message.text = "jshare-text";
message.title = "jshare-title";
····

jShare.shareMessage(message: message).then((JShareResponse response) {
  print("分享回调：" + response.toJsonMap().toString());
}).catchError((error) {
  print("分享回调 -- 出错：${error.toString()}");
});

```

#### 授权

```
jShare.authorize(platform: JSharePlatform.wechatSession).then((JShareSocial value){
	setState(() {
	  _resultString = "授权：" + value.toJsonMap().toString();
	});
}).catchError((error){
	setState(() {
	  _resultString = "授权：" + error.toString();
	});
});
```

#### 判断是否授权

```
jShare.isPlatformAuth(platform: JSharePlatform.wechatSession).then((JShareResponse response){
	setState(() {
	  _resultString = "是否授权：" + response.toJsonMap().toString();
	});
}).catchError((error){
	setState(() {
	  _resultString = "是否授权：" + error.toString();
	});
});
```

#### 取消授权

```
jShare.cancelPlatformAuth(platform: JSharePlatform.wechatSession).then((JShareResponse response){
	setState(() {
	  _resultString = "取消授权：" + response.toJsonMap().toString();
	});
}).catchError((error){
	setState(() {
	  _resultString = "取消授权：" + error.toString();
	});
});
```

#### 获取用户信息

```
jShare.getUserInfo(platform: JSharePlatform.wechatSession).then((JShareUserInfo info){
	setState(() {
	  _resultString = "获取用户信息：" + info.toJsonMap().toString();
	});
}).catchError((error){
	setState(() {
	  _resultString = "获取用户信息：" + error.toString();
	});
});
```

#### 判断平台分享是否有效

```
bool isValid = await jShare.isClientValid(platform: JSharePlatform.wechatSession);
```

#### 基础类

##### 初始化配置类
初始化所必须的一些配置

```
/// 初始化配置
class JShareConfig {
  bool isDebug = false;
  String channel;
  bool isAdvertisinId = false;
  bool isProduction = false;
  String appKey; // 极光平台 AppKey
  String weChatAppId;
  String weChatAppSecret;
  String qqAppId;
  String qqAppKey;
  String sinaWeiboAppKey;
  String sinaWeiboAppSecret;
  String sinaRedirectUri;
  String facebookAppID;
  String facebookDisplayName;
  String twitterConsumerKey;
  String twitterConsumerSecret;
}
```

##### 分享消息类
分享内容都将封装成 JShareMessage 类型，注意每个平台所支持的分享内容不同。

```
class JShareMessage {
  /// 标题：长度每个平台的限制而不同
  String title;
  /// 文本：文本内容，长度每个平台的限制而不同。在分享非文本类型时，此字段作为分享内容的描述使用
  String text;
  /// 链接：根据媒体类型填入链接，长度每个平台的限制不同。分享非文本及非图片类型时，必要！(音乐跳转url、视频url、网页url)
  String url;
  /// 图片路径
  String imagePath;
  /// 本地视频：仅支持 QZone、Twitter、Facebook、Facebook Messenger, iOS 端要传 ALAsset的ALAssetPropertyAssetURL; 其他平台通过 url 分享视频
  String videoPath;
  /// 分享 music 类型至微信平台或QQ平台时，音乐数据源url，点击可直接播放。
  String musicDataUrl;

  /// 分享 App 类型至微信平台时，第三方程序自定义的简单数据，only for ios
  String extInfo;
  /// 分享 File 或者 App 类型时，对应的File数据以及App数据，最大 10 M
  String fileDataPath;
  /// 分享 File 类型至微信平台时，对应的文件后缀名，分享文件必填，否则会导致分享到微信平台出现不一致的文件类型,最大 64 字符，only for ios
  String fileExt;

  /// 分享 Emoticon 类型至微信平台时，对应的表情数据，最大 10 M
  String emoticonDataPath;
  /// 分享至新浪微博平台时，分享参数的一个标识符，默认为 “objectId”。最大 255 字符
  String sinaObjectID;
  /// 微信小程序: 小程序username,如"gh_d43f693ca31f"
  String miniProgramUserName;
  /// 微信小程序: 小程序页面路径,如"pages/page10000/page10000"
  String miniProgramPath;
  /// 微信小程序: 小程序版本类型。 0正式版，1开发版，2体验版。默认0，正式版
  int miniProgramType = 0;
  /// 微信小程序: 是否使用带 shareTicket 的转发。默认false,不使用带 shareTicket 的转发
  bool miniProgramWithShareTicket = false;

  /// 分享的媒体类型。必要！
  JShareType mediaType;
  /// 分享的目标平台。必要！
  JSharePlatform platform;
}
```
##### 接口响应类

```
class JShareResponse {
  JShareCode code;/// 状态码
  String message; /// 返回提示
}
```

##### 平台授权信息类
继承于 `JShareResponse `

```
class JShareSocial extends JShareResponse {
  String openid;
  String token;
  String refreshToken;
  String expiration;
  Map originData ;
}
```

##### 平台用户信息类
继承于 `JShareResponse `

```
class JShareUserInfo extends JShareSocial {
  String name;
  String imageUrl;
  int gender;
}
```