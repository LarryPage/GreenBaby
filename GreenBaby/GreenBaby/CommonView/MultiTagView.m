//
//  MultiTagView.m
//  MobileResume
//
//  Created by Li XiangCheng on 13-11-25.
//  Copyright (c) 2013年 人人猎头. All rights reserved.
//

#import "MultiTagView.h"

@interface MultiTagView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation MultiTagView

#pragma mark init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.dataSource = self;
    self.delegate = self;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.scrollEnabled = NO;
    self.rowHeight = 42;
    self.tagCount = 0;
    self.tags = [[NSMutableArray alloc] initWithCapacity:kMaxTagCount];
    self.tagLabels = [[NSMutableArray alloc] initWithCapacity:kMaxTagCount];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.relatedCellIndexPaths = [[NSMutableDictionary alloc] initWithCapacity:kMaxTagCount];
    self.relatedCellLevels = [[NSMutableDictionary alloc] initWithCapacity:kMaxTagCount];
#pragma clang diagnostic pop
}

#pragma mark - Public Methods

- (void)setFont:(UIFont *)font {
    _font = font;
    
    [self.tagLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILabel *label = obj;
        label.font = font;
    }];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    _lineBreakMode = lineBreakMode;
    
    [self.tagLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILabel *label = obj;
        label.lineBreakMode = lineBreakMode;
    }];
}

#pragma mark - Add / Remove Tag

- (void)addTag:(NSString *)tag {
    if (self.tagCount == kMaxTagCount) {
        return;
    }
    
    [self.tags addObject:tag];
    self.tagCount++;
    [self reloadData];
}

- (void)addTag:(NSString *)tag relatedCellIndexPath:(NSIndexPath *)indexPath {
    [self addTag:tag];
    [self.relatedCellIndexPaths setObject:indexPath forKey:tag];
}

- (void)addTag:(NSString *)tag relatedCellIndexPath:(NSIndexPath *)indexPath level:(NSUInteger)level {
    [self addTag:tag relatedCellIndexPath:indexPath];
    [self.relatedCellLevels setObject:@(level) forKey:tag];
}

- (void)removeTag:(NSString *)tag {
    if (self.tagCount == 0) {
        return;
    }
    
    [self.tags removeObject:tag];
    self.tagCount--;
    [self reloadData];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (self.relatedCellIndexPaths[tag]) {
        [self.relatedCellIndexPaths removeObjectForKey:tag];
    }
    if (self.relatedCellLevels[tag]) {
        [self.relatedCellLevels removeObjectForKey:tag];
    }
#pragma clang diagnostic pop
}

#pragma mark - Action

- (void)removeButtonTapped:(UIButton *)sender {
    UILabel *label = (UILabel *)[sender.superview viewWithTag:100];
    NSString *tagName = label.text;
    
    NSUInteger index = [self.tags indexOfObject:tagName];
    
    [self removeTag:tagName];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveTags" object:@{@"level": @1, @"tagName": tagName, @"removeIndex": @(index)}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [self.tagLabels removeAllObjects];
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tags.count > 0) {
        return (self.tags.count - 1) / 3 + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    __block CGFloat x = 15;
    CGFloat y = 6;
    CGFloat interval = 5;
    CGFloat tagWidth = (self.bounds.size.width-x)/3-interval;//95
    CGFloat tagHeight = 30;
    
    NSInteger start, max;
    switch (indexPath.row) {
        case 0:
            start = 0;
            max = (self.tags.count > 3 ? 3 : self.tags.count);
            break;
        case 1:
            start = 3;
            max = (self.tags.count > 6 ? 6 : self.tags.count);
            break;
        case 2:
            start = 6;
            max = self.tags.count;
            break;
            
        default:
            start = 0;
            max = 0;
            break;
    }
    
    for (NSInteger i = start; i < max; i++) {
        UIView *tagBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(x, y, tagWidth, tagHeight)];
        tagBackgroundView.backgroundColor = [UIColor clearColor];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(0, 0, tagBackgroundView.frame.size.width, tagBackgroundView.frame.size.height);
        [btn setBackgroundImage:[UIImage createImageWithColor:MKRGBA(204,204,204,255)] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
        //设置Button为圆角
        btn.layer.masksToBounds=YES; //设置为yes，就可以使用圆角
        btn.layer.cornerRadius = 4.0;//设置它的圆角大小
        btn.layer.borderWidth = 1.0;//视图的边框宽度
        //btn.layer.backgroundColor =MKRGBA(240,240,240,255).CGColor;
        btn.layer.borderColor = MKRGBA(204,204,204,255).CGColor;//视图的边框颜色
        [btn addTarget:self action:@selector(removeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [tagBackgroundView addSubview:btn];
        
        //UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(7, 0, 57, tagHeight)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(7, 0, tagWidth-38, tagHeight)];
        label.text = self.tags[i];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor=MKRGBA(66,66,66,255);
        label.lineBreakMode = NSLineBreakByClipping;
        label.backgroundColor = [UIColor clearColor];
        label.tag = 100;
        [tagBackgroundView addSubview:label];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"tag_close"] forState:UIControlStateNormal];
        [button sizeToFit];
        button.center = CGPointMake(tagBackgroundView.width - 15, label.height / 2);
        [button addTarget:self action:@selector(removeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [tagBackgroundView addSubview:button];
        
        [cell.contentView addSubview:tagBackgroundView];
        
        [self.tagLabels addObject:label];
        self.font = label.font;
        self.lineBreakMode = label.lineBreakMode;
        
        x += tagWidth + interval;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 42;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 7;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 6)];
    view.backgroundColor=[UIColor whiteColor];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 5, tableView.bounds.size.width, 1)];
    line.backgroundColor=MKRGBA(246,246,248,255);
    [view addSubview:line];
    
    return view;
}

@end
