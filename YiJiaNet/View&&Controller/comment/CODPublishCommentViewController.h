//
//  CODPublishCommentViewController.h
//  YiJiaNet
//
//  Created by KUANG on 2019/1/16.
//  Copyright © 2019年 JIARUI. All rights reserved.
//

#import "CODBaseViewController.h"

@interface CODPublishCommentViewController : CODBaseTableViewController
@property (nonatomic, strong) NSString *paramId;
@property (nonatomic, copy) void(^refreshBlock)(void);

@end
