//
//  AdMobInterstitialViewController.h
//  admob 插頁廣告 ViewController
//

#ifndef AdMobInterstitialViewController_h
#define AdMobInterstitialViewController_h
#import <UIKit/UIKit.h>
@interface AdMobInterstitialViewController : UIViewController
-(void)registerAd:(NSString *)ad;
- (IBAction)loadAd;
- (bool)showAd;
@end

#endif /* AdMobInterstitialViewController_h */
