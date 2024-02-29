//
//  AdMobInterstitialViewController.m
//  admob 插頁廣告 ViewController 實現
//

#import "AdMobInterstitialViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
@interface AdMobInterstitialViewController ()<GADFullScreenContentDelegate>
@property(nonatomic, strong) GADInterstitialAd * interstitialAd;

@end
NSString* AdMobInterstitialADId = @"";
@implementation AdMobInterstitialViewController
- (void)viewDidLoad {
   [super viewDidLoad];
}

-(void)loadAd{
    GADRequest *request = [GADRequest request];
    [GADInterstitialAd loadWithAdUnitID:AdMobInterstitialADId
                                request:request
                      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
      if (error) {
        NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
        return;
      }
      self.interstitialAd = ad;
      self.interstitialAd.fullScreenContentDelegate = self;
    }];
}

-(void)registerAd:(NSString *)ad{
    AdMobInterstitialADId = [[NSString alloc]initWithString:ad];
}

-(BOOL)showAd{
    if(self.view && self.interstitialAd){
        self.view.hidden = NO;
        [self.interstitialAd presentFromRootViewController:self];
        return true;
    }else {
        return false;
    }
}


#pragma mark - GADFullScreenContentDelegate implementation
/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"Ad did fail to present full screen content.");
    self.interstitialAd = nil;
    [self loadAd];
}

/// Tells the delegate that the ad will present full screen content.
- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"Ad will present full screen content.");
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
   NSLog(@"Ad did dismiss full screen content.");
    self.interstitialAd = nil;
    [self loadAd];
}
@end

