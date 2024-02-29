#import "IAPManager.h"
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "NotifyJSHelper.h"

// 接口声明属性
@interface IAPManager()<SKPaymentTransactionObserver,SKProductsRequestDelegate>{
   NSString           *_currentPurchasedID;
   IAPCompletionHandle _iAPCompletionHandle;
    NSMutableArray *productIds;
    
    NSString *playerId;
    Boolean isSandbox;
    Boolean openLog;
    NSString *password;
    
}
@end



@implementation IAPManager

+(void)initIAP:(NSString*)info{
    NSDictionary *dictionary = [NotifyJSHelper dictionaryWithJsonString:info];
    NSString *_playerId =[dictionary objectForKey:@"playerId"];
    NSString *_isSandbox =[dictionary objectForKey:@"isSandbox"];
    NSString *_openLog =[dictionary objectForKey:@"openLog"];
    NSString * _password =[dictionary objectForKey:@"password"];
    
    [[IAPManager sharedInstance]initConfig :_playerId andOpenLog:_openLog andIsSandbox:_isSandbox andPassword:_password];
    [[IAPManager sharedInstance] addTransactionObserver];
}
 
+ (instancetype)sharedInstance{
     
    static IAPManager *iAPManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        iAPManager = [[IAPManager alloc] init];
    });
    return iAPManager;
}

//支付
+(void)appinPurchase:(NSString*)info{
    NSDictionary *dictionary = [NotifyJSHelper dictionaryWithJsonString:info];
    NSString *productID = [dictionary objectForKey:@"productID"];
   
    [[IAPManager sharedInstance] startPurchaseWithID:productID completeHandle:^(IAPPurchType type,NSDictionary *receipt){
        // 请求回调类型返回的数据
        NSString *message = @"";
        NSString *dataStr = @"";
        NSString *isSucces = @"";
                switch (type) {
                    case IAPPurchSuccess:
                        message = @"购买成功";
                        break;
                    case IAPPurchFailed:
                        message = @"购买失败";
                        break;
                    case IAPPurchCancel:
                        message = @"取消购买";
                        break;
                    case IAPPurchNotArrow:
                        message = @"此APP不允许内购";
                        break;
                    case IAPPurchNotFined:
                        message = @"没有找到相应配置商品";
                        break;
                    case IAPPurchVerSuccess:
                        message = @"订单校验成功";
                        break;
                    case IAPPurchVerFailed:
                        message = @"订单校验失败";
                        break;
                    default:
                        message = @"购买失败";
                        break;
                }
        
        NSString * funcName = @"globalThis.IAPManager.IAPCallback";
        NSString *receiptStr = @"\"\"";
        if(receipt){
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:receipt options:0 error:0];
            receiptStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        NSString *params = [NSString stringWithFormat:@"{\"isSucces\":\"%@\",\"message\":\"%@\",\"data\":%@,\"type\":%u}",
                            isSucces, message,receiptStr,type];
       
        [NotifyJSHelper notifyToJs:funcName params:params];
    }];
}


// 恢复购买
+ (void) restorePurchases {
    [[IAPManager sharedInstance] restorePurchasesReal];
}

-(void)initConfig:(NSString* )_playerId andOpenLog:(NSString* )_openLog andIsSandbox:(NSString* )_isSandbox andPassword:(NSString* )_password{
    playerId = [[NSString alloc] initWithString:_playerId];
    isSandbox = [_isSandbox compare:@"1"] == 0 ? true : false;
    openLog = [_openLog compare:@"1"] == 0 ? true : false;
    password = [[NSString alloc] initWithString:_password];
    
    if(openLog){
        NSLog(@"密钥：%@",password);
    }
}

-(void)addTransactionObserver{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}


- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}
 
- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [super dealloc];
}


// 开始恢复购买
- (void) restorePurchasesReal {
    // 初始化商品ID数组
    productIds = [[NSMutableArray alloc] init];
    // 恢复所有非消耗品
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


// 对已购商品，处理恢复购买的逻辑
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    // 恢复成功，对于非消耗品才能恢复,如果恢复成功则transaction中记录的恢复的产品交易
    // 把商品ID存起来
    [productIds addObject: transaction.payment.productIdentifier];
}

-(void)finishTransaction{
    // 验证成功与否都注销交易,否则会出现虚假凭证信息一直验证不通过,每次进程序都得输入苹果账号
    NSArray* transactions = [SKPaymentQueue defaultQueue].transactions;
    if (transactions.count > 0) {
            //检测是否有未完成的交易
            SKPaymentTransaction* transaction = [transactions firstObject];
            if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                return;
            }
        }

}
 
 
- (void)startPurchaseWithID:(NSString *)purchID  completeHandle:(IAPCompletionHandle)handle{
    [self finishTransaction];//防止如果上次支付完成没有结束再次充值会返回上次票据
    if (purchID) {
        if ([SKPaymentQueue canMakePayments]) {
            _currentPurchasedID = purchID;
            _iAPCompletionHandle = handle;
            
            //从App Store中检索关于指定产品列表的本地化信息
            NSSet *nsset = [NSSet setWithArray:@[purchID]];
            SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
            request.delegate = self;
            [request start];
        }else{
            [self handleActionWithType:IAPPurchNotArrow data:nil];
        }
    }
}

- (void)handleActionWithType:(IAPPurchType)type data:(NSDictionary *)receipt{
    if(_iAPCompletionHandle){ //正常支付流程
        _iAPCompletionHandle(type,receipt);
    }else{
         // 请求回调类型返回的数据
        NSString *message = @"";
        NSString *dataStr = @"";
        NSString *isSucces = @"";

        switch (type) {
                    case IAPPurchSuccess:
                        message = @"购买成功";
                        break;
                    case IAPPurchFailed:
                        message = @"购买失败";
                        break;
                    case IAPPurchCancel:
                        message = @"取消购买";
                        break;
                    case IAPPurchNotArrow:
                        message = @"此APP不允许内购";
                        break;
                    case IAPPurchNotFined:
                        message = @"没有找到相应配置商品";
                        break;
                    case IAPPurchVerSuccess:
                        message = @"订单校验成功";
                        break;
                    case IAPPurchVerFailed:
                        message = @"订单校验失败";
                        break;
                    default:
                        message = @"购买失败";
                        break;
        }
        
        NSString * funcName = @"globalThis.IAPManager.IAPCallback";
        NSString *receiptStr = @"\"\"";
        if(receipt){
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:receipt options:0 error:0];
            receiptStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        NSString *params = [NSString stringWithFormat:@"{\"isSucces\":\"%@\",\"message\":\"%@\",\"data\":%@,\"type\":%u}",
                            isSucces, message,receiptStr,type];
       
        [NotifyJSHelper notifyToJs:funcName params:params];
    }
}


#pragma mark - 苹果票据验证
//沙盒测试环境验证

#define IAPVerifyReceiptSandboxAPI @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define IAPVerifyReceiptProxAPI @"https://buy.itunes.apple.com/verifyReceipt"

-(void)verifyPurchaseWithProductionEnvironment:(SKPaymentTransaction *)transaction{
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];

    NSString *receiptString=[receiptData base64EncodedStringWithOptions:0];//转化为base64字符串
    //自动续费需要password:@"{\"receipt-data\" : \"%@\" , \"password\":\"5b5c3dxxww4fxxxxxxxxxxxxx\"}"
    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\",\"password\" : \"%@\"}", receiptString,password];//拼接请求数据
    
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

    /*
    注意：
    自己测试的时候使用的是沙盒购买(测试环境)
    App Store审核的时候也使用的是沙盒购买(测试环境)
    上线以后就不是用的沙盒购买了(正式环境)

    所以此时应该先验证正式环境，在验证测试环境

    正式环境验证成功，说明是线上用户在使用
    正式环境验证不成功返回21007，说明是自己测试或者审核人员在测试
    */

    //第一步，验证正式环境
    //创建请求到苹果官方进行购买验证（正式环境）
    NSURL *url=[NSURL URLWithString: IAPVerifyReceiptProxAPI];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
    //创建连接并发送同步请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
    if (error) {
        NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
        [self handleActionWithType:IAPPurchVerFailed data:nil];

        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    if(openLog){
        NSLog(@"请求响应的responseData %@",dic);
    }
  
    if([dic[@"status"] intValue]==0){
        //正式环境验证通过（说明是上线以后的用户购买）
        if(openLog){
            NSLog(@"购买成功！");
        }
        [self handleActionWithType:IAPPurchVerSuccess data:dic];
        //在此处对购买记录进行存储，可以存储到开发商的服务器端
    }else if([dic[@"status"] intValue]== 21007){
        //This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead.
        //购买凭证来自于测试环境，但是却发送到了正式环境，请改成测试环境（这种情况下可能是自己测试的，也可能是审核人员测试的）
        if(openLog){
            NSLog(@"购买验证测试环境");
        }
        //第二步，验证测试环境
        [self verifyPurchaseWithTestEnvironment:bodyData];

    }
    [self finishTransaction];
}

 //创建请求到苹果官方进行购买验证（测试环境）
- (void)verifyPurchaseWithTestEnvironment:(NSData *)bodyData {
    NSURL *url=[NSURL URLWithString:IAPVerifyReceiptSandboxAPI];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
    //创建连接并发送同步请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
    
    if (error) {
        if(openLog){
            NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
        }
        
        [self handleActionWithType:IAPPurchVerFailed data:nil];
        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    if(openLog){
        NSLog(@"请求响应的responseData %@",dic);
    }
    if([dic[@"status"] intValue]==0){
        if(openLog){
            NSLog(@"购买成功！");
        }
        [self handleActionWithType:IAPPurchVerSuccess data:dic];
 
    }else{
        if(openLog){
            NSLog(@"购买失败，未通过验证！");
        }
        
        [self handleActionWithType:IAPPurchVerFailed data:nil];
    }
}
 
#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSArray *product = response.products;
    if([product count] <= 0){
        if(openLog){
            NSLog(@"--------------没有商品------------------");
        }
        [self handleActionWithType:IAPPurchNotFined data:nil];
        return;
    }
     
    SKProduct *p = nil;
    for(SKProduct *pro in product){
        if([pro.productIdentifier isEqualToString:_currentPurchasedID]){
            p = pro;
            break;
        }
    }
    
    if(openLog){
        NSLog(@"productID:%@", response.invalidProductIdentifiers);
        NSLog(@"产品付费数量:%lu",(unsigned long)[product count]);
        NSLog(@"产品描述:%@",[p description]);
        NSLog(@"产品标题%@",[p localizedTitle]);
        NSLog(@"产品本地化描述%@",[p localizedDescription]);
        NSLog(@"产品价格：%@",[p price]);
        NSLog(@"产品productIdentifier：%@",[p productIdentifier]);
    }
//    SKPayment *payment = [SKPayment paymentWithProduct:p];
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:p];
    payment.applicationUsername = [[NSMutableString alloc]initWithString:playerId];
    [[SKPaymentQueue defaultQueue] addPayment:payment];

}
 
//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{

    
    if(openLog){
        NSLog(@"------------------从App Store中检索关于指定产品列表的本地化信息错误-----------------:%@", error);
    }
    [self handleActionWithType:IAPPurchNotFined data:nil];
}
 
- (void)requestDidFinish:(SKRequest *)request{
#if DEBUG
    NSLog(@"------------requestDidFinish-----------------");
#endif
}
 
#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    for (SKPaymentTransaction *tran in transactions) {
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased: //消费成功
                [self verifyPurchaseWithProductionEnvironment:tran];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                break;
            case SKPaymentTransactionStatePurchasing: //消费中
                if(openLog){NSLog(@"商品添加进列表");}
                break;
            case SKPaymentTransactionStateRestored: //恢复已购买的商品（消耗型产品不能恢复）
                if(openLog){NSLog(@"已经购买过商品");}
                [self restoreTransaction:tran];
                break;
            case SKPaymentTransactionStateFailed: //消费失败
                [self failedTransaction:tran];
                break;
            default:
                break;
        }
    }
}

// 交易失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction{
    if (transaction.error.code != SKErrorPaymentCancelled) {
        [self handleActionWithType:IAPPurchFailed data:nil];
    }else{
        [self handleActionWithType:IAPPurchCancel data:nil];
    }
     
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}



// 恢复购买完成
- (void)paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentQueue *) queue {
    NSArray *myArray = [productIds copy];
    if(myArray.count != 0){
        [self receiptVerifyPurchaseWithProductionEnvironment];//票据校验
        
        for (SKPaymentTransaction *transaction in queue.transactions) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
    
}

//校验票据的逻辑
-(void)receiptVerifyPurchaseWithProductionEnvironment{
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];

    NSString *receiptString=[receiptData base64EncodedStringWithOptions:0];//转化为base64字符串
    if(openLog){
        NSLog(@"订阅恢复receiptString%@",receiptString);
    }
    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\",\"password\" : \"%@\"}", receiptString,password];//拼接请求数据
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

    

    //第一步，验证正式环境
    //创建请求到苹果官方进行购买验证（正式环境）
    NSURL *url=[NSURL URLWithString: IAPVerifyReceiptProxAPI];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
    //创建连接并发送同步请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
    if (error) {
        if(openLog){
            NSLog(@"验证订阅恢复过程中发生错误，错误信息：%@",error.localizedDescription);
        }
        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    if(openLog){
        NSLog(@"订阅恢复%@",dic);
    }
    if([dic[@"status"] intValue]==0){
        //正式环境验证通过（说明是上线以后的用户购买）
        if(openLog){
            NSLog(@"订阅恢复成功！");
        }
      
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:0];
        NSString *responseDataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString * funcName = @"globalThis.IAPManager.restorePurchasesEnd";
        NSString *params = [NSString stringWithFormat:@"%@",responseDataString];
        [NotifyJSHelper notifyToJs:funcName params:params];
        
        //在此处对购买记录进行存储，可以存储到开发商的服务器端
    }else if([dic[@"status"] intValue]== 21007){
        //This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead.
        //购买凭证来自于测试环境，但是却发送到了正式环境，请改成测试环境（这种情况下可能是自己测试的，也可能是审核人员测试的）
        if(openLog){
            NSLog(@"订阅恢复验证测试环境");
        }
        //第二步，验证测试环境
        [self receiptVerifyPurchaseWithTestEnvironment:bodyData];

    }
}

 //创建请求到苹果官方进行购买验证（测试环境）
- (void)receiptVerifyPurchaseWithTestEnvironment:(NSData *)bodyData{
    NSURL *url=[NSURL URLWithString:IAPVerifyReceiptSandboxAPI];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
    //创建连接并发送同步请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
    
    if (error) {
        
        if(openLog){
            NSLog(@"验证订阅恢复过程中发生错误，错误信息：%@",error.localizedDescription);
        }
        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    if(openLog){
        NSLog(@"订阅恢复%@",dic);
    }
    if([dic[@"status"] intValue]==0){
        if(openLog){
            NSLog(@"订阅恢复成功 %@",responseData);
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:0];
        NSString *responseDataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString * funcName = @"globalThis.IAPManager.restorePurchasesEnd";
        NSString *params = [NSString stringWithFormat:@"%@",responseDataString];
        [NotifyJSHelper notifyToJs:funcName params:params];
        
        
    }else{
        if(openLog){
            NSLog(@"订阅恢复失败，未通过验证！");
        }
    }
}


@end


/* 调用支付方法
 - (void)purchaseWithProductID:(NSString *)productID{
      
     [[IAPManager shareIAPManager] startPurchaseWithID:productID completeHandle:^(IAPPurchType type,NSData *data) {
          
     }];
 }
 */
