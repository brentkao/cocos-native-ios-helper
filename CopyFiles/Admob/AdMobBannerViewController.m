//
//  AdMobBannerViewController.m
//  admob 橫幅廣告 ViewController 實現
//

#import "AdMobBannerViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
@interface AdMobBannerViewController ()<GADBannerViewDelegate>

@property(nonatomic, strong) GADBannerView *bannerView;

@end

NSString* AdMobBannerADId = @"";

@implementation AdMobBannerViewController

-(void)registerAd:(NSString *)ad{
    AdMobBannerADId = [[NSString alloc]initWithString:ad];
}

// 將視圖加入到控制器裡面
- (void)viewDidLoad
{
    NSLog(@"BannerViewController viewDidLoad");
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews
{
    NSLog(@"BannerViewController viewDidLayoutSubviews");
    [super viewDidLayoutSubviews];

    GADAdSize adSize = [self fbAdSize];
    CGSize viewSize = self.view.bounds.size;
    CGSize tabBarSize = self.tabBarController.tabBar.frame.size;
    viewSize = CGSizeMake(viewSize.width, viewSize.height - tabBarSize.height);
    UIEdgeInsets insets = [self safeAreaInsets];
    CGFloat bottomAlignedY = viewSize.height - adSize.size.height ;//- insets.bottom;
    self.bannerView.frame = CGRectMake(insets.left,
                                   bottomAlignedY,
                                   viewSize.width - insets.right - insets.left,
                                   adSize.size.height);
//    self.bannerView.backgroundColor = [UIColor grayColor];
}

- (UIEdgeInsets)safeAreaInsets
{
    NSLog(@"BannerViewController safeAreaInsets");
    // Comment the following if-statement if you are not running XCode 9+
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        return [window safeAreaInsets];
    }
    return UIEdgeInsetsZero;
}

-(BOOL)showAd{
    if(self.bannerView){
        self.view.hidden = NO;
        self.bannerView.hidden = NO;
        return true;
    }else {
        return false;
    }
}

-(void)hideAd{
    if(self.bannerView){
        self.view.hidden = YES;
        self.bannerView.hidden = YES;
    }
}

- (void)refreshAd{
    NSLog(@"BannerViewController refreshAd");
    self.bannerView.hidden = YES;
    [self loadAd];
}

- (void)loadAd
{
    NSLog(@"BannerViewController loadAd");
    if (nil != self.bannerView) {
        [self.bannerView removeFromSuperview];
    }

    GADAdSize adSize = [self fbAdSize];
    self.bannerView = [[GADBannerView alloc]initWithAdSize:adSize];
    self.bannerView.adUnitID = AdMobBannerADId;
    self.bannerView.delegate = self;
    self.bannerView.autoresizingMask =
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleLeftMargin|
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.bannerView];
    self.bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
    [self.bannerView loadRequest:request];
}

- (GADAdSize)fbAdSize
{
    BOOL isIPAD = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    return isIPAD ? GADAdSizeBanner : GADAdSizeBanner;
}
#pragma mark - GADBannerViewDelegate implementation
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidReceiveAd");
    // Add bannerView to view and add constraints as above.
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidRecordImpression");
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewWillPresentScreen");
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewWillDismissScreen");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidDismissScreen");
}



@end

