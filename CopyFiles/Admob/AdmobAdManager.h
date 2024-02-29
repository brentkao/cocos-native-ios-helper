//
//  AdmobAdManager.h
//  admob 廣告管理類
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "AdMobBannerViewController.h"
#import "AdMobRewardedVideoViewController.h"
#import "AdMobInterstitialViewController.h"

static ViewController *viewController;
static AdMobInterstitialViewController* m_interstitalView;
static AdMobRewardedVideoViewController* m_rewardVideoView;
static AdMobBannerViewController* m_bannerView;

NS_ASSUME_NONNULL_BEGIN
@interface AdmobAdManager : NSObject
// 註冊視圖與初始化 AdMob 的監聽器
+(void)registviewController:(ViewController *)viewController;

// 註冊 廣告ID 與載入廣告
+(void)registerAndLoadAd:(NSString *)info;

// 顯示獎勵廣告
+(BOOL)showRewardedVideoAd;

// 顯示插頁廣告
+(BOOL)showInterstitialAd;

// 顯示橫幅廣告
+(BOOL)showBannerAd;

// 隱藏橫幅廣告
+(void)hideBannerAd;

// 載入（緩存）AdMob 的獎勵廣告
+(BOOL)loadRewardedVideoAd;

// 載入（緩存）AdMob 的插頁廣告
+(BOOL)loadInterstitialAd;

// 載入（緩存）AdMob 的橫幅廣告
+(BOOL)loadBannerAd;

@end

NS_ASSUME_NONNULL_END


