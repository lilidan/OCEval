//
//  ViewController.m
//  OCEvalDemo
//
//  Created by sgcy on 2018/11/21.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "OCEval.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [OCEval eval:@"return objc_getAssociatedObject(self, @\"data\");" context:[@{@"self":self} mutableCopy]];
    if (array) {
        return array.count;
    }else{
        return 0;
    }
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 0;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    NSArray *array = [OCEval eval:@"return objc_getAssociatedObject(self, @\"data\");" context:[@{@"self":self} mutableCopy]];
    NSDictionary *model = array[indexPath.row];
    cell.textLabel.text = model[@"date"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@~%@ %@",model[@"low"],model[@"high"],model[@"text"]];
    return cell;
}

@end
