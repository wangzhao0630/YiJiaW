//
//  CODOrderPopView.h
//  YiJiaNet
//
//  Created by KUANG on 2019/1/3.
//  Copyright © 2019年 JIARUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CODOrderPopView : UIView

@property (nonatomic,copy) void (^commitBlock)(NSString * city, NSString *name, NSString *phone);

-(void)show;
-(void)close;

@end
