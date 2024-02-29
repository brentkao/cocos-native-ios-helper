//GameKitHelper.h

#import <GameKit/GameKit.h>

@interface GameKitHelper : NSObject
//處理錯誤
@property (nonatomic, readonly) NSError* lastError;

// 初始化
+ (id) sharedGameKitHelper;

// Player authentication, info
-(void) authenticateLocalPlayer;
-(void) setLastError:(NSError*)error;

// 提交分數
-(void) submitScore:(int64_t)score category:(NSString*)category;
//-(void) uploadScore:(NSDictionary *)dict;

// 顯示排行榜
- (void)showLeaderboard:(NSString*)rID;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;

// 提交成就百分比
- (void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent;

//- (void) retrieveTopTenScores;
-(void)getScoreData:(NSString*)rID;
-(int)getScore;
@end
