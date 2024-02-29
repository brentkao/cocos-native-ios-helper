//
//  AdMobRewardedVideoViewController.m
//  admob 獎勵廣告 ViewController 實現
//

#import "AdMobRewardedVideoViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "NotifyJSHelper.h"
@interface AdMobRewardedVideoViewController()<GADFullScreenContentDelegate>

@property(nonatomic, strong) GADRewardedAd *rewardedAd;

@end
NSString* AdMobRewardedVideoADId = @"";

@implementation AdMobRewardedVideoViewController

-(void)registerAd:(NSString *)ad{
    AdMobRewardedVideoADId = [[NSString alloc]initWithString:ad];
}

-(void)loadAd{
    [self loadRewardedAd];
}

-(BOOL)showAd{
    if (self.rewardedAd) {
        [self.rewardedAd presentFromRootViewController:self
                                      userDidEarnRewardHandler:^{
//                                      GADAdReward *reward =
//                                          self.rewardedAd.adReward;
                                      // TODO: Reward the user!
            NSString *info = [NSString stringWithFormat:@"{\"result\":\"%@\"}",@"complete"];
            NSString * funcName = @"globalThis.AdmobAdManger.overRewardedVideoAd";
            NSString *params = info;
            [NotifyJSHelper notifyToJs:funcName params:params];
            
                                    }];
        return true;
      } else {
        NSLog(@"Ad wasn't ready");
          NSString *info = [NSString stringWithFormat:@"{\"result\":\"%@\"}",@"fail"];
          NSString * funcName = @"globalThis.AdmobAdManger.overRewardedVideoAd";
          NSString *params = info;
          [NotifyJSHelper notifyToJs:funcName params:params];
          return false;
      }
}

- (void)loadRewardedAd {
  GADRequest *request = [GADRequest request];
  [GADRewardedAd
       loadWithAdUnitID:AdMobRewardedVideoADId
                request:request
      completionHandler:^(GADRewardedAd *ad, NSError *error) {
        if (error) {
          NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
          return;
        }
        self.rewardedAd = ad;
        NSLog(@"Rewarded ad loaded.");
      self.rewardedAd.fullScreenContentDelegate = self;
      }];
    
    
}

#pragma mark - GADFullScreenContentDelegate implementation
/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"Ad did fail to present full screen content.");
    
    NSString *info = [NSString stringWithFormat:@"{\"result\":\"%@\"}",@"fail"];
    NSString * funcName = @"globalThis.AdmobAdManger.overRewardedVideoAd";
    NSString *params = info;
    [NotifyJSHelper notifyToJs:funcName params:params];
}

/// Tells the delegate that the ad will present full screen content.
- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"Ad will present full screen content.");
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"Ad did dismiss full screen content.");
    
    NSString *info = [NSString stringWithFormat:@"{\"result\":\"%@\"}",@"cancel"];
    NSString * funcName = @"globalThis.AdmobAdManger.overRewardedVideoAd";
    NSString *params = info;
    [NotifyJSHelper notifyToJs:funcName params:params];
    
    [self.view removeFromSuperview];
    self.rewardedAd = nil;
    [self loadAd];
}

@end
