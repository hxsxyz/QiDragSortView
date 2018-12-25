//
//  QiDragSortView.m
//  QiDragSortView
//
//  Created by huangxianshuai on 2018/12/21.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "QiDragSortView.h"

@interface QiDragSortView ()

@property (nonatomic, assign) CGPoint originGesturePoint;
@property (nonatomic, assign) CGPoint originButtonCenter;

@end

@implementation QiDragSortView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {

        _columnCount = 3;
        _rowHeight = 40.0;
        _rowPadding = 30.0;
        _columnPadding = 20.0;
        _rowMargin = _rowPadding;
        _columnMargin = _columnPadding;
        
        _buttons = [NSMutableArray array];
        _normalColor = [UIColor blackColor];
        _selectedColor = [UIColor blueColor];
    }
    
    return self;
}

- (void)setTitles:(NSArray<NSString *> *)titles {
    
    _titles = titles;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger differCount = titles.count - self.buttons.count;
        
        if (differCount > 0) {
            for (NSInteger i = self.buttons.count; i < differCount; i++) {
                [self.buttons addObject:[self buttonWithTag:i]];
            }
        }
        else if (differCount < 0) {
            self.buttons = [self.buttons subarrayWithRange:(NSRange){0, titles.count}].mutableCopy;
        }
        
        self.enabledTitles = self.enabledTitles ?: titles;
        self.selectedTitles = self.selectedTitles ?: titles;
        
        for (NSInteger i = 0; i < self.buttons.count; i++) {
            [self.buttons[i] setTitle:titles[i] forState:UIControlStateNormal];
            [self.buttons[i] addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
            [self selectButton:self.buttons[i] forStatus:[self.selectedTitles containsObject:titles[i]]];
            if ([self.enabledTitles containsObject:titles[i]]) {
                [self.buttons[i] addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        for (NSInteger i = 0; i < self.buttons.count; i++) {
            NSInteger rowIndex = i / self.columnCount;
            NSInteger columnIndex = i % self.columnCount;
            CGFloat buttonWidth = (self.bounds.size.width - self.columnMargin * 2 - self.columnPadding * (self.columnCount - 1))  / self.columnCount;
            CGFloat buttonX = self.columnMargin + columnIndex * (buttonWidth + self.columnPadding);
            CGFloat buttonY = self.rowMargin + rowIndex * (self.rowHeight + self.rowPadding);
            self.buttons[i].frame = CGRectMake(buttonX, buttonY, buttonWidth, self.rowHeight);
        }
        
        CGRect frame = self.frame;
        NSInteger rowCount = ceilf((CGFloat)self.buttons.count / (CGFloat)self.columnCount);
        frame.size.height = self.rowMargin * 2 + self.rowHeight * rowCount  + self.rowPadding * (rowCount - 1);
        self.frame = frame;
    });
}

- (void)buttonClicked:(UIButton *)button {
    
    if (_buttonClicked) {
        _buttonClicked(button);
    }
    else {
        [self selectButton:button forStatus:!button.selected];
    }
    
    if (_dragSortEnded) {
        _dragSortEnded(_buttons);
    }
}

- (void)selectButton:(UIButton *)button forStatus:(BOOL)selected {
    
    button.selected = selected;
    button.layer.borderColor = selected? _selectedColor.CGColor: _normalColor.CGColor;
}

- (UIButton *)buttonWithTag:(NSInteger)tag {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:_normalColor forState:UIControlStateNormal];
    [button setTitleColor:_selectedColor forState:UIControlStateSelected];
    [button setTitleColor:_selectedColor forState:UIControlStateSelected | UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.minimumScaleFactor = .5;
    button.backgroundColor = [UIColor whiteColor];
    button.layer.borderColor = _normalColor.CGColor;
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5.0;
    button.layer.borderWidth = 1.0;
    button.tag = tag;
    [self addSubview:button];
    
    return button;
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture {
    
    UIButton *currentButton = (UIButton *)gesture.view;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        [self bringSubviewToFront:currentButton];
        
        [UIView animateWithDuration:.25 animations:^{
            self.originButtonCenter = currentButton.center;
            self.originGesturePoint = [gesture locationInView:currentButton];
            currentButton.transform = CGAffineTransformScale(currentButton.transform, 1.2, 1.2);
        }];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:.25 animations:^{
            currentButton.center = self.originButtonCenter;
            currentButton.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (self.dragSortEnded) {
                self.dragSortEnded(self.buttons);
            }
        }];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint gesturePoint = [gesture locationInView:currentButton];
        CGFloat deltaX = gesturePoint.x - _originGesturePoint.x;
        CGFloat deltaY = gesturePoint.y - _originGesturePoint.y;
        currentButton.center = CGPointMake(currentButton.center.x + deltaX, currentButton.center.y + deltaY);
        
        NSInteger fromIndex = currentButton.tag;
        NSInteger toIndex = [self toIndexWithCurrentButton:currentButton];
        
        if (toIndex >= 0) {
            currentButton.tag = toIndex;
            
            if (toIndex > fromIndex) {
                for (NSInteger i = fromIndex; i < toIndex; i++) {
                    UIButton *nextButton = _buttons[i + 1];
                    CGPoint tempPoint = nextButton.center;
                    [UIView animateWithDuration:.5 animations:^{
                        nextButton.center = self.originButtonCenter;
                    }];
                    _originButtonCenter = tempPoint;
                    nextButton.tag = i;
                }
            }
            else if (toIndex < fromIndex) {
                for (NSInteger i = fromIndex; i > toIndex; i--) {
                    UIButton *previousButton = self.buttons[i - 1];
                    CGPoint tempPoint = previousButton.center;
                    [UIView animateWithDuration:.5 animations:^{
                        previousButton.center = self.originButtonCenter;
                    }];
                    _originButtonCenter = tempPoint;
                    previousButton.tag = i;
                }
            }
            [_buttons sortUsingComparator:^NSComparisonResult(UIButton *obj1, UIButton *obj2) {
                return obj1.tag > obj2.tag;
            }];
        }
    }
}

- (NSInteger)toIndexWithCurrentButton:(UIButton *)currentButton {
    
    for (UIButton *button in _buttons) {
        if (button != currentButton) {
            if (CGRectContainsPoint(currentButton.frame, button.center)) {
                return button.tag;
            }
        }
    }
    return -1;
}


#pragma mark -

- (void)dealloc {
    
    NSLog(@"%s", __func__);
}

@end
