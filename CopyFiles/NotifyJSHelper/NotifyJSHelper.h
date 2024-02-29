//
//  NotifyJSHelper.hpp
//  全局通知 JS 層統一入口
//

#import <Foundation/Foundation.h>


@interface NotifyJSHelper : NSObject

+(instancetype)shareInstance;
+(void)notifyToJs:(NSString *)funcName params:(NSString *)params;
+(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end

