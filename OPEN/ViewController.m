//
//  ViewController.m
//  OPEN
//
//  Created by jing huang on 2019/8/22.
//  Copyright © 2019 jing huang. All rights reserved.
//

#import "ViewController.h"
#import "TestView.h"
#import "TriangleView.h"
#import "TextureView.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_listArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _listArray = @[@"三角形",@"绘图",@"金子塔",@"地球自转",@"魔方",@"图片"];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 160)];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"123"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"123"];
    }
    cell.textLabel.text = _listArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *vc = [[UIViewController alloc] init];
    
    UIView *view = [[UIView alloc] init];
    if (indexPath.row == 0) {
        view = [[TriangleView alloc] initWithFrame:self.view.bounds];
    }
    if (indexPath.row == 1) {
        view = [[TestView alloc] initWithFrame:self.view.bounds];
    }
    if (indexPath.row == 2) {
//        view = [[NSClassFromString(@"TowerView") alloc] initWithFrame:self.view.bounds];
        
        vc = [[NSClassFromString(@"TowerViewController") alloc] init];
    }
    if (indexPath.row == 3) {
        vc = [[NSClassFromString(@"EarthViewController") alloc] init];
    }
    if (indexPath.row == 4) {
        vc = [[NSClassFromString(@"MagicCubeViewController") alloc] init];
    }
    if (indexPath.row == 5) {
        view = [[TextureView alloc] initWithFrame:self.view.bounds];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [vc.view addSubview:view];
    });
}


@end
