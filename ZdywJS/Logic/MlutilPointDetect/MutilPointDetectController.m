//
//  MutilPointDetectController.m
//  3GClient
//
//  Created by zhouww on 13-4-24.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "MutilPointDetectController.h"
#import <UIKit/UIKit.h>

static MutilPointDetectController *g_mutilPointDetectCtl = nil;

@interface MutilPointDetectController (Private)

// 初始化测试网络是否正常的外部网络地址
- (void)buildTestNetDataModel;

// 初始化多点接入的http server地址
- (void)buildMutilPointDataModel;

// 测试http server是否可用
- (void)testHttpServerAction:(int)state;

@end


@implementation MutilPointDetectController

@synthesize delegate = _delegate;
@synthesize mainHttpServer = _mainHttpServer;

// 单实例
+ (MutilPointDetectController*)shareInstance
{
    @synchronized(self)
    {
        if(g_mutilPointDetectCtl == nil)
        {
            g_mutilPointDetectCtl = [[MutilPointDetectController alloc] init];
        }
        
        return g_mutilPointDetectCtl;
    }
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _testNetIndex = 0;
        
        [self setMainHttpServer:nil];
        
        //初始化测试网络是否正常的外部网络地址
        [self buildTestNetDataModel];
        
        //初始化多点接入的http server地址
        [self buildMutilPointDataModel];
        
        // 监听客户端的激活
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appActivedAction)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveTestHttpServerData:)
                                                     name:kNotificationDefaultConfigFinish
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildTestNetDataModel
{
    _testNetHostNameArray = [[NSMutableArray alloc] initWithCapacity:0];
    [_testNetHostNameArray addObject:@"www.baidu.com"];
//    [_testNetHostNameArray addObject:@"www.qq.com"];
}

- (void)buildMutilPointDataModel
{
    _mutilPointAddress = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString *strBrandId = [ZdywUtils getLocalStringDataValue:kZdywDataKeyBrandID];
    if([strBrandId isEqualToString:@"dd"])
    {
        NSArray * mutilPointDomains = [NSArray arrayWithObjects:@"http://agw.shuodh.com",@"http://agw1.shuodh.com",@"http://agw2.shuodh.com",@"http://agw3.shuodh.com",@"http://agw4.shuodh.com",nil];
        NSArray * mutilPointPort = [NSArray arrayWithObjects:@"2001",@"2002",@"2003",@"2004",@"2005",nil];
        for (NSString *domainsStr in mutilPointDomains) {
            for (NSString *portStr in mutilPointPort) {
                NSLog(@"%@",[NSString stringWithFormat:@"%@:%@",domainsStr,portStr]);
                [_mutilPointAddress addObject:[NSString stringWithFormat:@"%@:%@",domainsStr,portStr]];
            }
        }
    }
}

// 停止测试http server
- (void)stopTestHttpServer
{
    [[ZdywServiceManager shareInstance] stopRequestWithType:ZdywServiceDefaultConfigType];
}

#pragma  mark -
#pragma mark AddressPingHelperDelegate

// 监听客户端激活的操作，并检查http server是否可用
- (void)appActivedAction
{
    [self performSelectorInBackground:@selector(handleAppActivedAction) withObject:nil];
}

- (void)handleAppActivedAction
{
    PhoneNetType  netType = [ZdywUtils getCurrentPhoneNetType];
    
    if(netType == PNT_UNKNOWN)
    {
        //用户为开启网络，提示用户开启网络
        if(self.delegate && [self.delegate respondsToSelector:@selector(appDidCloseWeb)])
        {
            [self.delegate appDidCloseWeb];
        }
    }
    else
    {
        //用户已开启网络，开始尝试请求一次数据
        [self testHttpServerAction:0];
    }
}

#pragma mark -
#pragma mark test http server

// 测试http server是否可用
- (void)testHttpServerAction:(int)state
{
    _currentRequestState = state;
    [[ZdywServiceManager shareInstance] requestService:ZdywServiceDefaultConfigType
                                              userInfo:nil
                                              postDict:nil];
}

// 解析test http server返回的数据
- (void)receiveTestHttpServerData:(NSNotification*)notification
{
    NSDictionary *dic = [notification userInfo];
    
    if([dic objectForKey:@"result"])
    {
        int nRet = [[dic objectForKey:@"result"] intValue];
        
        if(nRet == 0)
        {
            if(_currentRequestState == 0)
            {
                NSLog(@"http server normal");
                
                return;
            }
            else
            {
                //探测接入点成功
                if(self.delegate && [self.delegate respondsToSelector:@selector(endDetectPoint:state:)])
                {
                    [self.delegate endDetectPoint:_mutilPointIndex+1 state:YES];
                }
                
                return;
            }
        }
    }
    
    NSLog(@"http server failed");
    
    if(_currentRequestState == 0)
    {
        //检测网络是否正常
        [self testNetState];
    }
    else
    {
        //探测上个接入点失败
        if(self.delegate && [self.delegate respondsToSelector:@selector(endDetectPoint:state:)])
        {
            [self.delegate endDetectPoint:_mutilPointIndex+1 state:NO];
        }
        
        //探测下个接入点
        [self findNextValidHttpServer];
    }
}

#pragma mark -
#pragma mark test net normal?

- (void)testNetState
{
    //初始化变量
    _testNetIndex = 0;
    
    //ping操作
    if(_testNetIndex < [_testNetHostNameArray count])
    {
        NSString *strHostName = [_testNetHostNameArray objectAtIndex:_testNetIndex];
        
        _addressPingHelper = [[AddressPingHelper alloc] init];
        _addressPingHelper.delegate = self;
        [_addressPingHelper pingHostName:strHostName];
    }
}

// 网络异常
- (void)testNetDidAbnormal
{
    _testNetIndex++;
    
    if(_testNetIndex < [_testNetHostNameArray count])
    {
        NSString *strHostName = [_testNetHostNameArray objectAtIndex:_testNetIndex];
        
        _addressPingHelper = [[AddressPingHelper alloc] init];
        _addressPingHelper.delegate = self;
        [_addressPingHelper pingHostName:strHostName];
    }
    else
    {
        NSLog(@"net abnormal");
    }
}

// 网络正常
- (void)testNetDidNormal
{
    NSLog(@"net normal");
    
    //网络正常但无法接入http server
    if(self.delegate && [self.delegate respondsToSelector:@selector(netDidNormal)])
    {
        [self.delegate netDidNormal];
    }
}

#pragma mark -
#pragma mark find valid http server

// 寻找有效的接入点
- (void)findValidHttpServer
{
    [self performSelectorInBackground:@selector(handleFindValidHttpServer) withObject:nil];
}

- (void)handleFindValidHttpServer
{
    _mutilPointIndex = 0;
    
    NSString *strTemp = [ZdywUtils getLocalStringDataValue:kZdywDataKeyServerAddress];
    [self setMainHttpServer:strTemp];
    
    //探测可用的http server
    if(_mutilPointIndex < [_mutilPointAddress count])
    {
        NSString *strHttpServer = [_mutilPointAddress objectAtIndex:_mutilPointIndex];
        
        [ZdywUtils setLocalDataString:strHttpServer key:kZdywDataKeyServerAddress];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(startDetectPoint:)])
        {
            [self.delegate startDetectPoint:_mutilPointIndex+1];
        }
        
        [self testHttpServerAction:1];
    }
}

- (void)findNextValidHttpServer
{
    _mutilPointIndex++;
    
    //探测可用的http server
    if(_mutilPointIndex < [_mutilPointAddress count])
    {
        NSString *strHttpServer = [_mutilPointAddress objectAtIndex:_mutilPointIndex];
        
        [ZdywUtils setLocalDataString:strHttpServer key:kZdywDataKeyServerAddress];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(startDetectPoint:)])
        {
            [self.delegate startDetectPoint:_mutilPointIndex+1];
        }
        
        [self testHttpServerAction:1];
    }
    else
    {
        //找不到可用的http server
        if(self.delegate && [self.delegate respondsToSelector:@selector(failedDetectPoint)])
        {
            [self.delegate failedDetectPoint];
        }
    }
}

@end
