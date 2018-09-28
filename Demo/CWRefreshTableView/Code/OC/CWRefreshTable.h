//
//  CWRefreshTable.h
//  CWRefreshTableView
//
//  Created by 罗泰 on 2018/9/27.
//  Copyright © 2018年 chenwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

NS_ASSUME_NONNULL_BEGIN

/**
 刷新类型

 - CWRefreshTableRefreshType_refresh: 下拉刷新
 - CWRefreshTableRefreshType_loadMore: 上拉加载
 */
typedef NS_ENUM(NSUInteger, CWRefreshTableRefreshType) {
    CWRefreshTableRefreshType_refresh = 1,
    CWRefreshTableRefreshType_loadMore = 2,
};

@interface CWRefreshTable : UITableView
#pragma mark - PROPERTY

/**
 每页数据量,默认为20
 */
@property (nonatomic, assign) NSInteger pageSize;

#pragma mark - METHOD

/**
 使用代码触发下拉刷新事件
 */
- (void)beginRefresh;


/**
 使用代码触发上拉加载事件
 */
- (void)beginLoadMore;


/**
 结束刷新

 @param desArr 请求到的数据源数组
 @param srcArr 现有的数据源数组
 @param index 当前分页数: 内部代码是从1开始算的(不是从0开始算的,如果外部逻辑是从0开始算的,请自行转换一下)
 */
- (void)endRefreshWithDesArr:(NSArray *)desArr
                      srcArr:(NSMutableArray *)srcArr
                   pageIndex:(NSInteger)index;


/**
 设置下拉刷新

 @param header 自定义的下拉刷新控件,如果传nil,默认为:MJRefreshNormalHeader
 @param block 下拉事件回调, 如果传nil则不会创建控件
 */
- (void)setRefreshHeader:(nullable MJRefreshHeader *)header
                   block:(void(^)(void)) block;



/**
 设置上拉加载

 @param footer 自定义的上拉加载控件, 如果传nil, 默认为:MJRefreshAutoNormalFooter
 @param block 上拉事件回调, 如果传nil则不会创建控件
 */
- (void)setLoadMore:(nullable MJRefreshFooter *)footer
              block:(void(^)(void)) block;

@end

NS_ASSUME_NONNULL_END
