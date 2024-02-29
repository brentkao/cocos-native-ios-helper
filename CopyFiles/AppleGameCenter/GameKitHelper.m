//GameKitHelper.m

#import "GameKitHelper.h"

@interface GameKitHelper ()
<GKGameCenterControllerDelegate> {
    BOOL _gameCenterFeaturesEnabled;
    UIViewController* currentModalViewController;
    int score;
}
@end

@implementation GameKitHelper

//#pragma mark Singleton stuff
+(id) sharedGameKitHelper {
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper =
        [[GameKitHelper alloc] init];
    });
    return sharedGameKitHelper;
}

//#pragma mark Player Authentication
-(void) authenticateLocalPlayer {
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        [self setLastError:error];
        if (localPlayer.authenticated) {
            _gameCenterFeaturesEnabled = YES;
            NSlog(@"授權完成")
        } else if(viewController) {
            [self presentViewController:viewController];
        } else {
            _gameCenterFeaturesEnabled = NO;
        }
    };
}

//#pragma mark Property setters

-(void) setLastError:(NSError*)error {
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameCenter -- setLastError -- ERROR: %@", [[_lastError userInfo]
                                                           description]);
    }
}

#pragma mark UIViewController stuff

-(UIViewController*) getRootViewController {
    return [UIApplication
            sharedApplication].keyWindow.rootViewController;
}

-(void)presentViewController:(UIViewController*)vc {
    UIViewController* rootVC = [self getRootViewController];
    [rootVC presentViewController:vc animated:YES
                       completion:nil];
}

// 這裡兩個參數 score是數據， category是ID，就是我們創建排行榜以後，不可更改的那個ID。
-(void) submitScore:(int64_t)score category:(NSString*)category {
    // 檢查是否登錄
    if (!_gameCenterFeaturesEnabled)    {
        NSLog(@"GameCenter -- submitScore -- Player not authenticated");
        return;
    }
    
    // 創建一個分數對象
    GKScore* gkScore = [[GKScore alloc] initWithCategory:category];
    
    // 設定分數 對象的值
    gkScore.value = score;
    
    // 向GameCenter提交數據
    [gkScore reportScoreWithCompletionHandler: ^(NSError* error)    {
        [self setLastError:error];
    }];
}

//-(void) uploadScore:(NSDictionary *)dict {
//    NSString* rID = [dict objectForKey:@"id"];
//    int score = [[dict objectForKey:@"score"] intValue];
//
//    [[GameKitHelper sharedGameKitHelper] submitScore:(int64_t)score category:rID];
//}

- (void) showLeaderboard:(NSString*)rID{
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil) {
        [leaderboardController setCategory:rID];
        leaderboardController.leaderboardDelegate = self;
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        currentModalViewController = [[UIViewController alloc] init];
        [window addSubview:currentModalViewController.view];
        [currentModalViewController presentModalViewController:leaderboardController animated:YES];
    }
}

//關閉排行榜回調
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
    if(currentModalViewController !=nil){
        [currentModalViewController dismissModalViewControllerAnimated:NO];
        [currentModalViewController.view removeFromSuperview];
        currentModalViewController = nil;
    }
}

//- (void) retrieveTopTenScores
//{
//    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
//    //NSLog(@" value:%@",leaderboardRequest.localPlayerScore.value);
//    if (leaderboardRequest != nil)
//    {
//        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
//        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
//        leaderboardRequest.range = NSMakeRange(1,10);
//        leaderboardRequest.category = @"20230312";
//
//        //__block NSString *score;
//        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
//            if (error != nil){
//                // handle the error.
//                NSLog(@"下载失败");
//            }
//            if (scores != nil){
//                NSLog(@" value:%d",leaderboardRequest.localPlayerScore.value);
//                //score = [NSString stringWithFormat:@"%lld", scoreInt];
//                // process the score information.
//                NSLog(@"下载成功....");
//                NSArray *tempScore = [NSArray arrayWithArray:leaderboardRequest.scores];
//                for (GKScore *obj in tempScore) {
//                    NSLog(@"    playerID            : %@",obj.playerID);
//                    NSLog(@"    category            : %@",obj.category);
//                    NSLog(@"    date                : %@",obj.date);
//                    NSLog(@"    formattedValue    : %@",obj.formattedValue);
//                    NSLog(@"    value                : %d",obj.value);
//                    NSLog(@"    rank                : %d",obj.rank);
//                    NSLog(@"**************************************");
//                }
//            }
//        }];
//    }
//}

// 報告成就
- (void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent {
    // 創建或更新成就進度對象
    NSLog(@"reportAchievementIdentifier identifier: %@", identifier);
    NSLog(@"reportAchievementIdentifier percentComplete: %f", percent);


    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    if (achievement) {
        // 設置成就進度
        achievement.percentComplete = percent;
        achievement.showsCompletionBanner = YES;  // 自動顯示完成橫幅

        // 報告成就
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"reportAchievementIdentifier 錯誤報告成就: %@", error);
                [self setLastError:error];
            }else{
                NSLog(@"reportAchievementIdentifier 上報成功");
            }
        }];
    }
}

- (void) getScoreData:(NSString*)rID{
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    if (leaderboardRequest != nil)
    {
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.range = NSMakeRange(1,10);
        leaderboardRequest.category = rID;
        
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            if (error != nil){
                // handle the error.
                NSLog(@"下載失敗");
            }
            if (scores != nil){
                score = (int)leaderboardRequest.localPlayerScore.value;
            }
        }];
    }
}
-(int)getScore{
    return score;
}
@end
