//
//  FirstViewController.m
//  AAReorderSample
//
//  Created by Georg Kitz on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "AAReorderCell.h"

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView1 = [[UITableView alloc] initWithFrame:CGRectMake(50, 50, 320, 480) style:UITableViewStyleGrouped];
    _tableView1.delegate = self;
    _tableView1.dataSource = self;
    [self.view addSubview:_tableView1];
    
    _tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(420, 50, 320, 480) style:UITableViewStyleGrouped];
    _tableView2.delegate = self;
    _tableView2.dataSource = self;
    [self.view addSubview:_tableView2];
    
    self.title = @"Controller 1";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _data1 = [NSMutableArray array];
    _data2 = [NSMutableArray array];
    
    for (NSInteger count = 0; count < 50; count++) {
        [_data1 addObject:[NSString stringWithFormat:@"Row %d", count]];
        [_data2 addObject:@""];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    
    [_tableView1 setEditing:editing animated:animated];
    [_tableView2 setEditing:editing animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TableView DataSource Methods 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_data1 count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier";
    AAReorderCell *cell = (AAReorderCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[AAReorderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.reorderDelegate = self;
    }
   
    cell.textLabel.text = [NSString stringWithFormat:@"Row %d", indexPath.row];
    if (_tableView1 == tableView) {
         cell.title = [_data1 objectAtIndex: indexPath.row];   
    } else {
         cell.title = [_data2 objectAtIndex: indexPath.row];           
    }
    
    return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ReorderDelegate Methods 

- (void)didEndReorderingForView:(AAReorderContentView *)view 
                  fromIndexPath:(NSIndexPath *)fromIndexPath inTable:(UITableView *)fromTableView 
                    toIndexPath:(NSIndexPath *)toIndexPath inTable:(UITableView *)toTableView{
    
    NSMutableArray *fromArray = (fromTableView == _tableView1) ? _data1 : _data2;
    NSMutableArray *toArray = (toTableView == _tableView1) ? _data1 : _data2;
    
    NSString *value = [fromArray objectAtIndex:fromIndexPath.row];
    
    [fromArray removeObjectAtIndex:fromIndexPath.row];
    [fromArray insertObject:@"" atIndex:fromIndexPath.row];
    
    [toArray removeObjectAtIndex:toIndexPath.row];
    [toArray insertObject:value atIndex:toIndexPath.row];
    
    [_tableView1 reloadData];
    [_tableView2 reloadData];
}

@end
