//GameCenterController.h


@interface GameCenterManager:NSObject
+(void)loginGameCenter;
+(void)uploadScore:(NSString *)dict;
+(void)showLeaderboard:(NSString *)dict;
//+(void)retrieveTopTenScores;
+(void)getScoreData:(NSString *)dict;
+(int)getScore;
@end
