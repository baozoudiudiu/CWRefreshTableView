//
//  CWRefreshTable.m
//  CWRefreshTableView
//
//  Created by 罗泰 on 2018/9/27.
//  Copyright © 2018年 chenwang. All rights reserved.
//

#import "CWRefreshTable.h"

@interface CWRefreshTable (){
    
}
@property (nonatomic, copy) void (^refreshBlock)(void);
@property (nonatomic, copy) void (^loadMoreBlock)(void);

@property (nonatomic, strong) UIView                    *noDataView;
@end


@implementation CWRefreshTable
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style])
    {
        self.pageSize = 20;
        [self configureView];
    }
    return self;
}


#pragma mark - LOGIC
- (void)refreshActionHandle {
    if(self.refreshBlock)
    {
        self.refreshBlock();
    }
}


- (void)loadMoreActionHandle {
    if(self.loadMoreBlock)
    {
        self.loadMoreBlock();
    }
}


- (void)beginRefresh {
    if(self.mj_header)
    {
        if(self.mj_footer)
        {
            self.mj_footer.hidden = YES;
        }
        [self.mj_header beginRefreshing];
    }
}


- (void)beginLoadMore {
    if(self.mj_footer)
    {
        [self.mj_footer beginRefreshing];
    }
}

- (void)endRefreshWithDesArr:(NSArray *)desArr srcArr:(NSMutableArray *)srcArr pageIndex:(NSInteger)index {
    NSInteger count;
    
    if (!desArr ||
        [desArr isKindOfClass:[NSNull class]])
    {
        desArr = @[];
        count = 0;
    }
    else
    {
        count = desArr.count;
    }
    
    CWRefreshTableRefreshType type = index == 1 ? CWRefreshTableRefreshType_refresh : CWRefreshTableRefreshType_loadMore;
    switch (type)
    {
        case CWRefreshTableRefreshType_refresh:
        {
            if (srcArr)
            {
                [srcArr removeAllObjects];
                [srcArr addObjectsFromArray:desArr];
            }
        }
            break;
        case CWRefreshTableRefreshType_loadMore:
        {
            if (srcArr)
            {
                [srcArr addObjectsFromArray:desArr];
            }
        }
            break;
    }
    [self endRefreshWithType:type count:count];
}


- (void)endRefreshWithType:(CWRefreshTableRefreshType)refreshType count:(NSInteger)dataCount {
    switch (refreshType)
    {
        case CWRefreshTableRefreshType_refresh:
        {
            if (self.mj_header.isRefreshing)
            {
                [self.mj_header endRefreshing];
            }
            
            if (self.mj_footer)
            {
                self.mj_footer.hidden = NO;
                if(dataCount < self.pageSize)
                {
                    [self.mj_footer endRefreshingWithNoMoreData];
                }
                else
                {
                    [self.mj_footer resetNoMoreData];
                }
            }
            
            if (dataCount > 0)
            {
                [self hiddenNoDataView];
            }
            else
            {
                [self showNoDataView];
            }
        }
            break;
        case CWRefreshTableRefreshType_loadMore:
        {
            if (self.mj_footer.isRefreshing)
            {
                if(dataCount < self.pageSize)
                {
                    [self.mj_footer endRefreshingWithNoMoreData];
                }
                else
                {
                    [self.mj_footer endRefreshing];
                }
            }
        }
            break;
    }
}

- (UIView *)showNoDataView {
    if (self.mj_footer)
    {
        self.mj_footer.hidden = YES;
    }
    
    self.noDataView.hidden = NO;
    
    return self.noDataView;
}


- (UIView *)hiddenNoDataView {
    self.noDataView.hidden = YES;
    return self.noDataView;
}

#pragma mark - CONFIGURE UI 设置
- (void)configureView {
    self.estimatedRowHeight = 0;
    self.estimatedSectionHeaderHeight = 0;
    self.estimatedSectionFooterHeight = 0;
    
    self.tableFooterView = [UIView new];
}


#pragma mark - SETTER
- (void)setRefreshHeader:(MJRefreshHeader *)header block:(void(^)(void)) block {
    if (!block)
    {
        self.mj_header = nil;
        self.refreshBlock = nil;
        return;
    }
    
    if (!header)
    {
        header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                  refreshingAction:@selector(refreshActionHandle)];
    }
    
    self.mj_header = header;
    self.refreshBlock = block;
}


- (void)setLoadMore:(MJRefreshFooter *)footer block:(void(^)(void)) block {
    
    if (!block)
    {
        self.mj_footer = nil;
        self.loadMoreBlock = nil;
        return;
    }
    
    if (!footer)
    {
        footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self
                                                      refreshingAction:@selector(loadMoreActionHandle)];
    }
    
    self.mj_footer = footer;
    self.loadMoreBlock = block;
    
    if (self.mj_header)
    {
        self.mj_footer.hidden = YES;
        __weak typeof (&*self) weakSelf = self;
        [self.mj_header setRefreshingBlock:^{
            weakSelf.mj_footer.hidden = YES;
        }];
    }
}

- (void)customNoDataView:(UIView *)nodataView {
    if (nodataView)
    {
        [self.noDataView removeFromSuperview];
        nodataView.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5
                                        , CGRectGetHeight(self.frame) * 0.5);
        self.noDataView = nodataView;
        self.noDataView.hidden = YES;
        [self addSubview:self.noDataView];
    }
    
}

#pragma mark - GETTER
- (UIView *)noDataView {
    if(!_noDataView)
    {
        self.noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 30)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:_noDataView.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"没有数据";
        [_noDataView addSubview:label];
        
        _noDataView.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5
                                             , CGRectGetHeight(self.frame) * 0.5);
        _noDataView.hidden = NO;
        [self addSubview:_noDataView];
    }
    return _noDataView;
}
@end
