//
//  ZCUIBaseController.m
//  SobotKit
//
//  Created by zhangxy on 15/11/12.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUIBaseController.h"
#import "ZCLibGlobalDefine.h"
#import "ZCActionSheet.h"
#import "ZCUICore.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIImageTools.h"
#import "ZCToolsCore.h"

@interface ZCUIBaseController ()<ZCActionSheetDelegate>{
    CGFloat viewWidth;
    CGFloat viewHeight;
}

@end

@implementation ZCUIBaseController

#pragma mark - 横竖屏
//是否允许切换
-(BOOL)shouldAutorotate{
    return YES;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([ZCUICore getUICore].kitInfo.isShowPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        // 如果topViewController是自己，
//        if(self.navigationController && self.navigationController.topViewController && [self.navigationController.topViewController respondsToSelector:@selector(supportedInterfaceOrientations)]){
//            return [self.navigationController.topViewController supportedInterfaceOrientations];
//        }
        return UIInterfaceOrientationMaskAll;
    }
}

// 斑马必须使用以下方法
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if ([ZCUICore getUICore].kitInfo.isShowPortrait) {
        return UIInterfaceOrientationPortrait;
    }else{
        if(self.navigationController && self.navigationController.topViewController && [self.navigationController.topViewController respondsToSelector:@selector(preferredInterfaceOrientationForPresentation)]){
            return [self.navigationController.topViewController preferredInterfaceOrientationForPresentation];
        }
        return UIInterfaceOrientationPortrait|UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

// 横竖屏切换
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self orientationChanged];
       
    // 切换的方法必须调用
    [self viewDidLayoutSubviews];
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[ZCUITools zcgetBackgroundColor]];
    
    if(zcGetSystemDoubleVersion() >= 9.0){
        if(isRTLLayout()){
            [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
            [UISearchBar appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
            [self.navigationController.navigationBar setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
        }else{
            [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
            [UISearchBar appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
            [self.navigationController.navigationBar setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
        }
    }
    viewWidth = self.view.frame.size.width;
    
    viewHeight = self.view.frame.size.height;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        if(self.navigationController!=nil){
            self.navigationController.navigationBarHidden = YES;
        }
    }
//    viewWidth = self.view.frame.size.width;
//    viewHeight = self.view.frame.size.height;
    
    // 从其他页面返回时，重新布局
    [self orientationChanged];
}

-(BOOL)orientationChanged{
    BOOL isChange = NO;
    if ([ZCToolsCore getToolsCore].getCurScreenDirection == 0) {
        
        CGFloat c = viewWidth;
        if(viewWidth > viewHeight){
            viewWidth = viewHeight;
            viewHeight = c;
            isChange = YES;
        }
    }else{
        CGFloat c = viewHeight;
        if(viewWidth < viewHeight){
            viewHeight = viewWidth;
            viewWidth = c;
            
            isChange = YES;
        }
    }
    return isChange;
}



-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutTopView];
}

-(CGFloat)getCurViewWidth{
    return viewWidth;
}

-(CGFloat)getCurViewHeight{
    return viewHeight;
}


// 监听暗黑模式变化
-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [super traitCollectionDidChange:previousTraitCollection];
    if(zcGetSystemDoubleVersion()>=13){
        // trait发生了改变
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            
            if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
                if(self.backButton){
                    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateNormal];
                    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateHighlighted];

                    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore"] forState:UIControlStateNormal];
                    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore_press"] forState:UIControlStateHighlighted];
                    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg).length >0) {
                        [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg)]  forState:UIControlStateNormal];
                    }
                    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg).length >0) {
                        [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg)]  forState:UIControlStateHighlighted];
                    }
                }
            }else{
                [self setNavigationBarStyle];
            }
            
        }
    }
}


#pragma mark - topView

-(void)createTitleView{
    [self createTitleViewWith:0];
}

-(void)createTitleViewWith:(int)type{
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, NavBarHeight)];
    
    [self.topView setBackgroundColor:[ZCUITools zcgetBgBannerColor]];
    [_topView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [_topView setAutoresizesSubviews:YES];
    [self.view addSubview:self.topView];
    

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, NavBarHeight-44, self.view.frame.size.width- 80*2, 44)];
    [self.titleLabel setFont:[ZCUITools zcgetTitleFont]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setTextColor:[ZCUITools zcgetTopViewTextColor]];
   
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
    [self.titleLabel setAutoresizesSubviews:YES];
    
    [self.topView addSubview:self.titleLabel];
    
    self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:CGRectMake(0, NavBarHeight-44, 64, 44)];
    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateNormal];
    [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateHighlighted];
    
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg).length >0) {
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg)] forState:UIControlStateNormal];
    }
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg).length >0) {
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg)] forState:UIControlStateHighlighted];
    }
    [self.backButton setBackgroundColor:[UIColor clearColor]];
    if ([ZCUICore getUICore].kitInfo.topBackNolColor != nil ) {
        [self.backButton setBackgroundImage:[ZCUIImageTools zcimageWithColor: [ZCUICore getUICore].kitInfo.topBackNolColor]  forState:UIControlStateNormal];
    }
    if ([ZCUICore getUICore].kitInfo.topBackSelColor != nil) {
        [self.backButton setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackSelColor] forState:UIControlStateHighlighted];
    }
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self.backButton setContentEdgeInsets:UIEdgeInsetsZero];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.backButton setAutoresizesSubviews:YES];
    [self.backButton setTitle:ZCSTLocalString(@"") forState:UIControlStateNormal];
    [self.backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [self.backButton.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
    [self.backButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [self.topView addSubview:self.backButton];
    self.backButton.tag = BUTTON_BACK;
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreButton setFrame:CGRectMake(self.view.frame.size.width-74, NavBarHeight-44, 74, 44)];
    [self.moreButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.moreButton setContentEdgeInsets:UIEdgeInsetsZero];
    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
    [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.moreButton setAutoresizesSubviews:YES];
    [self.moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.moreButton setTitle:@"" forState:UIControlStateNormal];
    [self.moreButton.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
    [self.moreButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore"] forState:UIControlStateNormal];
    [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore_press"] forState:UIControlStateHighlighted];
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg).length >0) {
        [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg)]  forState:UIControlStateNormal];
    }
    if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg).length >0) {
        [self.moreButton setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg)]  forState:UIControlStateHighlighted];
    }
    [self.topView addSubview:self.moreButton];
    self.moreButton.tag = BUTTON_MORE;
    [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (type == 1) {
        
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateNormal];
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateHighlighted];
        
        [self.topView setBackgroundColor:[ZCUITools zcgetscTopBgColor]];
        
        [self.titleLabel setFont:[ZCUITools zcgetscTopTextFont]];
        [self.titleLabel setTextColor:[ZCUITools zcgetscTopTextColor]];
        
        [self.backButton setTitleColor:[ZCUITools zcgetscTopBackTextColor] forState:UIControlStateNormal];
        [self.backButton.titleLabel setFont:[ZCUITools zcgetscTopBackTextFont]];
        
        self.bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, NavBarHeight -0.5, ScreenWidth, 0.5)];
        self.bottomLine.backgroundColor = UIColorFromThemeColor(ZCBgLineColor);
        [self.bottomLine setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
        
        [self.topView addSubview:self.bottomLine];
        
    }
    
    if(isRTLLayout()){
        [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [[ZCToolsCore getToolsCore] setRTLFrame:self.backButton];
        [[ZCToolsCore getToolsCore] setRTLFrame:self.moreButton];
    }
    
}

- (void)layoutTopView{
    if([[ZCToolsCore getToolsCore] getCurScreenDirection] > 0){
        if(self.topView!=nil){
            if(self.topView.frame.size.height != NavLandspaceBarHeight){
                self.topView.frame = CGRectMake(0, 0, self.view.frame.size.width, NavLandspaceBarHeight);
                if(!self.backButton.hidden){
                    CGRect bf = self.backButton.frame;
                    bf.origin.x = 10;
                    self.backButton.frame = bf;
                }
                
                if(!self.moreButton){
                    [self.moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 25)];
                    [self.moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 25)];
                }
                    
            }
        }
    }else{
        if(self.topView!=nil){
            if(self.topView.frame.size.height != NavBarHeight){
                self.topView.frame = CGRectMake(0, 0, self.view.frame.size.width, NavBarHeight);
            }
            if(!self.backButton.hidden){
                CGRect bf = self.backButton.frame;
                bf.origin.x = 0;
                self.backButton.frame = bf;
            }
            
            if(!self.moreButton){
                [self.moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
                [self.moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
            }
        }
    }
    
    if(isRTLLayout()){
        if(self.backButton != nil){
            [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
            [[ZCToolsCore getToolsCore] setRTLFrame:self.backButton];
            [[ZCToolsCore getToolsCore] setRTLFrame:self.moreButton];
        }
    }
}


-(BOOL)prefersStatusBarHidden{
    if(isLandspace){
        return YES;
    }
    return NO;
}

#pragma mark -
//**************************项目中的导航栏一部分是自定义的View,一部分是系统自带的NavigationBar*********************************
- (void)setNavigationBarStyle{
    [self setNavigationBarLeft:@[@(BUTTON_BACK)] right:nil];
}

-(void)setNavigationBarLeft:(NSArray *)leftTags right:(NSArray *)rightTags{
    //    self.navigationItem.leftBarButtonItem = item;
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace   target:nil action:nil];
    /**
     width为负数时，相当于btn向右移动width数值个像素，由于按钮本身和  边界间距为5pix，所以width设为-5时，间距正好调整为0；width为正数 时，正好相反，相当于往左移动width数值个像素
     */
    negativeSpacer.width = -5;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:ZCUIFont16,NSForegroundColorAttributeName:[ZCUITools zcgetTopViewTextColor]}];
    
    [self.navigationController.navigationBar setBarTintColor:[ZCUITools zcgetBgBannerColor]];
    if ([ZCUICore getUICore].kitInfo.topViewBgColor != nil) {
        [self.navigationController.navigationBar setBarTintColor:[ZCUICore getUICore].kitInfo.topViewBgColor];
    }
    
    NSMutableArray *leftItems = [[NSMutableArray alloc] init];
    if(leftTags!=nil && leftTags.count > 0){
        [leftItems addObject:negativeSpacer];
        for(NSNumber *tag in leftTags){
            UIBarButtonItem *item = [self createItemButtonWith:[tag integerValue]];
            [leftItems addObject:item];
        }
    }

    NSMutableArray *rightItems = [[NSMutableArray alloc] init];
    if(rightTags!=nil && rightTags.count > 0){
        for(NSNumber *tag in rightTags){
            UIBarButtonItem *item = [self createItemButtonWith:[tag integerValue]];
            [rightItems addObject:item];
        }
    }
    
    if(rightItems!=nil && rightItems.count>0){
        self.navigationItem.rightBarButtonItems = rightItems;

        self.navigationItem.leftBarButtonItems = leftItems;
    }else{
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItems = leftItems;
    }
    
    [self.navigationController.navigationBar setBarTintColor:[ZCUITools zcgetBgBannerColor]];
    if ([ZCUICore getUICore].kitInfo.topViewBgColor != nil) {
//        [self.navigationController.navigationBar setBarTintColor:[ZCUICore getUICore].kitInfo.topViewBgColor];
//        UINavigationBar *navigationBar = self.navigationController.navigationBar;
//        [navigationBar setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault]; //此处使底部线条颜色为红色
//        [navigationBar setShadowImage:[ZCUIImageTools zcimageWithColor:[UIColor redColor]]];
        
    }else{
//            2.8.0  消除阴影
            [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        
            self.navigationController.navigationBar.shadowImage = [UIImage new];
    }
}


-(UIBarButtonItem *) createItemButtonWith:(ZCButtonClickTag) tag{
    //12 * 19
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn.titleLabel setFont:[ZCUITools zcgetTitleFont]];
    btn.frame = CGRectMake(0, 0, 44,44) ;
    btn.tag = tag;
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateHighlighted];
    [btn setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateDisabled];
    
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    
    if(isRTLLayout()){
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    }

    if(tag == BUTTON_BACK){
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        if(isRTLLayout()){
            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        }
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_titlebar_back_normal"] forState:UIControlStateNormal];
        if (zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg).length >0) {
            [btn setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg)] forState:UIControlStateNormal];
        }
        if (zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg).length >0) {
            [btn setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg)] forState:UIControlStateHighlighted];
        }
        [btn setTitle:ZCSTLocalString(@"") forState:UIControlStateNormal];
        if ([ZCUICore getUICore].kitInfo.topBackTitle != nil) {
           [btn setTitle:[ZCUICore getUICore].kitInfo.topBackTitle forState:UIControlStateNormal];
        }
        if (![@"" isEqual:[ZCUICore getUICore].kitInfo.topBackNolColor] && [ZCUICore getUICore].kitInfo.topBackNolColor != nil) {
            [btn setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUICore getUICore].kitInfo.topBackNolColor] forState:UIControlStateNormal];
        }
        if(zcLibConvertToString(btn.titleLabel.text).length > 0){
            CGRect lf = btn.frame;
            lf.size.width=60;
            [btn setFrame:lf];
        }
    }
    if(tag == BUTTON_MORE){
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore"] forState:UIControlStateNormal];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_btnmore_press"] forState:UIControlStateHighlighted];
        if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg).length >0) {
            [btn setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnNolImg)]  forState:UIControlStateNormal];
        }
        if (zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg).length >0) {
            [btn setImage:[ZCUITools zcuiGetBundleImage:zcLibConvertToString([ZCUICore getUICore].kitInfo.moreBtnSelImg)]  forState:UIControlStateHighlighted];
        }
    }
    if (tag == BUTTON_EVALUATION) {
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_evaluate"] forState:UIControlStateNormal];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_evaluate"] forState:UIControlStateHighlighted];
    }
    if(tag == BUTTON_TEL){
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zccion_call_icon"] forState:UIControlStateNormal];
        [btn setImage:[ZCUITools zcuiGetBundleImage:@"zccion_call_icon"] forState:UIControlStateHighlighted];
    }
    if(tag == BUTTON_CLOSE){
        [btn setTitle:ZCSTLocalString(@"关闭") forState:UIControlStateNormal];
    }
    if(tag == BUTTON_SEND){
        CGRect lf = btn.frame;
        lf.size.width=60;
        [btn setFrame:lf];
        [btn setTitle:ZCSTLocalString(@"发送") forState:UIControlStateNormal];
    }
        
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    return item;
}

#pragma mark 石墨文档需求，改版状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Dark){
        if(zcGetSystemDoubleVersion()>=13){
            return UIStatusBarStyleDarkContent;
        }
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}


// 基于NavigationController才能正常使用，否则uni-app项目无法启动
//-(UIViewController *)childViewControllerForStatusBarStyle {
//    return self;
//}




#pragma mark - click
// button点击事件
-(IBAction)buttonClick:(UIButton *) sender{

    if(sender.tag == BUTTON_MORE){
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:UIColorFromRGB(TextCleanMessageColor) CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"清空聊天记录"), nil];
        mysheet.selectIndex = 1;
        [mysheet show];
        
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end