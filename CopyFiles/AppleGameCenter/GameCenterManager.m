//GameCenterManager.m
#import <Foundation/Foundation.h>
#import "GameCenterManager.h"
#import "GameKitHelper.h"
#import "NotifyJSHelper.h"

@implementation GameCenterManager
+(void)loginGameCenter{
    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
}
+(void) uploadScore:(NSString *)info {
    NSDictionary *dict = [NotifyJSHelper dictionaryWithJsonString:info];
    NSString* rID = [dict objectForKey:@"id"];
    int score = [[dict objectForKey:@"score"] intValue];
    
    [[GameKitHelper sharedGameKitHelper] submitScore:(int64_t)score category:rID];
}
+(void)showLeaderboard:(NSString *)info {
    NSDictionary *dict = [NotifyJSHelper dictionaryWithJsonString:info];
    NSString* rID = [dict objectForKey:@"id"];
    [[GameKitHelper sharedGameKitHelper] showLeaderboard:rID];
}
+(void)retrieveTopTenScores{
//    [[GameKitHelper sharedGameKitHelper] retrieveTopTenScores];
}
+(void)getScoreData:(NSString *)info{
    NSDictionary *dict = [NotifyJSHelper dictionaryWithJsonString:info];
    NSString* rID = [dict objectForKey:@"id"];
    [[GameKitHelper sharedGameKitHelper] getScoreData:rID];
}
+(int)getScore{
    return [[GameKitHelper sharedGameKitHelper] getScore];
}
@end
