

package cn.jiguang.share.demo.wxapi;


import android.content.Intent;
import android.os.Bundle;
import cn.jiguang.share.wechat.WeChatHandleActivity;

/** 微信客户端回调activity示例 */
public class WXEntryActivity extends WeChatHandleActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
    }
}
