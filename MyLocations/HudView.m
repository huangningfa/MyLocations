//
//  HudView.m
//  MyLocations
//
//  Created by HNF's wife on 16/9/17.
//  Copyright © 2016年 huangningfa@163.com. All rights reserved.
//

#import "HudView.h"

@implementation HudView

+ (HudView *)hudInView:(UIView *)view animated:(BOOL)animated {
    HudView *hudView = [[HudView alloc] initWithFrame:view.bounds];
    hudView.opaque = false;
    [view addSubview:hudView];
    view.userInteractionEnabled = NO;

    [hudView showAnimated:animated];
    return hudView;
}

- (void)drawRect:(CGRect)rect {
    CGFloat boxW = 96;
    CGFloat boxH = 96;
    
    CGRect boxRect = CGRectMake(roundf(self.bounds.size.width - boxW) / 2, roundf(self.bounds.size.height - boxH) / 2, boxW, boxH);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:10];
    [[[UIColor alloc] initWithWhite:0.3 alpha:0.8] setFill];
    [roundedRect fill];
    
    UIImage *image = [UIImage imageNamed:@"Checkmark"];
    CGPoint imagePoint = CGPointMake(self.center.x - roundf(image.size.width / 2), self.center.y - roundf(image.size.height / 2) - boxH / 8);
    [image drawAtPoint:imagePoint];
    
    NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:16],
                              NSForegroundColorAttributeName: [UIColor whiteColor]};
    CGSize textSize = [self.text sizeWithAttributes:attribs];
    
    CGPoint textPoint = CGPointMake(self.center.x - roundf(textSize.width / 2), self.center.y - roundf(textSize.height / 2) + boxH / 4);
    [self.text drawAtPoint:textPoint withAttributes:attribs];
}

- (void)showAnimated:(BOOL)animated {
    if (animated) {
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:0 animations:^{
            self.alpha = 1;
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

@end
