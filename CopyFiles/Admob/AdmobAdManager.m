//
//  AdmobAdManager.m
//  admob 廣告管理類的實現
//

#import <Foundation/Foundation.h>
#import "AdmobAdManager.h"
#import "AdMobBannerViewController.h"
#import "AdMobRewardedVideoViewController.h"
#import "AdMobInterstitialViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "../NotifyJSHelper/NotifyJSHelper.h"

@implementation AdmobAdManager
    
/**
 注册与初始化admob
 @param ViewController 类型
 */
+(void)registviewController:(ViewController *)viewController_{
    viewController = viewController_;
    //初始化移动广告 SDK
    //https://developers.google.cn/admob/ios/quick-start?hl=zh-cn#initialize_the_mobile_ads_sdk
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ @"27d22d1ab9eafa0bcbadced30c67dad0" ];
    [GADMobileAds.sharedInstance startWithCompletionHandler:nil];
    
}


+(void)registerAndLoadAd:(NSString *)info{
    NSDictionary *dictionary = [NotifyJSHelper dictionaryWithJsonString:info];
    NSString *rewardedVideoADId = [dictionary objectForKey:@"rewardedVideoADId"];
    NSString *interstitialADId =[dictionary objectForKey:@"interstitialAdId"];
    NSString *bannerADId =[dictionary objectForKey:@"bannerAdId"];

    if(interstitialADId){
        m_interstitalView = [AdMobInterstitialViewController alloc];
        [m_interstitalView registerAd:interstitialADId];
        [m_interstitalView loadAd];
    }
    if(rewardedVideoADId){
        m_rewardVideoView = [AdMobRewardedVideoViewController alloc];
        [m_rewardVideoView registerAd:rewardedVideoADId];
        [m_rewardVideoView loadAd];
    }
    if(bannerADId){
        m_bannerView = [AdMobBannerViewController alloc];
        [m_bannerView registerAd:bannerADId];
        [m_bannerView loadAd];
    }
   
}

+(BOOL)showRewardedVideoAd{
    if(m_rewardVideoView){
        UIWindow * window = [UIApplication sharedApplication].delegate.window;
        [m_rewardVideoView.view setMultipleTouchEnabled:YES];
        [window.rootViewController.view addSubview:m_rewardVideoView.view];

        return [m_rewardVideoView showAd];
    }else{
        return false;
    }
}

+(BOOL)showInterstitialAd{
    if(m_interstitalView){
        UIWindow * window = [UIApplication sharedApplication].delegate.window;
        [m_interstitalView.view setMultipleTouchEnabled:YES];
        [window.rootViewController.view addSubview:m_interstitalView.view];

        return [m_interstitalView showAd];
    }else{
        return false;
    }
}

+(BOOL)showBannerAd{
    if(m_bannerView){
        UIWindow * window = [UIApplication sharedApplication].delegate.window;
        [m_bannerView.view setMultipleTouchEnabled:YES];
        [window.rootViewController.view addSubview:m_bannerView.view];
       return [m_bannerView showAd];
    }else {
        return false;
    }
}

+(void)hideBannerAd{
    if(m_bannerView){
        [m_bannerView.view removeFromSuperview];
        [m_bannerView refreshAd];
        [m_bannerView hideAd];
    }
}

//加载(缓存)admob的激励视频
+(BOOL)loadRewardedVideoAd{
    if(m_rewardVideoView){
        [m_rewardVideoView loadAd];
    }
    return true;
}

//加载(缓存)admob的插屏广告
+(BOOL)loadInterstitialAd{
    if(m_interstitalView){
        [m_interstitalView loadAd];
    }
    return true;
}

//加载(缓存)admob的banner广告
+(BOOL)loadBannerAd{
    if(m_bannerView){
        [m_bannerView loadAd];
    }
    return true;
}


@end
