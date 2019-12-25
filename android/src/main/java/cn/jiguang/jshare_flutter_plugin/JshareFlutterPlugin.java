package cn.jiguang.jshare_flutter_plugin;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.nfc.Tag;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import cn.jiguang.share.android.api.AuthListener;
import cn.jiguang.share.android.api.JShareInterface;
import cn.jiguang.share.android.api.PlatActionListener;
import cn.jiguang.share.android.api.Platform;
import cn.jiguang.share.android.api.PlatformConfig;
import cn.jiguang.share.android.api.ShareParams;
import cn.jiguang.share.android.model.AccessTokenInfo;
import cn.jiguang.share.android.model.BaseResponseInfo;
import cn.jiguang.share.android.model.UserInfo;
import cn.jiguang.share.android.utils.FileUtils;
import cn.jiguang.share.facebook.Facebook;
import cn.jiguang.share.facebook.messenger.FbMessenger;
import cn.jiguang.share.qqmodel.QQ;
import cn.jiguang.share.qqmodel.QZone;
import cn.jiguang.share.twitter.Twitter;
import cn.jiguang.share.wechat.Wechat;
import cn.jiguang.share.wechat.WechatFavorite;
import cn.jiguang.share.wechat.WechatMoments;
import cn.jiguang.share.weibo.SinaWeibo;
import cn.jiguang.share.weibo.SinaWeiboMessage;
import cn.jiguang.share.wechat.WeChatHandleActivity;
import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** JshareFlutterPlugin */
public class JshareFlutterPlugin implements MethodCallHandler {

  // 定义日志 TAG
  private  static  final String TAG = "| JSHARE | Android | - ";
  private static  String  j_code_key = "code";
  /// 回调的提示信息，统一返回 flutter 为 message
  private static  String  j_msg_key  = "message";
  // 成功
  private static String j_success_code = "success";
  // 取消
  private static String j_cancel_code = "cancel";
  private static String j_fail_code ="fail";

  private Context context;
  private Registrar registrar;
  private MethodChannel channel;


  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "jshare_flutter_plugin");
    channel.setMethodCallHandler(new JshareFlutterPlugin(registrar,channel));
  }

  private JshareFlutterPlugin(Registrar registrar,MethodChannel channel){
    this.registrar = registrar;
    this.context = registrar.context();
    this.channel = channel;
  }

  ExecutorService exec = Executors.newSingleThreadExecutor();

  @Override
  public void onMethodCall(final MethodCall call,final Result result) {
    Log.d(TAG,"onMethodCall:" + call.method);

    if (call.method.equals("setup")){
      setup(call, result);
    } else if (call.method.equals("shareMessage")){
      shareMessage(call, result);
//      exec.execute(new Runnable() {
//        @Override
//        public void run() {
//          Log.d(TAG,"Action - shareMessage - run" );
//
//        }
//      });
      //exec.shutdown();

    } else if (call.method.equals("authorize")) {
      authorize(call, result);
    } else if (call.method.equals("isClientValid")) {
      isClientValid(call, result);
    } else if (call.method.equals("isPlatformAuth")) {
      isPlatformAuth(call, result);
    } else if (call.method.equals("cancelPlatformAuth")) {
      cancelPlatformAuth(call, result);
    } else if (call.method.equals("getUserInfo")) {
      getUserInfo(call, result);
    }
    else if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }


  private void setup(MethodCall call, Result result) {

    Boolean isDebug = call.argument("isDebug");
    String appKey = call.argument("appKey");
    String weChatAppId = call.argument("weChatAppId");
    String weChatAppSecret = call.argument("weChatAppSecret");
    String qqAppId = call.argument("qqAppId");
    String qqAppKey = call.argument("qqAppKey");
    String sinaWeiboAppKey = call.argument("sinaWeiboAppKey");
    String sinaWeiboAppSecret = call.argument("sinaWeiboAppSecret");
    String sinaRedirectUri = call.argument("sinaRedirectUri");
    String facebookAppID = call.argument("facebookAppID");
    String facebookDisplayName = call.argument("facebookDisplayName");
    String twitterConsumerKey = call.argument("twitterConsumerKey");
    String twitterConsumerSecret = call.argument("twitterConsumerSecret");


    JShareInterface.setDebugMode(isDebug);

    PlatformConfig platformConfig = new PlatformConfig();
    platformConfig.setWechat(weChatAppId,weChatAppSecret);
    platformConfig.setQQ(qqAppId,qqAppKey);
    platformConfig.setSinaWeibo(sinaWeiboAppKey,sinaWeiboAppSecret,sinaRedirectUri);
    platformConfig.setFacebook(facebookAppID,facebookDisplayName);
    platformConfig.setTwitter(twitterConsumerKey,twitterConsumerSecret);

    JShareInterface.init(context, platformConfig);
  }

  private void isClientValid(MethodCall call, Result result) {
    Log.d(TAG,"Action - isClientValid:" );
    String para_platform = call.argument("platform");
    final String platformName = JShareMessage.getPlatform(para_platform);
    boolean isValid = JShareInterface.isClientValid(platformName);

    final Map<String,Object> map = new HashMap<>();
    map.put(j_code_key,isValid?j_success_code:j_fail_code);
    map.put(j_msg_key,"");

    runMainThread(map, result);
  }

  private void shareMessage(MethodCall call,final Result result) {
    Log.d(TAG,"Action - shareMessage:" );

    JShareMessage message = new JShareMessage((Map<String, Object>) call.arguments);
    if (message.platform == null) {
      return;
    }

    ShareParams shareParams = new ShareParams();
    shareParams.setShareType(message.shareType);

    if (message.title != null){
      shareParams.setTitle(message.title);
    }
    if (message.text != null){
      shareParams.setText(message.text);
    }
    if (message.url != null) {
      shareParams.setUrl(message.url);
    }


    // 分享图片、emoji 表情、其他类型的缩略图
    if (message.imagePath != null) {
      shareParams.setImagePath(message.imagePath);
    }

    // 音乐源url
    if (message.musicDataUrl != null){
      shareParams.setMusicUrl(message.musicDataUrl);
    }

    // 支持分享视频: 微信、QZone（本地视频）、FB（本地视频）、Twitter（本地视频）
    if (message.videoPath != null){
      shareParams.setVideoPath(message.videoPath);
    }

    // 支持分享文件 ： 微信（朋友圈、微信收藏不支持）
    if (message.platform == Wechat.Name ) {
      if (message.fileDataPath != null){
        shareParams.setFilePath(message.fileDataPath);
      }
    }

    // 分享小程序,支持分享小程序 ： 微信（朋友圈、微信收藏不支持）
    if (message.shareType == Platform.SHARE_MINI_PROGRAM) {
      if (message.platform == Wechat.Name ) {
        if (message.miniProgramPath != null) {
          shareParams.setMiniProgramPath(message.miniProgramPath);
        }
        if (message.miniProgramUserName != null) {
          shareParams.setMiniProgramUserName(message.miniProgramUserName);
        }
        if (message.miniProgramWithShareTicket != null) {
          shareParams.setMiniProgramWithShareTicket(message.miniProgramWithShareTicket);
        }
        if (message.imagePath != null){
          shareParams.setMiniProgramImagePath(message.imagePath);
        }
        shareParams.setMiniProgramType(message.miniProgramType);
      }
    }

    JShareInterface.share(message.platform, shareParams, new PlatActionListener() {
      @Override
      public void onComplete(Platform platform, int action, HashMap<String, Object> hashMap) {
        Log.d(TAG,"Action - shareMessage - onComplete" );
        // 分享成功
        final Map<String,Object> map = new HashMap<>();
        map.put(j_code_key,j_success_code);
        map.put(j_msg_key,"分享成功");
        runMainThread(map, result);
      }

      @Override
      public void onError(Platform platform, int action, int errorCode, Throwable throwable) {
        Log.d(TAG,"Action - shareMessage - onError" );
        // 分享失败
        final Map<String,Object> map = new HashMap<>();
        map.put(j_code_key,errorCode);
        map.put(j_msg_key,"分享失败");
        runMainThread(map, result);
      }

      @Override
      public void onCancel(Platform platform, int action) {
        Log.d(TAG,"Action - shareMessage - onCancel" );
        // 分享取消
        final Map<String,Object> map = new HashMap<>();
        map.put(j_code_key,j_cancel_code);
        map.put(j_msg_key,"分享取消");
        runMainThread(map, result);
      }
    });

  }

  private void authorize(MethodCall call, final Result result){

    String para_platform = call.argument("platform");
    final String platformName = JShareMessage.getPlatform(para_platform);

    JShareInterface.authorize(platformName, new AuthListener() {
      @Override
      public void onComplete(Platform platform, int action, BaseResponseInfo data) {
        Log.d(TAG, "onComplete:" + platform + ",action:" + action + ",data:" + data);
        final Map<String,Object> map = new HashMap<>();
        map.put(j_code_key,j_success_code);

        String toastMsg = null;
        if (action == Platform.ACTION_AUTHORIZING){
          if (data instanceof AccessTokenInfo) {        //授权信息
            String token = ((AccessTokenInfo) data).getToken();//token
            long expiration = ((AccessTokenInfo) data).getExpiresIn();//token有效时间，时间戳
            String refresh_token = ((AccessTokenInfo) data).getRefeshToken();//refresh_token
            String openid = ((AccessTokenInfo) data).getOpenid();//openid

            //授权原始数据，开发者可自行处理
            String originData = data.getOriginData();
            toastMsg = "授权成功:" + data.toString();

            Log.d(TAG, "openid:" + openid + ",token:" + token + ",expiration:" + expiration + ",refresh_token:" + refresh_token);
            Log.d(TAG, "originData:" + originData);

            if (token != null) {
              map.put("token",token);
            }
            if (refresh_token != null) {
              map.put("refreshToken",refresh_token);
            }
            if (openid != null) {
              map.put("openid",openid);
            }
            if (originData != null) {
              map.put("originData",originData);
            }

            map.put("expiration",Long.toString(expiration));
          }
        }
        runMainThread(map, result);
      }

      @Override
      public void onError(Platform platform, int action, int errorCode, Throwable throwable) {
        String toastMsg = null;
        if (action == Platform.ACTION_AUTHORIZING) {
          toastMsg = "授权失败";
        }
        final Map<String,Object> map = new HashMap<>();
        map.put(j_code_key,errorCode);
        map.put(j_msg_key,toastMsg);

        runMainThread(map, result);
      }

      @Override
      public void onCancel(Platform platform, int action) {
        Log.d(TAG, "onCancel:" + platform + ",action:" + action);
        String toastMsg = null;
        if (action == Platform.ACTION_AUTHORIZING) {
          toastMsg = "取消授权";
        }

        final Map<String,Object> map = new HashMap<>();
        map.put(j_code_key,j_cancel_code);
        map.put(j_msg_key,toastMsg);

        runMainThread(map, result);
      }
    });
  }

  // 判断是否授权
  private void isPlatformAuth(MethodCall call, final Result result) {
    String platformName = call.argument("platform");
    String platform = JShareMessage.getPlatform(platformName);
    boolean isAuth = JShareInterface.isAuthorize(platform);

    final Map<String,Object> map = new HashMap<>();
    map.put(j_code_key,j_success_code);
    map.put(j_msg_key,isAuth?"已经授权":"未授权");
    runMainThread(map,result);
  }

  ///取消授权
  private void cancelPlatformAuth(MethodCall call, final Result result) {
    String platformName = call.argument("platform");
    String platform = JShareMessage.getPlatform(platformName);

    JShareInterface.removeAuthorize(platform, new AuthListener() {
      @Override
      public void onComplete(Platform platform, int action, BaseResponseInfo baseResponseInfo) {
        Log.d(TAG, "onComplete:" + platform + ",action:" + action + ",data:" + baseResponseInfo);
        String toastMsg = null;
        if (action == Platform.ACTION_REMOVE_AUTHORIZING) {
          toastMsg = "删除授权成功";
        }

        final Map<String,Object> map = new HashMap<>();
        map.put(j_code_key,j_success_code);
        map.put(j_msg_key,toastMsg);

        runMainThread(map, result);
      }

      @Override
      public void onError(Platform platform, int action, int errorCode, Throwable error) {
        Log.d(TAG, "onError:" + platform + ",action:" + action + ",error:" + error);
        String toastMsg = null;
        if (action == Platform.ACTION_REMOVE_AUTHORIZING) {
          toastMsg = "删除授权失败";
        }

        final Map<String,Object> map = new HashMap<>();
        map.put(j_code_key,errorCode);
        map.put(j_msg_key,toastMsg);

        runMainThread(map, result);
      }

      @Override
      public void onCancel(Platform platform, int action) {
        final Map<String,Object> map = new HashMap<>();
        map.put(j_code_key,j_cancel_code);
        map.put(j_msg_key,"放弃取消授权");

        runMainThread(map, result);
      }
    });
  }

  // 获取个人信息
  private void getUserInfo(MethodCall call, final Result result) {
    String platformName = call.argument("platform");
    String platform = JShareMessage.getPlatform(platformName);

    JShareInterface.getUserInfo(platform, new AuthListener() {
      @Override
      public void onComplete(Platform platform, int action, BaseResponseInfo info) {
        Log.d(TAG, "onComplete:" + platform + ",action:" + action + ",info:" + info);
        final Map<String,Object> map = new HashMap<>();
        map.put(j_code_key,j_success_code);

        String toastMsg = null;
        if (action == Platform.ACTION_USER_INFO) {
          if (info instanceof UserInfo) {      //第三方个人信息
            String openid = ((UserInfo) info).getOpenid();  //openid
            String name = ((UserInfo) info).getName();  //昵称
            String imageUrl = ((UserInfo) info).getImageUrl();  //头像url
            int gender = ((UserInfo) info).getGender();//性别, 1表示男性；2表示女性
            //个人信息原始数据，开发者可自行处理
            String originData = info.getOriginData();
            toastMsg = "获取个人信息成功:" + info.toString();
            Log.d(TAG, "openid:" + openid + ",name:" + name + ",gender:" + gender + ",imageUrl:" + imageUrl);
            Log.d(TAG, "originData:" + originData);

            if (openid != null) {
              map.put("openid",openid);
            }
            if (name != null) {
              map.put("name",name);
            }
            if (imageUrl != null) {
              map.put("imageUrl",imageUrl);
            }
            map.put("gender",gender);
            if (originData != null) {
              map.put("originData",originData);
            }
          }
        }
        runMainThread(map,result);
      }

      @Override
      public void onError(Platform platform, int action, int errorCode, Throwable error) {
        Log.d(TAG, "onError:" + platform + ",action:" + action + ",error:" + error);
        String toastMsg = null;
        if (action == Platform.ACTION_USER_INFO){
          toastMsg = "获取个人信息失败";
        }
        final Map<String,Object> map = new HashMap<>();
        map.put(j_code_key,errorCode);
        map.put(j_msg_key,toastMsg);
        runMainThread(map, result);
      }

      @Override
      public void onCancel(Platform platform, int action) {
        Log.d(TAG, "onCancel:" + platform + ",action:" + action);
        String toastMsg = null;
        if (action == Platform.ACTION_USER_INFO) {
          toastMsg = "取消获取个人信息";
        }
        final Map<String,Object> map = new HashMap<>();
        map.put(j_code_key,j_cancel_code);
        map.put(j_msg_key,toastMsg);
        runMainThread(map, result);
      }
    });
  }

  // 主线程再返回数据
  private void runMainThread(final Map<String,Object> map, final Result result) {
    Handler handler = new Handler(Looper.getMainLooper());
    handler.post(new Runnable() {
      @Override
      public void run() {
        result.success(map);
      }
    });
  }


  private Bitmap returnBitmapFromUrl(String url) {
    Log.d(TAG,"returnBitmapFromUrl: url = " + url);

    URL fileUrl = null;
    Bitmap bitmap = null;
    try {
      fileUrl = new URL(url);
    }catch (MalformedURLException e){
      e.printStackTrace();
      Log.d(TAG,"MalformedURLException ERROR:" + e);
    }

    try {
      HttpURLConnection connection = (HttpURLConnection)fileUrl.openConnection();
//      connection.setDoInput(true);
//      connection.connect();
      connection.setConnectTimeout(3000);
      Log.d(TAG,"download bitmap from url: - 1-" + connection.getResponseCode());
      InputStream is =  connection.getInputStream();
      Log.d(TAG,"download bitmap from url: - 2-" + connection.getResponseCode());

      bitmap = BitmapFactory.decodeStream(is);
      is.close();
    } catch (IOException e){
      e.printStackTrace();
      Log.d(TAG,"IOException ERROR:" + e);
    }
    Log.d(TAG,"bitmap" + bitmap);
    return bitmap;
  }

  private Bitmap byte2Bitmap(byte[] b){
    if(b.length != 0){
      return BitmapFactory.decodeByteArray(b, 0, b.length);
    } else{
      return null;
    }
  }
}

class JShareMessage {
  String title ;
  String text;
  String url ;
  String videoPath ;
  String imagePath ;
  //String imageUrl;
  String musicDataUrl;
  String extInfo ;
  String fileDataPath;
  String fileExt ;
  String emoticonDataPath ;
  String sinaObjectID ;
  String miniProgramUserName ;
  String miniProgramPath ;
  int miniProgramType ;
  Boolean miniProgramWithShareTicket;

  String platform;
  int shareType;

  public JShareMessage(Map<String,Object> argument){
    title = (String)argument.get("title");
    text = (String)argument.get("text");
    url = (String)argument.get("url");
    videoPath = (String)argument.get("videoPath");
    imagePath = (String) argument.get("imagePath");
    //imageUrl = (String)argument.get("imageUrl");

    musicDataUrl = (String)argument.get("musicDataUrl");
    extInfo = (String)argument.get("extInfo");
    fileDataPath = (String)argument.get("fileDataPath");
    fileExt = (String)argument.get("fileExt");
    emoticonDataPath = (String)argument.get("emoticonDataPath");
    sinaObjectID = (String)argument.get("sinaObjectID");
    miniProgramUserName = (String)argument.get("miniProgramUserName");
    miniProgramPath = (String)argument.get("miniProgramPath");
    miniProgramType = (int)argument.get("miniProgramType");
    miniProgramWithShareTicket = (Boolean) argument.get("miniProgramWithShareTicket");

    String platformName = (String)argument.get("platform");
    platform = JShareMessage.getPlatform(platformName);

    String mediaType = (String)argument.get("mediaType");
    shareType = JShareMessage.getShareType(mediaType);
  }



  static public String getPlatform(String platformName) {
    String platform = null;
    switch (platformName){
      case "wechatSession": platform = Wechat.Name; break;
      case "wechatTimeLine": platform = WechatMoments.Name; break;
      case "wechatFavourite": platform = WechatFavorite.Name; break;
      case "qq": platform = QQ.Name; break;
      case "qZone": platform = QZone.Name; break;
      case "sinaWeibo": platform = SinaWeibo.Name; break;
      case "sinaWeiboContact": platform = SinaWeiboMessage.Name; break;
      case "facebook": platform = Facebook.Name; break;
      case "facebookMessenger": platform = FbMessenger.Name; break;
      case "twitter": platform = Twitter.Name; break;
      default:
        platform = null;
        break;
    }
    return platform;
  }

  static public int getShareType(String mediaType){
    int shareType = Platform.SHARE_TEXT;
    switch (mediaType){
      case "text":
        shareType = Platform.SHARE_TEXT;
        break;
      case "image":
        shareType = Platform.SHARE_IMAGE;
        break;
      case "link":
        shareType = Platform.SHARE_WEBPAGE;
        break;
      case "audio":
        shareType = Platform.SHARE_MUSIC;
        break;
      case "video":
        shareType = Platform.SHARE_VIDEO;
        break;
      case "app":
        shareType = Platform.SHARE_APPS;
        break;
      case "file":
        shareType = Platform.SHARE_FILE;
        break;
      case "emoticon":
        shareType = Platform.SHARE_EMOJI;
        break;
      case "miniProgram":
        shareType = Platform.SHARE_MINI_PROGRAM;
        break;
      default:
        break;
    }
    return shareType;
  }
}
