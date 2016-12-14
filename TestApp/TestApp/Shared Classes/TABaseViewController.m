//
//  TABaseViewController.m
//  TestApp
//
//  Created by Atul Khatri on 21/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import "TABaseViewController.h"

@interface TABaseViewController ()

@end

@implementation TABaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
