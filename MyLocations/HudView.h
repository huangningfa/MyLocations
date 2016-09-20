//
//  HudView.h
//  MyLocations
//
//  Created by HNF's wife on 16/9/17.
//  Copyright © 2016年 huangningfa@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudView : UIView

@property (nonatomic, copy) NSString *text;

+ (HudView *)hudInView:(UIView *)view animated:(BOOL)animated;

@end
