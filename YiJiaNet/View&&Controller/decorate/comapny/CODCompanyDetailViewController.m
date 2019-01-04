//
//  CODCompanyDetailViewController.m
//  YiJiaNet
//
//  Created by KUANG on 2018/12/29.
//  Copyright © 2018年 JIARUI. All rights reserved.
//

#import "CODCompanyDetailViewController.h"
#import "CODExamDetailViewController.h"
#import "UINavigationBar+COD.h"
#import "SDCycleScrollView.h"
#import "UIImageView+WebCache.h"
#import "UIButton+COD.h"
#import "UIViewController+COD.h"
#import "CODLayoutButton.h"
#import "CODDecoExamCollectionView.h"
#import "CODExamDetailViewController.h"
#import "JXMapNavigationView.h"
#import "CODSpecialPopView.h"
#import "StoreGoodsCommentCell.h"
#import "MyCommentImfoMode.h"

#import "CODCommentViewController.h"
#import "TWHRichTextTool.h"
#import "CODCalcuQuoteViewController.h"
#import "CODExampleListViewController.h"
#import "CODOrderPopView.h"
#import "CustomIOSAlertView.h"

static CGFloat const kTopViewHeight = 188;// 顶部图高度
#define kOffsety 200.f  // 导航栏渐变的判定值

@interface CODCompanyDetailViewController ()<UITableViewDataSource, UITableViewDelegate, SDCycleScrollViewDelegate>
/** 导航栏 */
@property (nonatomic, strong) UILabel *navTitleLabel;
@property (nonatomic, assign) CGFloat alphaMemory;
@property (nonatomic,strong) UIButton *returnBtn;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) SDCycleScrollView *bannerView;
@property (nonatomic, strong) UILabel *scrollImgNumLabel;

@property (nonatomic, strong) CODDecoExamCollectionView *examCollectionView;
@property (nonatomic, strong) NSArray *exampleArray;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *collectButton;


@property (nonatomic, assign) BOOL isFirstPush;

@property (nonatomic, strong) JXMapNavigationView *mapNavigationView;
@property (nonatomic, strong) CODSpecialPopView *specialPopView;
@property (nonatomic, strong) NSArray *specialArray;

/** 详情数据信息 */
@property (nonatomic,strong) NSMutableDictionary *imfoDic;
@property (nonatomic,strong) NSMutableDictionary *Dic;
/** 查看全部评价尾部视图 */
@property (nonatomic,strong)UIView *comentFootVW;
@end

@implementation CODCompanyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationController.navigationBar.cod_backgroundColor = [UIColor clearColor];
    [self SetNav];
    
    [self configureView];
    
    self.exampleArray = @[@{@"title":@"世茂大观程先生雅居",@"subTitle":@"/二居/中式/全装",@"icon":@"place_zxal_detail"},
                       @{@"title":@"龙斗壹号周先生雅居",@"subTitle":@"/三居/中式/全装",@"icon":@"https://pic1.shejiben.com/case/2018/12/13/20181213191302-de334824.jpg"},
                       ];
    
    self.specialArray = @[@{@"title":@"六大设计系统",@"subTitle":@"通风采光系统；动线规划系统；场景收纳系统；灯光设计系统；色彩美观系统；整装风格系统，六大科学设计系统重新定义家的户白岁丈。"},
                          @{@"title":@"智能家居整装",@"subTitle":@"开启拎包入住家装智能家居新时代，提前享受未来；精选国内一线环保主材， 128 项全包， 28 项不限， 6 大费用全免；灯光一键开窍闭合，全屋电器手机可控，离家警戒安防模式；供应链集中配套，超低利润回馈客户；工厂模块化生产工期更合理。"},
                          @{@"title":@"质量保障体系",@"subTitle":@"28 项特色施工工艺高于行业标准，工艺不达标，砸掉重做；环保不达标，全额退款。"},
                          ];

    MyCommentImfoMode *commentModel = [[MyCommentImfoMode alloc] init];
    commentModel.nickname = @"张三";
    commentModel.add_time = @"2018-12-12";
    commentModel.content = @"设计师清风很用心，态度也很好，基本规定时间就可以给方案。节省了我不少的时间，最主要的是做出来的东西我很喜欢~整体风格我很满意。";
    commentModel.images = @[@"",@"",@"",@"",@"",@""];
    commentModel.scores = @"3";
    self.imfoDic = [NSMutableDictionary dictionary];
    [self.imfoDic setObject:commentModel forKey:@"mode"];
    
    [self.tableView reloadData];
    
    @weakify(self);
    [[RACObserve(self, exampleArray) distinctUntilChanged] subscribeNext:^(NSArray *arr) {
        @strongify(self);
        self.examCollectionView.dataArray = arr;
        [self.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    if (@available(iOS 11.0, *)) {
        // tableView 偏移20/64适配
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;//UIScrollView也适用
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.navigationController.navigationBar.translucent = YES;
    self.navTitleLabel.textColor = [UIColor colorWithWhite:0.0 alpha:0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    self.navTitleLabel.textColor = [UIColor colorWithWhite:0.0 alpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View
- (void)configureView {
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0) style:UITableViewStyleGrouped];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = CODColorBackground;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        //        [tableView registerClass:[CODHotTableViewCell class] forCellReuseIdentifier:kCell];
        tableView.tableHeaderView = self.topView;
        
        tableView;
    });
    [self.view addSubview:self.tableView];
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, kTopViewHeight)];
    
    self.bannerView = ({
        SDCycleScrollView *bannerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREENWIDTH, kTopViewHeight) delegate:nil placeholderImage:[UIImage imageNamed:@"placeholder"]];
        bannerView.delegate = self;
        bannerView.showPageControl = NO;
        bannerView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
        bannerView.currentPageDotColor = CODColorTheme;
        bannerView.localizationImageNamesGroup = @[@"icon_banner", @"icon_banner1", @"icon_banner2"];
        bannerView;
    });
    [self.topView addSubview:self.bannerView];
    
    self.tableView.tableHeaderView = self.topView;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 50, 0));
    }];
    
    self.bottomView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_bottom).offset(-50);
            make.left.right.offset(0);
            make.height.equalTo(@50);
        }];
        UIButton *collectBtn = [[UIButton alloc] init];
        [collectBtn SetBtnTitle:@"收藏" andTitleColor:CODColor666666 andFont:kFont(12) andBgColor:nil andBgImg:nil andImg:kGetImage(@"decorate_collection") andClickEvent:@selector(collectAction:) andAddVC:self];
        [collectBtn cod_alignImageUpAndTitleDown];
        [view addSubview:collectBtn];
        self.collectButton = collectBtn;
        [collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view.mas_centerY);
            make.left.offset(10);
            make.top.offset(0);
            make.width.equalTo(@50);
        }];
        UIButton *callBtn = [[UIButton alloc] init];
        [callBtn SetBtnTitle:@"电话" andTitleColor:CODColor666666 andFont:kFont(12) andBgColor:nil andBgImg:nil andImg:kGetImage(@"decorate_collection") andClickEvent:@selector(callAction) andAddVC:self];
        [callBtn cod_alignImageUpAndTitleDown];
        [view addSubview:callBtn];
        [callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view.mas_centerY);
            make.left.equalTo(collectBtn.mas_right).offset(10);
            make.top.offset(0);
            make.width.equalTo(@50);
        }];
        
        UIView *btnBackView = [[UIView alloc] init];
        btnBackView.backgroundColor = CODColorTheme;
        [btnBackView setLayWithCor:18 andLayerWidth:0 andLayerColor:0];
        [view addSubview:btnBackView];
        CGFloat btnBackViewW = SCREENWIDTH - 150 - 10;
        [btnBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view);
            make.left.offset(150);
            make.right.offset(-10);
            make.height.equalTo(@40);
        }];
        
        UIButton *orderBtn = [[UIButton alloc] init];
        [orderBtn SetBtnTitle:@"免费预约" andTitleColor:[UIColor whiteColor] andFont:kFont(12) andBgColor:nil andBgImg:nil andImg:nil andClickEvent:@selector(orderAction) andAddVC:self];
        [btnBackView addSubview:orderBtn];
        [orderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view);
            make.left.offset(0);
            make.width.equalTo(@(btnBackViewW/2));
            make.height.equalTo(@40);
        }];
        UIButton *priceBtn = [[UIButton alloc] init];
        [priceBtn SetBtnTitle:@"为我报价" andTitleColor:[UIColor whiteColor] andFont:kFont(12) andBgColor:nil andBgImg:nil andImg:nil andClickEvent:@selector(priceAction) andAddVC:self];
        [btnBackView addSubview:priceBtn];
        [priceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view);
            make.left.equalTo(orderBtn.mas_right);
            make.right.offset(-10);
            make.height.equalTo(@40);
        }];
        
        view;
    });
}
- (CODDecoExamCollectionView *)examCollectionView {
    if (!_examCollectionView) {
        _examCollectionView = [[CODDecoExamCollectionView alloc] init];
        _examCollectionView.backgroundColor = [UIColor whiteColor];
        @weakify(self);
        _examCollectionView.itemActionBlock = ^(CODDectateExampleModel *model) {
            @strongify(self);
            [self collectViewItmeAction:model];
        };
    }
    return _examCollectionView;
}
- (JXMapNavigationView *)mapNavigationView{
    if (_mapNavigationView == nil) {
        _mapNavigationView = [[JXMapNavigationView alloc]init];
        _mapNavigationView.selfClass = self;
    }
    return _mapNavigationView;
}
- (CODSpecialPopView *)specialPopView{
    if (_specialPopView == nil) {
        _specialPopView = [[CODSpecialPopView alloc]init];
    }
    return _specialPopView;
}

-(UIView *)comentFootVW
{
    if (!_comentFootVW) {
        _comentFootVW = [UIView getAViewWithFrame:CGRectMake(0, 0, SCREENWIDTH,60) andBgColor:[UIColor whiteColor]];
        
        UIButton *scanAllBtn = [UIButton GetBtnWithTitleColor:CODColor333333 andFont:kFont(15) andBgColor:nil andBgImg:nil andImg:nil andClickEvent:@selector(allCommentAction) andAddVC:self andTitle:@"查看全部评价"];
        [_comentFootVW addSubview:scanAllBtn];
        __weak UIView *weakComentFootVW = _comentFootVW;

        [scanAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakComentFootVW.mas_centerX);
            //            make.centerY.equalTo(_comentFootVW.mas_centerY)/*.offset(-10)*/;
            make.bottom.equalTo(weakComentFootVW.mas_bottom).offset(-20);
            make.width.mas_equalTo(130);
            make.height.mas_equalTo(35);
        }];
        [scanAllBtn setLayWithCor:18 andLayerWidth:.8 andLayerColor:CODColor999999];
    }return _comentFootVW;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 3 : 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {//装修公司名
            static NSString * kCompanyCellID = @"companyCellID";
            CODBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCompanyCellID];
            if (!cell) {
                cell = [[CODBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCompanyCellID];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.backgroundColor = [UIColor whiteColor];
                
                UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
                iconImageView.tag = 1;
                [cell.contentView addSubview:iconImageView];
                
                UILabel *compNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 10, SCREENWIDTH-80, 20)];
                compNameLabel.textColor = CODColor333333;
                compNameLabel.tag = 2;
                compNameLabel.font = kFont(16);
                [cell.contentView addSubview:compNameLabel];
                
                UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 40, SCREENWIDTH-80, 20)];
                subTitleLabel.textColor = CODHexColor(0x666666);
                subTitleLabel.tag = 3;
                subTitleLabel.font = kFont(12);
                [cell.contentView addSubview:subTitleLabel];
                
                UIView *linView = [[UIView alloc] initWithFrame:CGRectMake(0, 69, SCREENWIDTH, 1)];
                linView.backgroundColor = CODColorBackground;
                [cell.contentView addSubview:linView];
            }
            UIImageView *iconImageView = (UIImageView *)[cell.contentView viewWithTag:1];
            UILabel *compNameLabel = (UILabel *)[cell.contentView viewWithTag:2];
            UILabel *subTitleLabel = (UILabel *)[cell.contentView viewWithTag:3];
            iconImageView.image = kGetImage(@"place_default_avatar");
            compNameLabel.text = @"牧野装饰";
            subTitleLabel.text = @"案例：452 好评度：99%";
            return cell;
        } else if (indexPath.row == 1) {// 路线
            static NSString * kAdressCellID = @"adressCellID";
            CODBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAdressCellID];
            if (!cell) {
                cell = [[CODBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAdressCellID];
                cell.backgroundColor = [UIColor whiteColor];
                
                UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 24, 10, 12)];
                iconImageView.image = kGetImage(@"amount_location");
                [cell.contentView addSubview:iconImageView];
                
                UILabel *addressLab = [[UILabel alloc] initWithFrame:CGRectMake(35, 20, SCREENWIDTH-105, 20)];
                addressLab.textColor = CODColor333333;
                addressLab.tag = 1;
                addressLab.font = kFont(14);
                [cell.contentView addSubview:addressLab];
                
                UIButton *adreBtn = [[UIButton alloc] init];
                [adreBtn SetBtnTitle:@"查看路线" andTitleColor:CODColor666666 andFont:kFont(12) andBgColor:nil andBgImg:nil andImg:kGetImage(@"decorate_positioning") andClickEvent:@selector(callAction) andAddVC:self];
                [adreBtn cod_alignImageUpAndTitleDown];
                adreBtn.frame = CGRectMake(CGRectGetMaxX(addressLab.frame)+10, 0, 50, 60);
                adreBtn.userInteractionEnabled = NO;
                [cell.contentView addSubview:adreBtn];
                
                UIView *linView = [[UIView alloc] initWithFrame:CGRectMake(0, 59, SCREENWIDTH, 1)];
                linView.backgroundColor = CODColorBackground;
                [cell.contentView addSubview:linView];
            }
            UILabel *addreLab = (UILabel *)[cell.contentView viewWithTag:1];
            addreLab.text = @"南昌市青云谱区新地路景泰华产业园1号...";
            
            return cell;
        } else {
            static NSString * kTeseCellID = @"teseCellID";
            CODBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTeseCellID];
            if (!cell) {
                cell = [[CODBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTeseCellID];
                cell.backgroundColor = [UIColor whiteColor];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font = kFont(12);
                cell.textLabel.textColor = CODColor333333;
            }
            
            NSString *title = @"特色服务";
            NSString *cntent = @"样板房征集·免费上门量房·免费报价·盛大开业";
            NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：%@",title,cntent]];
            [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:[[NSString stringWithFormat:@"%@：%@",title,cntent] rangeOfString:title]];
            cell.textLabel.attributedText = attribute;
            
            return cell;
        }
    }
    
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            static NSString * kExampleTitleCellID = @"exampleTitleCell";
            CODBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kExampleTitleCellID];
            if (!cell) {
                cell = [[CODBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kExampleTitleCellID];
                cell.backgroundColor = [UIColor whiteColor];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font = kFont(16);
                cell.detailTextLabel.font = kFont(12);
            }
            cell.textLabel.text = @"装修案例";
            cell.detailTextLabel.text = @"共2451个";
            return cell;
        } else {
            static NSString * kExampleCellID = @"exampleCell";
            CODBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kExampleCellID];
            if (!cell) {
                cell = [[CODBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kExampleCellID];
                [cell.contentView addSubview:self.examCollectionView];
                [self.examCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(cell.contentView);
                }];
            }
            return cell;
        }
        
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            static NSString * kCommentTitleCellID = @"commentTitleCell";
            CODBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentTitleCellID];
            if (!cell) {
                cell = [[CODBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCommentTitleCellID];
                cell.backgroundColor = [UIColor whiteColor];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font = kFont(16);
                cell.detailTextLabel.font = kFont(12);
            }
            cell.textLabel.text = @"评价(1000)";
            cell.detailTextLabel.text = @"好评度 ";
            return cell;
        } else {
            StoreGoodsCommentCell *comentCell = [StoreGoodsCommentCell cellWithTableView:tableView reuseIdentifier:nil];
            if ([[self.imfoDic allKeys] containsObject:@"mode"]) {
                comentCell.imfo_mode = self.imfoDic[@"mode"];
            }
            return comentCell;
        }
    }
    else {
        if (indexPath.row == 0) {
            static NSString * kExampleTitleCellID = @"exampleTitleCell";
            CODBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kExampleTitleCellID];
            if (!cell) {
                cell = [[CODBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kExampleTitleCellID];
                cell.backgroundColor = [UIColor whiteColor];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font = kFont(16);
                cell.detailTextLabel.font = kFont(12);
            }
            cell.textLabel.text = @"商家信息";
            cell.detailTextLabel.text = @"更多";
            return cell;
        } else {
            static NSString * kExampleCellID = @"exampleCell";
            CODBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kExampleCellID];
            if (!cell) {
                cell = [[CODBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kExampleCellID];
                
                
            }
            return cell;
        }
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    if (indexPath.section == 0) {
    //        if (indexPath.row == 0) {
    //            return 70;
    //        } else {
    //            return 140;
    //        }
    //    } else {
    //        if (indexPath.row == 0) {
    //            return 60;
    //        } else {
    //            return 140;
    //        }
    //    }
    //
    if (indexPath.section == 0) {
        return indexPath.row == 0 ? 70 : 60;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return 40;
        } else {
            
            if (self.exampleArray.count > 0) {
                if (self.exampleArray.count > 2) {
                    return 2*180;
                } else {
                    return 180;
                }
            } else {
                return 0;
            }
        }
    } else if (indexPath.section == 2) {
        return indexPath.row == 0 ? 40 : ((MyCommentImfoMode *)(self.imfoDic[@"mode"])).rowHeight;
        
    } else {
        return indexPath.row == 0 ? 40 : 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0.01 : 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == 2 ? CGRectGetHeight(self.comentFootVW.frame) : 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return section == 2 ? self.comentFootVW : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            CODBaseWebViewController *webView = [[CODBaseWebViewController alloc] initWithUrlString:CODDetaultWebUrl];
            webView.webTitleString = @"商家信息";
            [self.navigationController pushViewController:webView animated:YES];
        } else if (indexPath.row ==1) {
            [self.mapNavigationView showMapNavigationViewWithtargetLatitude:0 targetLongitute:0 toName:@"地址"];
        } else {
            CODSpecialPopView *popView = [[CODSpecialPopView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
            popView.dataArray = self.specialArray;
            [popView show];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            CODExampleListViewController *exampleListVV = [[CODExampleListViewController alloc] init];
            [self.navigationController pushViewController:exampleListVV animated:YES];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            CODCommentViewController *commentVC = [[CODCommentViewController alloc] init];
            [self.navigationController pushViewController:commentVC animated:YES];
        }
    } else {
        if (indexPath.row == 0) {
            CODBaseWebViewController *webView = [[CODBaseWebViewController alloc] initWithUrlString:CODDetaultWebUrl];
            webView.webTitleString = @"商家信息";
            [self.navigationController pushViewController:webView animated:YES];
        }
    }
}

#pragma mark - Action
- (void)collectViewItmeAction:(CODDectateExampleModel *)model {
    CODExamDetailViewController *detailVC = [[CODExamDetailViewController alloc] init];
    [self.navigationController pushViewController:detailVC animated:YES];
}
- (void)collectAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        [SVProgressHUD cod_showWithSuccessInfo:@"收藏成功"];
        [btn setImage:kGetImage(@"decorate_collection_fill") forState:UIControlStateNormal];
    } else {
        [SVProgressHUD cod_showWithSuccessInfo:@"已取消收藏"];
        [btn setImage:kGetImage(@"decorate_collection") forState:UIControlStateNormal];
    }
}

- (void)callAction {
    [self alertVcTitle:nil message:@"是否拨打10086" leftTitle:@"取消" leftTitleColor:CODColor666666 leftClick:^(id leftClick) {
    } rightTitle:@"拨打" righttextColor:CODColorTheme andRightClick:^(id rightClick) {
        dispatch_async(dispatch_get_main_queue(), ^{;
            NSMutableString * str = [[NSMutableString alloc] initWithFormat:@"tel://%@",@"10086"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        });
    }];
}

- (void)orderAction {
    CODOrderPopView *popView = [[CODOrderPopView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    popView.commitBlock = ^(NSString *city, NSString *name, NSString *phone) {
        NSLog(@"city=%@,name=%@,phone=%@",city,name,phone);
        
        [SVProgressHUD cod_showWithStatu:@"正在提交，请稍后"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD cod_dismis];
            
            [SVProgressHUD cod_showWithSuccessInfo:@"提交成功\n我们将尽快为您回电"];

        });
    };
    
    [popView show];

}

- (void)priceAction {
    CODCalcuQuoteViewController *VC = [[CODCalcuQuoteViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)allCommentAction {
    CODCommentViewController *commentVC = [[CODCommentViewController alloc] init];
    [self.navigationController pushViewController:commentVC animated:YES];
}

#pragma mark - 轮播图的代理实现
// 图片滚动回调实现
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index {
    //    [self.scrollImgNumLabel setText:kFORMAT(@"%ld/3",index+1)];
}
// 点击图片回调
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    
}
#pragma mark - 导航栏设置
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= kOffsety) {
        _alphaMemory = offsetY/kOffsety >= 1 ? 1 : offsetY/kOffsety;
        [self wr_setNavBarBackgroundAlpha:_alphaMemory];
        self.navTitleLabel.textColor = [UIColor colorWithWhite:0.0 alpha:_alphaMemory];
    }else if (offsetY>kOffsety){
        _alphaMemory = 1;
        [self wr_setNavBarBackgroundAlpha:_alphaMemory];
        self.navTitleLabel.textColor = [UIColor colorWithWhite:0.0 alpha:_alphaMemory];
    }
    if (_alphaMemory < .8) {
        [self.returnBtn setImage:kGetImage(@"decorate_incon_return") forState:0];
    } else {
        [self.returnBtn setImage:kGetImage(@"nav_app_return") forState:0];
    }
}

- (UILabel *)navTitleLabel {
    if (!_navTitleLabel) {
        _navTitleLabel = [[UILabel alloc] init];
        _navTitleLabel.backgroundColor = [UIColor clearColor];
        _navTitleLabel.font = [UIFont boldSystemFontOfSize:18];
        _navTitleLabel.textColor = [UIColor colorWithWhite:0.0 alpha:0];
        _navTitleLabel.textAlignment = NSTextAlignmentCenter;
        _navTitleLabel.text = @"牧野装饰";
    } return _navTitleLabel;
}

- (void)SetNav {
    // 一行代码搞定导航栏底部分割线是否隐藏
    [self wr_setNavBarShadowImageHidden:YES];
    [self wr_setNavBarBackgroundAlpha:0.0];
    
    self.navigationItem.titleView = self.navTitleLabel;
    
    self.returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.returnBtn setImage:kGetImage(@"decorate_incon_return") forState:0];
    self.returnBtn.size = self.returnBtn.currentImage.size;
    [self.returnBtn addTarget:self action:@selector(cod_returnAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *faqBtnItem =  [[UIBarButtonItem alloc]initWithCustomView:self.returnBtn];
    self.navigationItem.leftBarButtonItems = @[faqBtnItem];
}
@end