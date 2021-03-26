package cn.jiguang.jshare_flutter_plugin;

import java.util.Map;

import cn.jiguang.share.android.api.Platform;
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

/**
 * Create by wangqingqing
 * On 2021/3/26 16:07
 * Copyright(c) 2020 极光
 * Description
 */
public class JShareMessage {
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



     public static String getPlatform(String platformName) {
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

     public static int getShareType(String mediaType){
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
