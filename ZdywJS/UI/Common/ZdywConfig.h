//
//  ZdywConfig.h
//  ZdywMini
//
//  Created by mini1 on 14-5-28.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#define kZdywClientIsIphone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define IOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0

#define IOS6 [[[UIDevice currentDevice]systemVersion] floatValue] < 7.0

#define kAppStoreVersion                0              //               0 企业版     1 AppStore版本
#define kZdywBrandID                    @"js"                                           //brandid
// AppStore版本用 iphone-app 企业版用iphone
#define kZdywPhoneType                  @"iphone"                                       //pv
#define kZdywPublicKey                  @"9876543210!@#$%^"                             //public_key
#define kZdywAppleID                    @"845078110"                                    //apple id
#define kZdywHttpServer                 @"http://agw.ddtel.cn:2001"   //@"http://agw.xy086.cn:2001"
#define kPaySource                      @"59"
#define kCustomerServicePhone           @"400-6617-288"                               //客服电话
#define kCustomerServiceQQ              @"2263398703"                                 //客服QQ
#define kInvite                         @"14"                                          // 渠道号
#define kCustomerServiceTime            @"8:00-23:00"


#define kMaxFeelCPhoneCount             3