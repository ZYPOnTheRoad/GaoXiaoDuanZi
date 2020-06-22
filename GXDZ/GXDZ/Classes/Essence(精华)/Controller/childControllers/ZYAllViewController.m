//
//  ZYAllViewController.m
//  GXDZ
//
//  Created by ZYP OnTheRoad on 2020/6/18.
//  Copyright © 2020 ZYP OnTheRoad. All rights reserved.
//

#import "ZYAllViewController.h"
#import "ZYTopicCell.h"
#import "ZYTopicItem.h"


static NSString *ID = @"ZYTopicCell";
@interface ZYAllViewController ()

@property (nonatomic ,strong) NSString *maxtime;
@property (nonatomic, strong) NSMutableArray *topicItems;
@property (nonatomic ,weak) AFHTTPSessionManager *manager;

@end

@implementation ZYAllViewController
#pragma mark- 懒加载
- (NSMutableArray *)topicItems {
    if (!_topicItems) {
        _topicItems = [NSMutableArray array];
    }
    return _topicItems;
}
- (AFHTTPSessionManager *)manager {
    if (!_manager) {
       AFHTTPSessionManager *manager =  [AFHTTPSessionManager manager];
        _manager = manager;
    }
    return _manager;
 }
   
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadNewData];
    
    [self setUpTableView];
    
    [self setUpRefreshView];
}

- (void)setUpTableView {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:ZYTopicCell.class forCellReuseIdentifier:ID];
    
}

- (void)setUpRefreshView {
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    //根据拖拽比例自动改变透明度
    header.automaticallyChangeAlpha = YES;
    self.tableView.mj_header = header;
    
    //上拉刷新
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    if (!self.topicItems.count) footer.hidden = YES;
    self.tableView.mj_footer = footer;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //设置滚动指示器的 插入
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}
#pragma mark - 加载新数据
- (void)loadNewData {
    //取消之前任务
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"a"] = @"list";
    parameters[@"c"] = @"data";
    parameters[@"tybe"] = @(ZYTopicItemTypeAll);
    
    [self.manager GET:kURL_STRING parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, NSDictionary  *responseObject) {
    
        //1.结束刷新
        [self.tableView.mj_header endRefreshing];
        //有数据 显示 mj_footer
        self.tableView.mj_footer.hidden = NO;
        //2.保存下一页最大ID
        self.maxtime = responseObject[@"info"][@"maxtime"];
        //3.字典转模型并添加到数组
        
        NSMutableArray *tmp = [NSMutableArray array];
        for (NSDictionary *dict in responseObject[@"list"]) {
            [tmp addObject:[ZYTopicItem topicItemWithDict:dict]];
        }
        //每次加载新数据时重新覆盖之前的数据
        self.topicItems = tmp;
        //4.刷新列表
        [self.tableView reloadData];
    } failure:nil];
}

#pragma mark- 加载更多数据
- (void)loadMoreData {
    //取消之前任务
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"a"] = @"list";
    parameters[@"c"] = @"data";
    parameters[@"maxtime"] = _maxtime;
    parameters[@"tybe"] = @(ZYTopicItemTypeAll);
    
    [self.manager GET:kURL_STRING parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, NSDictionary  *responseObject) {
       
        //1.结束刷新
        [self.tableView.mj_footer endRefreshing];
        //2.保存下一页最大ID
        self.maxtime = responseObject[@"info"][@"maxtime"];
        //3.字典转模型并添加到数组
        for (NSDictionary *dict in responseObject[@"list"]) {
            [self.topicItems addObject:[ZYTopicItem topicItemWithDict:dict]];
        }
        //4.刷新列表
        [self.tableView reloadData];
    } failure:nil];
    
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.topicItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZYTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    cell.topicItem = self.topicItems[indexPath.row];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZYTopicItem *topicItem = self.topicItems[indexPath.row];
    
    return topicItem.cellHeight;
}
@end
