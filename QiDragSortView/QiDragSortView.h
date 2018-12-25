//
//  QiDragSortView.h
//  QiDragSortView
//
//  Created by huangxianshuai on 2018/12/21.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QiDragSortView : UIView

@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) CGFloat rowMargin;
@property (nonatomic, assign) CGFloat rowPadding;
@property (nonatomic, assign) CGFloat columnMargin;
@property (nonatomic, assign) CGFloat columnPadding;
@property (nonatomic, assign) NSInteger columnCount;

@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, strong) NSArray<NSString *> *enabledTitles;
@property (nonatomic, strong) NSArray<NSString *> *selectedTitles;
@property (nonatomic, strong) NSArray<NSString *> *titles;

@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;

@property (nonatomic, copy) void(^buttonClicked)(UIButton *button);
@property (nonatomic, copy) void(^dragSortEnded)(NSArray<UIButton *> *buttons);

@end

NS_ASSUME_NONNULL_END
