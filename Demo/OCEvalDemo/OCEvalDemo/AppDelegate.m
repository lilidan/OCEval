//
//  AppDelegate.m
//  OCEvalDemo
//
//  Created by sgcy on 2018/11/21.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "AppDelegate.h"
#import "OCEval.h"
#import <objc/runtime.h>
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString *viewDidload = @"{\
    [OCCfuntionHelper defineCFunction:@\"objc_setAssociatedObject\" types:@\"void,id,void *,id,unsigned int\"];\
    [OCCfuntionHelper defineCFunction:@\"objc_getAssociatedObject\" types:@\"id,id,void *\"];\
    [originalInvocation invoke];\
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:0];\
    [self.view addSubview:tableView];\
    tableView.delegate = self;\
    tableView.dataSource = self;\
    NSURL *url = [NSURL URLWithString:@\"https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22nome%2C%20ak%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys\"];\
    NSURLRequest *request = [NSURLRequest requestWithURL:url];\
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {\
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];\
    NSArray *array = dic[@\"query\"][@\"results\"][@\"channel\"][@\"item\"][@\"forecast\"];\
    objc_setAssociatedObject(self, @\"data\", array, 1);\
    [tableView reloadData];\
    }];}\
";
    
    [OCEval hookClass:@"ViewController"
             selector:@"viewDidLoad"
             argNames:@[]
              isClass:NO
       implementation:viewDidload];
    
    
    NSString *numberOfRowsInSection = @"{NSArray *array = objc_getAssociatedObject(self, @\"data\");\
    if (array != nil) {\
        return array.count;\
    }else{\
        return 3;\
    }\
    }";
    
    [OCEval hookClass:@"ViewController"
             selector:@"tableView:numberOfRowsInSection:"
             argNames:@[@"tableView",@"section"]
              isClass:NO
       implementation:numberOfRowsInSection];
    
    
    
    
    return YES;
    

}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
