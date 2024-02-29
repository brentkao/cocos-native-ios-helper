//
//  AdMobBannerViewController.h
//   admob 橫幅廣告 ViewController
//

#ifndef AdMobBannerViewController_h
#define AdMobBannerViewController_h
#import <UIKit/UIKit.h>
@interface AdMobBannerViewController : UIViewController
-(void)registerAd:(NSString *)ad;
-(void)loadAd;
-(BOOL)showAd;
-(void)hideAd;
-(void)refreshAd;
@end

#endif /* AdMobBannerViewController_h */
