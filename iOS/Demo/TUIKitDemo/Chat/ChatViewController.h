//
//  ChatViewController.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo 聊天视图
 *  本文件实现了聊天视图
 *  在用户需要收发群组、以及其他用户消息时提供UI
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 *
 */
#import <UIKit/UIKit.h>
#import "TUIBaseChatViewController.h"
#import "TUICommonModel.h"
#import "TUIChatConversationModel.h"
@class TUIMessageCellData;

@interface ChatViewController : UIViewController

@property (nonatomic, strong) TUIChatConversationModel *conversationData;
@property (nonatomic, strong) TUIUnReadView *unRead;
@property (nonatomic, strong) V2TIMMessage *waitToSendMsg;

#pragma mark - 用于消息搜索场景
@property (nonatomic, copy) NSString *highlightKeyword;
@property (nonatomic, strong) V2TIMMessage *locateMessage;
@end
