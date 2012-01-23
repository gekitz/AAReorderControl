//
//  FirstViewController.h
//  AAReorderSample
//
//  Created by Georg Kitz on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    UITableView *_tableView1;
    UITableView *_tableView2;
}

@end
