import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:jshare_flutter_plugin/jshare_flutter_plugin.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  List<Map<String, dynamic>> platfromList = [
    {
      "name": "微信",
      "icon": "jiguang_socialize_wechat.png",
      "platform": JSharePlatform.wechatSession
    },
    {
      "name": "朋友圈",
      "icon": "jiguang_socialize_wxtimeLine.png",
      "platform": JSharePlatform.wechatTimeLine
    },
    {
      "name": "微信收藏",
      "icon": "jiguang_socialize_wxfavorite.png",
      "platform": JSharePlatform.wechatFavourite
    },
    {
      "name": "QQ",
      "icon": "jiguang_socialize_qq.png",
      "platform": JSharePlatform.qq
    },
    {
      "name": "QQ空间",
      "icon": "jiguang_socialize_qzone.png",
      "platform": JSharePlatform.qZone
    },
    {
      "name": "微博",
      "icon": "jiguang_socialize_sina.png",
      "platform": JSharePlatform.sinaWeibo
    },
    {
      "name": "FaceBook",
      "icon": "jiguang_socialize_facebook.png",
      "platform": JSharePlatform.facebook
    },
    {
      "name": "Twitter",
      "icon": "jiguang_socialize_twitter.png",
      "platform": JSharePlatform.twitter
    }
  ];

  String _resultString = "显示结果";

  JShare jShare = new JShare();
  JShareType shareType;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {

    JShareConfig shareConfig = new JShareConfig(appKey: null);/// 填写自己应用的极光 AppKey

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

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: new Scaffold(
      appBar: new AppBar(title: new Text("")),
      body: new Center(
        child: new Builder(builder: (BuildContext context) {
          return new Column(
            children: <Widget>[
              new Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                color: Colors.brown,
                child: Text(_resultString),
                width: 300,
                height: 100,
              ),
              new Container(
                margin: EdgeInsets.all(10),
                //color: Colors.brown,
                child: new Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: new CustomButton(
                        title: "分享【文本】",
                        onPressed: () {
                          _showSheet(context, JShareType.text);
                        },
                      ),
                    ),
                    new Text(" "),
                    Expanded(
                      flex: 1,
                      child: new CustomButton(
                        title: "分享【图片】",
                        onPressed: () {
                          _showSheet(context, JShareType.image);
                        },
                      ),
                    ),
                    new Text(" "),
                    Expanded(
                      flex: 1,
                      child: new CustomButton(
                        title: "分享【链接】",
                        onPressed: () {
                          _showSheet(context, JShareType.link);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              new Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: new Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: new CustomButton(
                          title: "分享【音乐】",
                          onPressed: () {
                            _showSheet(context, JShareType.audio);
                          },
                        ),
                      ),
                      new Text(" "),
                      Expanded(
                        flex: 1,
                        child: new CustomButton(
                          title: "分享【视频】",
                          onPressed: () {
                            _showSheet(context, JShareType.video);
                          },
                        ),
                      ),
                      new Text(" "),
                      Expanded(
                        flex: 1,
                        child: new CustomButton(
                          title: "分享【APP】",
                          onPressed: () {
                            _showSheet(context, JShareType.app);
                          },
                        ),
                      ),
                    ],
                  )),
              new CustomButton(
                title: "分享【小程序】",
                onPressed: () {
                  _showSheet(context, JShareType.miniProgram);
                },
              ),
              new Divider(height: 10,color: Colors.brown),
              new Text("以下示例以【微信】为例"),
              new Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: new Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: new CustomButton(
                        title: "是否授权",
                        onPressed: () {
                          jShare.isPlatformAuth(platform: JSharePlatform.wechatSession).then((JShareResponse response){
                            setState(() {
                              _resultString = "是否授权：" + response.toJsonMap().toString();
                            });
                          }).catchError((error){
                            setState(() {
                              _resultString = "是否授权：" + error.toString();
                            });
                          });
                        },
                      ),
                    ),
                    new Text(" "),
                    Expanded(
                      flex: 1,
                      child: new CustomButton(
                        title: "授权",
                        onPressed: () {
                          jShare.authorize(platform: JSharePlatform.wechatSession).then((JShareSocial value){
                            setState(() {
                              _resultString = "授权：" + value.toJsonMap().toString();
                            });
                          }).catchError((error){
                            setState(() {
                              _resultString = "授权：" + error.toString();
                            });
                          });
                        },
                      ),
                    ),
                    new Text(" "),
                    Expanded(
                      flex: 1,
                      child: new CustomButton(
                        title: "取消授权",
                        onPressed: () {
                          jShare.cancelPlatformAuth(platform: JSharePlatform.wechatSession).then((JShareResponse response){
                            setState(() {
                              _resultString = "取消授权：" + response.toJsonMap().toString();
                            });
                          }).catchError((error){
                            setState(() {
                              _resultString = "取消授权：" + error.toString();
                            });
                          });
                        },
                      ),
                    ),
                  ],
                )
              ),
              new CustomButton(
                title: "获取【用户信息】",
                onPressed: () {
                  jShare.getUserInfo(platform: JSharePlatform.wechatSession).then((JShareUserInfo info){
                    setState(() {
                      _resultString = "获取用户信息：" + info.toJsonMap().toString();
                    });
                  }).catchError((error){
                    setState(() {
                      _resultString = "获取用户信息：" + error.toString();
                    });
                  });
                },
              ),
            ],
          );
        }),
      ),
    ));
  }


  Widget _showSheet(BuildContext context, JShareType type) {
    shareType = type;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return _shareWidget(context);
        });
  }

  Widget _shareWidget(BuildContext context) {
    return new Container(
      height: 300,
      color: Colors.white,
      child: new Column(
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: new Container(
              height: 200,
              child: new GridView.builder(
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 5.0,
                    childAspectRatio: 1.0),
                itemBuilder: (BuildContext context, int index) {
                  return new Column(
                    children: <Widget>[
                      new Padding(
                          padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
                          child: new GestureDetector(
                            child: new Image.asset(
                              'assets/images/${platfromList[index]["icon"]}',
                              width: 50,
                              height: 50,
                              fit: BoxFit.fill,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              _didSelectPlatform(index: index);
                            },
                          )),
                      new Text(platfromList[index]["name"]),
                    ],
                  );
                },
                itemCount: platfromList.length,
              ),
            ),
          ),
          new Divider(height: 0.5, color: Colors.blueGrey),
          new Center(
            child: new Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: new GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text(
                      "取 消",
                      style:
                          new TextStyle(fontSize: 20.0, color: Colors.blueGrey),
                    ))),
          ),
        ],
      ),
    );
  }

  /// 选择摸个平台分享
  void _didSelectPlatform({@required int index}) async {
    print("Action - didSelectPlatform:  " +
        "platfrom = " +
        platfromList[index].toString());

    JShareMessage message = new JShareMessage();
    message.mediaType = shareType;
    message.platform = platfromList[index]["platform"];

    if (message.platform != JSharePlatform.sinaWeibo) {
      // 新浪可以支持网页分享
      bool isValid = await jShare.isClientValid(platform: message.platform);
      if (isValid == false) {
        print("is not available platfrom (" +
            platfromList[index].toString() +
            ")");
        return;
      }
    }

    message.text = "jshare-text";
    message.title = "jshare-title";
    message.url = "https://www.jiguang.cn/";

    /// 添加 测试图片
    String tempImagePath = await _tempSaveTestImage();

    if (shareType == JShareType.image) {
      //大图
      message.imagePath = tempImagePath;
    } else {
      //缩略图
      message.imagePath = tempImagePath;
    }

    if (shareType == JShareType.audio) {
      //音频跳转链接
      message.url = "https://y.qq.com/n/yqq/song/003RCA7t0y6du5.html";
      // 音频源链接，直接播放
      // message.musicDataUrl = "";
    } else if (shareType == JShareType.video) {
      //视频源
      if (message.platform == JSharePlatform.qZone ||
          message.platform == JSharePlatform.facebook ||
          message.platform == JSharePlatform.facebookMessenger ||
          message.platform == JSharePlatform.twitter) {
        //message.videoPath = "";Android 为本地路径，iOS 为ALAsset的ALAssetPropertyAssetURL
      } else {
        message.url = "http://v.youku.com/v_show/id_XOTQwMDE1ODAw.html?from=s1.8-1-1.2&spm=a2h0k.8191407.0.0";
      }
    } else if (shareType == JShareType.link) {
      //分享网页链接
      //
    } else if (shareType == JShareType.app) {
      //message.fileDataPath = ""; iOS 端 APP 数据
      message.extInfo = "<xml>extend info</xml>";
    } else if (shareType == JShareType.file) {
      // message.fileDataPath = "";
      //message.fileExt = "";
    } else if (shareType == JShareType.emoticon) {
      // message.emoticonDataPath =
    } else if (shareType == JShareType.miniProgram) {
      message.miniProgramUserName = "gh_cd370c00d3d4";
      message.miniProgramPath = "pages/index/index";
      message.miniProgramType = 0;
      message.miniProgramWithShareTicket = true;
      // 小程序封面图
      //message.imageUrl = "https://img2.3lian.com/2014/f5/63/d/23.jpg";
    } else {}

    jShare.shareMessage(message: message).then((JShareResponse response) {
      print("分享回调：" + response.toJsonMap().toString());
      setState(() {
        _resultString = "分享成功："+ response.toJsonMap().toString();
      });
      /// 删除测试图片
      _tempDeleteTestImage();
    }).catchError((error) {
      print("分享回调 -- 出错：${error.toString()}");

      setState(() {
        _resultString = "分享失败："+ error.toString();
      });

      /// 删除测试图片
      _tempDeleteTestImage();
    });
  }


  /// TEST : 测试图片
  static String testImageName = "icon_jiguang.png";

  Future<String> _tempSaveTestImage() async {
    print("Action - _tempSaveTestImage:");
    final Directory directory = await getTemporaryDirectory();

    Uint8List bytes = await _getAssetsImageBytes(testImageName);
    String path = await _saveFile(directory, testImageName, bytes);

    return path;
  }

  /// TEST : 删除图片
  void _tempDeleteTestImage() async {
    print("Action - _tempDeleteTestImage:");
    final Directory directory = await getTemporaryDirectory();
    String imageName = testImageName;
    _deleteFile(directory, imageName);
  }


  /// TEST : 获取 assets里的图片（测试暂时用 assets 里的）
  Future<Uint8List> _getAssetsImageBytes(String imagePath) async {
    print("Action - getAssetsImageBytes:" + imagePath);

    ByteData byteData = await rootBundle.load("assets/images/"+imagePath);
    Uint8List uint8list = byteData.buffer.asUint8List();

    return uint8list;
  }

  /// TEST : 存储文件
  Future<String> _saveFile(Directory directory, String name, Uint8List bytes) async {
    print("Action - _saveFile:" + "directory:" + directory.toString() + ",name:" + name);
    final File file = File('${directory.path}/$name');

    if (file.existsSync()) {
      file.deleteSync();
    }

    File file1 = await file.writeAsBytes(bytes);

    if(file1.existsSync()) {
      print('====保存成功');
    }else{
      print('====保存失败');
    }
    return file1.path;
  }

  /// TEST : 获取文件路径
  String _getFilePath(Directory directory, String name){
    print("Action - _getFilePath:");
    final File file = File('${directory.path}/$name');
    if (!file.existsSync()) {
      return null;
    }
    String path = file.readAsStringSync();
    return path;
  }

  /// TEST : 删除文件
  void _deleteFile(Directory directory, String name) {
    print("Action - _deleteFile:");
    final File file = File('${directory.path}/$name');

    if (file.existsSync()) {
      file.deleteSync();
    }
  }
}



/// 封装 按钮
class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  const CustomButton({@required this.onPressed, this.title});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new FlatButton(
      onPressed: onPressed,
      child: new Text("$title"),
      color: Color(0xff585858),
      highlightColor: Color(0xff888888),
      splashColor: Color(0xff888888),
      textColor: Colors.white,
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
    );
  }
}
