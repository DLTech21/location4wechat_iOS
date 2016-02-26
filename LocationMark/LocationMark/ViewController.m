//
//  ViewController.m
//  LocationMark
//
//  Created by Donal Tong on 16/2/26.
//  Copyright © 2016年 Donal. All rights reserved.
//
#import "ViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入搜索功能所有的头文件

#import "AddressDetailCell.h"
#import "Place.h"
#import "LocationSearchDisplayController.h"
#import "UIView+Utils.h"

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height
#define WEAKSELF typeof(self) __weak weakSelf = self;
@interface ViewController ()<BMKMapViewDelegate,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate,UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, BMKSuggestionSearchDelegate, BMKPoiSearchDelegate  >
{
    UIImageView *_bomeImage;
    
    BMKPinAnnotationView *newAnnotation;
    
    BMKGeoCodeSearch *_geoCodeSearch;
    
    BMKReverseGeoCodeOption *_reverseGeoCodeOption;
    
    BMKLocationService *_locService;
    
    NSMutableArray *_addArray;
    
    UITableView *_tableView;
    
    BOOL isTouch;
    
    CLLocationCoordinate2D currentPt;
    NSString * currentAddress;
    UISearchBar *_searchBar;
    BMKSuggestionSearch *_searcher;
    NSMutableArray *pois;
    BMKPoiSearch *_poisearch;
    
}
@property (strong, nonatomic) BMKMapView *mapView;
@property (strong, nonatomic) LocationSearchDisplayController *searchController;
@end

@implementation ViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_mapView viewWillAppear];
    _mapView.delegate=self;
    _geoCodeSearch.delegate=self;
    _locService.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; //不用时，置nil
    _geoCodeSearch.delegate=nil;
    _locService.delegate = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _addArray=[NSMutableArray array];
    isTouch = YES;
    [self initNavBar];
    [self initLocationService];
    [self initMap];
    [self.view addSubview:self.searchBar];
    [self initTableView];
    [self initBomeImage];
    [self searchController];
    _searcher =[[BMKSuggestionSearch alloc]init];
    _searcher.delegate = self;
    pois = [NSMutableArray new];
    _poisearch = [[BMKPoiSearch alloc] init];
    _poisearch.delegate = self;
}

- (void)initNavBar {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sendLocation)];
    [button setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16],
                                     NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = button;
    
    self.title = @"位置";
    
}

-(void)sendLocation
{
    [self.delegate sendLocationLatitude:currentPt.latitude longitude:currentPt.longitude andAddress:currentAddress];
}

//放置中间大头针
-(void)initBomeImage
{
    if (_bomeImage==nil) {
        
        _bomeImage=[[UIImageView alloc]initWithFrame:CGRectMake(screen_width/2-25, _mapView.height/2-50, 50, 50)];
        _bomeImage.image=[UIImage imageNamed:@"pic_pin_serach_MapModel"];
    }
    [_mapView addSubview:_bomeImage];
}


//初始化显示列表
-(void)initTableView
{
    if (_tableView==nil) {
        
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, screen_height/2, screen_width, screen_height/2) style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.tableFooterView=[[UIView alloc]init];
        
    }
    [self.view addSubview:_tableView];
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 64, self.view.frame.size.width, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索地点";
        _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
    }
    
    return _searchBar;
}

-(void)initMap
{
    if (_mapView==nil) {
        
        _mapView=[[BMKMapView alloc]initWithFrame:CGRectMake(0, 44, screen_width, screen_height/2)];
        
        [_mapView setMapType:BMKMapTypeStandard];// 地图类型 ->卫星／标准、
        
        _mapView.zoomLevel=19;
        
        _mapView.showsUserLocation = YES;
    }
    
    _mapView.delegate=self;
    
    _mapView.centerCoordinate = CLLocationCoordinate2DMake(121, 112);
    
    [self.view addSubview:_mapView];
    
}

-(void)initLocationService
{
    if (_locService==nil) {
        
        _locService = [[BMKLocationService alloc]init];
        
        [_locService setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    
    _locService.delegate = self;
    
    [_locService startUserLocationService];
    
}

- (LocationSearchDisplayController *)searchController
{
    if (_searchController == nil) {
        _searchController = [[LocationSearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        WEAKSELF
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            
            static NSString *identfire=@"cellID";
            
            AddressDetailCell *cell=[tableView dequeueReusableCellWithIdentifier:identfire];
            
            if (!cell) {
                
                cell=[[[NSBundle mainBundle] loadNibNamed:@"AddressDetailCell" owner:nil options:nil] firstObject];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
            }
            Place *p = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            cell.place = p;
            return cell;
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return 50;
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [weakSelf.searchController.searchBar endEditing:YES];
            weakSelf.searchController.active = NO;
            Place *place = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            isTouch = NO;
            weakSelf.mapView.centerCoordinate = place._pt;
            currentPt = place._pt;
            currentAddress = place.name;
        }];
    }
    
    return _searchController;
}
#pragma mark BMKLocationServiceDelegate
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    //设置地图中心为用户经纬度
    [_mapView updateLocationData:userLocation];
    _mapView.centerCoordinate = userLocation.location.coordinate;
    currentPt = userLocation.location.coordinate;
    currentAddress = userLocation.title;
}

#pragma mark BMKMapViewDelegate

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //屏幕坐标转地图经纬度
    CLLocationCoordinate2D MapCoordinate=[_mapView convertPoint:_mapView.center toCoordinateFromView:_mapView];
    
    if (_geoCodeSearch==nil) {
        //初始化地理编码类
        _geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
        _geoCodeSearch.delegate = self;
        
    }
    if (_reverseGeoCodeOption==nil) {
        
        //初始化反地理编码类
        _reverseGeoCodeOption= [[BMKReverseGeoCodeOption alloc] init];
    }
    //    if (isTouch) {
    //需要逆地理编码的坐标位置
    _reverseGeoCodeOption.reverseGeoPoint =  CLLocationCoordinate2DMake(MapCoordinate.latitude,MapCoordinate.longitude);
    [_geoCodeSearch reverseGeoCode:_reverseGeoCodeOption];
    //    }
}

#pragma mark BMKGeoCodeSearchDelegate

-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    //获取周边用户信息
    if (error==BMK_SEARCH_NO_ERROR) {
        
        [_addArray removeAllObjects];
        for(BMKPoiInfo *poiInfo in result.poiList)
        {
            Place *place=[[Place alloc]init];
            place.name=poiInfo.name;
            place.address=poiInfo.address;
            place._pt = poiInfo.pt;
            [_addArray addObject:place];
            [_tableView reloadData];
        }
    }else{
        
        NSLog(@"BMKSearchErrorCode: %u",error);
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _addArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identfire=@"cellID";
    
    AddressDetailCell *cell=[tableView dequeueReusableCellWithIdentifier:identfire];
    
    if (!cell) {
        
        cell=[[[NSBundle mainBundle] loadNibNamed:@"AddressDetailCell" owner:nil options:nil] firstObject];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    cell.place=_addArray[indexPath.row];
    
    return cell;
}

//设置cell分割线做对齐
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Place *place =_addArray[indexPath.row];
    isTouch = NO;
    _mapView.centerCoordinate = place._pt;
    currentPt = place._pt;
    currentAddress = place.name;
    
}

-(void)viewDidLayoutSubviews {
    
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    BMKSuggestionSearchOption* option = [[BMKSuggestionSearchOption alloc] init];
    option.cityname = @"";
    option.keyword  = searchText;
    [_searcher suggestionSearch:option];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        CGRect statusBarFrame =  [[UIApplication sharedApplication] statusBarFrame];
        [UIView animateWithDuration:0.25 animations:^{
            for (UIView *subview in self.view.subviews)
                subview.transform = CGAffineTransformMakeTranslation(0, statusBarFrame.size.height);
        }];
    }
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [UIView animateWithDuration:0.25 animations:^{
            for (UIView *subview in self.view.subviews)
                subview.transform = CGAffineTransformIdentity;
        }];
    }
}

//实现Delegate处理回调结果
- (void)onGetSuggestionResult:(BMKSuggestionSearch*)searcher result:(BMKSuggestionResult*)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        [self.searchController.resultsSource removeAllObjects];
        [self.searchController.searchResultsTableView reloadData];
        for (NSString *poiId in result.poiIdList) {
            BMKPoiDetailSearchOption* option = [[BMKPoiDetailSearchOption alloc] init];
            option.poiUid = poiId;//POI搜索结果中获取的uid
            [_poisearch poiDetailSearch:option];
        }
    }
    else {
    }
}

-(void)onGetPoiDetailResult:(BMKPoiSearch *)searcher
                     result:(BMKPoiDetailResult *)poiDetailResult
                  errorCode:(BMKSearchErrorCode)errorCode
{
    if(errorCode == BMK_SEARCH_NO_ERROR){
        Place *p = [Place new];
        p.name = poiDetailResult.name;
        p.address = poiDetailResult.address;
        p._pt = poiDetailResult.pt;
        [self.searchController.resultsSource addObject:p];
        [self.searchController.searchResultsTableView reloadData];
    }
}

@end

