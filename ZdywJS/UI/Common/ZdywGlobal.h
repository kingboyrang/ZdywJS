//
//  ZdywGlobal.h
//  ZdywMini
//  全局控制的一些宏
//  Created by mini1 on 14-5-28.
//  Copyright (c) 2014年 Guoling. All rights reserved.
//

#ifndef ZdywMini_ZdywGlobal_h
#define ZdywMini_ZdywGlobal_h


#define L(obj)          NSLocalizedString (obj, nil)
#define kZdywIsIos7 ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)       //是否为ios7
#define kZdywIsRetain4  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)    //是否为4寸屏

#define kZdywScreenWidth 320.0f
#define kZdywScreenHeight  (kZdywIsRetain4 ? 568.0f : 480.0f)

#define kNavigationBarBgColor           [UIColor colorWithRed:1.0/255.0 green:174.0/255.0 blue:238.0/255.0 alpha:1.0]
#define kNavigationBarTintColor         [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define kNavigationBarBackGroundColor   [UIColor colorWithRed:1.0/255.0 green:168.0/255.0 blue:230.0/255.0 alpha:1.0]

#endif
