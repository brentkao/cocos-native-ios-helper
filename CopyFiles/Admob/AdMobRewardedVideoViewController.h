//
//  AdMobRewardedVideoViewController.h
//  admob 獎勵廣告 ViewController
//

#ifndef AdMobRewardedVideoViewController_h
#define AdMobRewardedVideoViewController_h
#import <UIKit/UIKit.h>
@interface AdMobRewardedVideoViewController : UIViewController
-(void)registerAd:(NSString *)ad;
-(IBAction)loadAd;
-(bool)showAd;
@end


#endif /* AdMobRewardedVideoViewController_h */
