//
//  NotifyJSHelper.cpp
//  全局通知 JS 層統一入口
//

#include "NotifyJSHelper.h"
//cocos creator 3.x
#include "cocos/bindings/jswrapper/SeApi.h"
#include "cocos/application/ApplicationManager.h"
#include "base/UTF8.h"

@implementation NotifyJSHelper
static NotifyJSHelper *_sharedIns = nil;
+(instancetype) shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedIns = [[self alloc] init] ;
    }) ;
    
    return _sharedIns ;
}

/**
 通知js
 @param resultType 類型
 @param params 透傳參數
 */
+(void)notifyToJs:(NSString *)funcName params:(NSString *)params {
    NSLog(@"%s, resultType: %ld, params: %@", __FUNCTION__, (long)funcName, params);
    
    if (funcName == nil) {
        NSLog(@"%s, error: %@", __FUNCTION__, @"funcName is nil");
        return;
    }
    
    if (params == nil) {
        params = @"";
    }
    
    NSString *eval = [NSString stringWithFormat:@"%@('%@')", funcName, params];
    const char *c_eval = [eval UTF8String];
    if ([NSThread isMainThread])
       {
           NSLog(@"isMainThread");
           // 是主執行緒，直接進行 UI 操作即可。
           se::ScriptEngine::getInstance()->evalString(c_eval);
       }
       else
       {
           NSLog(@"No MainThread");
           dispatch_sync(dispatch_get_main_queue(), ^{
               // 非主執行緒，將 UI 操作切換到主執行緒進行。
               se::ScriptEngine::getInstance()->evalString(c_eval);
           });
       }

}

+(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
     return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:0
                                                          error:nil];
   
    return dic;
}

@end
