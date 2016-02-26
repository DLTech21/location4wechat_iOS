//
//  LocationSearchDisplayController.h
//  LocationMark
//
//  Created by Donal Tong on 16/2/26.
//  Copyright © 2016年 Donal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationSearchDisplayController : UISearchDisplayController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>
@property (strong, nonatomic) NSMutableArray *resultsSource;

@property (nonatomic) UITableViewCellEditingStyle editingStyle;

@property (copy) UITableViewCell * (^cellForRowAtIndexPathCompletion)(UITableView *tableView, NSIndexPath *indexPath);
@property (copy) BOOL (^canEditRowAtIndexPath)(UITableView *tableView, NSIndexPath *indexPath);
@property (copy) CGFloat (^heightForRowAtIndexPathCompletion)(UITableView *tableView, NSIndexPath *indexPath);
@property (copy) void (^didSelectRowAtIndexPathCompletion)(UITableView *tableView, NSIndexPath *indexPath);
@property (copy) void (^didDeselectRowAtIndexPathCompletion)(UITableView *tableView, NSIndexPath *indexPath);
@end
