#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

typedef enum {
    IAPPurchSuccess = 0,       // 购买成功
    IAPPurchFailed = 1,        // 购买失败
    IAPPurchCancel = 2,        // 取消购买
    IAPPurchVerFailed = 3,     // 订单校验失败
    IAPPurchVerSuccess = 4,    // 订单校验成功
    IAPPurchNotArrow = 5,      // 不允许内购
    IAPPurchNotFined = 6,      //到苹果配置后台没有找到配置数据
}IAPPurchType;

typedef void (^IAPCompletionHandle)(IAPPurchType type,NSDictionary *data);

@interface IAPManager : NSObject

+ (instancetype)sharedInstance;

//初始化
+(void)initIAP:(NSString*)info;

//发起支付入口
+(void)appinPurchase:(NSString*)info;

// 恢复购买
+ (void) restorePurchases;

@end

NS_ASSUME_NONNULL_END
