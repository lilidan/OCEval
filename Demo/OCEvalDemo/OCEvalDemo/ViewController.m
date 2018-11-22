//
//  ViewController.m
//  OCEvalDemo
//
//  Created by sgcy on 2018/11/21.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray *data;
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:0];
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.data;
    if (array) {
        return array.count;
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    NSArray *array = self.data;
    NSDictionary *model = array[indexPath.row];
    cell.textLabel.text = model[@"date"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@~%@ %@",model[@"low"],model[@"high"],model[@"text"]];
    return cell;
}



@end
