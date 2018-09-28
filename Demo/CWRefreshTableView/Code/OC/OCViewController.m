//
//  OCViewController.m
//  CWRefreshTableView
//
//  Created by 罗泰 on 2018/9/28.
//  Copyright © 2018年 chenwang. All rights reserved.
//

#import "OCViewController.h"

#import "CWRefreshTable.h"

@interface OCViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) CWRefreshTable                *tableView;

@property (nonatomic, strong) NSMutableArray<NSNumber *>    *dataArr;

@property (nonatomic, assign) NSInteger                     pageIndex;

@end

@implementation OCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    
    self.pageIndex = 1;
}


#pragma mark - CONFIGURE UI
- (void)configureUI {
    [self.view addSubview:self.tableView];
    
}


#pragma mark - NETWORK
- (void)requestData:(NSInteger)pageIndex {
    /// 这里模拟网络请求.
    NSInteger count = self.tableView.pageSize;
    NSMutableArray *arr = [NSMutableArray array];
//    if (pageIndex < 5)
//    {
//        // 前四页有数据
//        for (int i = 0; i < count; i++)
//        {
//            NSInteger number = (pageIndex - 1) * count + i;
//            [arr addObject:@(number)];
//        }
//    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self handleData:arr pageIndex:pageIndex];
    });
}

- (void)handleData:(NSArray *)arr pageIndex:(NSInteger)pageIndex {
    if (arr)
    {
        self.pageIndex = pageIndex;
       
    }
    
    [self.tableView endRefreshWithDesArr:arr srcArr:self.dataArr pageIndex:pageIndex];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cell_id = @"cell_id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cell_id];
    }
    NSString *contentString = [NSString stringWithFormat:@"%@", self.dataArr[indexPath.row]];
    cell.textLabel.text = contentString;
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

#pragma mark GETTER
- (CWRefreshTable *)tableView {
    if(!_tableView)
    {
        self.tableView = [[CWRefreshTable alloc] initWithFrame:self.view.bounds
                                                         style: UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        __weak typeof (&*self) weakSelf = self;
        [_tableView setRefreshHeader:nil block:^{
            [weakSelf requestData:1];
        }];
        
        [_tableView setLoadMore:nil block:^{
            [weakSelf requestData:weakSelf.pageIndex + 1];
        }];
    }
    return _tableView;
}

- (NSMutableArray<NSNumber *> *)dataArr {
    
    if(!_dataArr)
    {
        self.dataArr = [NSMutableArray array];
    }
    return _dataArr;
}
@end
