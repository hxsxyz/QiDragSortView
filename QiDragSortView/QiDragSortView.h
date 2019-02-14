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

@property (nonatomic, assign) CGFloat rowHeight;//!< 行高
@property (nonatomic, assign) CGFloat rowMargin;//!< 行边距
@property (nonatomic, assign) CGFloat rowPadding;//!< 行间距
@property (nonatomic, assign) CGFloat columnMargin;//!< 列边距
@property (nonatomic, assign) CGFloat columnPadding;//!< 列间距
@property (nonatomic, assign) NSInteger columnCount;//!< 列数

@property (nonatomic, strong) UIColor *normalColor;//!< 按钮基本字体颜色
@property (nonatomic, strong) UIColor *selectedColor;//!< 按钮选择字体颜色

@property (nonatomic, strong) NSArray<NSString *> *enabledTitles;//!< 可以被点击的titles（上行参数，默认全选）
@property (nonatomic, strong) NSArray<NSString *> *selectedTitles;//!< 可以被选择的titles（上行参数，默认全选）
@property (nonatomic, strong) NSArray<NSString *> *titles;//!< 按钮的titles
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;//!< 所有的按钮

/*!
 @brief 按钮点击事件回调
 */
@property (nonatomic, copy) void(^buttonClicked)(UIButton *button);

/*!
 @brief 按钮拖拽排序事件回调
 */
@property (nonatomic, copy) void(^dragSortEnded)(NSArray<UIButton *> *buttons);

@end

NS_ASSUME_NONNULL_END
