//
//  ListViewController.m
//  OCEvalDemo
//
//  Created by sgcy on 2018/11/27.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "ListViewController.h"
#import "JobModel.h"
#import "JobCell.h"

@interface ListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *models;
@property (nonatomic,strong) NSOperationQueue *queue;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:0];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = [UIView new];
    [self.view addSubview:self.tableView];
    self.queue = [[NSOperationQueue alloc] init];
//    [self.tableView registerClass:[JobCell class] forCellReuseIdentifier:@"cell"];
    [self fetchData];
}

- (void)fetchData
{
    NSURL *url = [NSURL URLWithString:@"https://jobs.github.com/positions.json?page=1&search=iOS"];
                  NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSMutableArray *models = [NSMutableArray new];
        for (NSDictionary *dic in array) {
            JobModel *model = [[JobModel alloc] init];
            [model setValuesForKeysWithDictionary:dic];
            [models addObject:model];
        }
        self.models = [models copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.models) {
        return self.models.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JobCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[JobCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    JobModel *model = self.models[indexPath.row];
    [cell setModel:model];
    return cell;
}

@end
