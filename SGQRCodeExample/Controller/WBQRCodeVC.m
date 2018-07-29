//
//  WBQRCodeVC.m
//  SGQRCodeExample
//
//  Created by kingsic on 2018/2/8.
//  Copyright © 2018年 kingsic. All rights reserved.
//

#import "WBQRCodeVC.h"
#import "SGQRCode.h"
#import "ScanSuccessJumpVC.h"
#import "SGQRCodeScanView.h"

@interface WBQRCodeVC () {
    SGQRCodeObtain *obtain;
}
@property (nonatomic, strong) SGQRCodeScanView *scanView;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, assign) BOOL stop;
@end

@implementation WBQRCodeVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_stop) {
        [obtain startRunning];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanView addTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanView removeTimer];
}

- (void)dealloc {
    NSLog(@"WBQRCodeVC - dealloc");
    [self removeScanningView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    obtain = [SGQRCodeObtain QRCodeObtain];
    
    [self setupQRCodeScan];
    [self setupNavigationBar];
    [self.view addSubview:self.scanView];
    [self.view addSubview:self.promptLabel];
}

- (void)setupQRCodeScan {
    __weak typeof(self) weakSelf = self;

    SGQRCodeObtainConfigure *configure = [SGQRCodeObtainConfigure QRCodeObtainConfigure];
    configure.openLog = YES;
    [obtain establishQRCodeObtainScanWithController:self configure:configure];
    [obtain setBlockWithQRCodeObtainScanResult:^(SGQRCodeObtain *obtain, NSString *result) {
        if (result) {
            [obtain stopRunning];
            weakSelf.stop = YES;
            [obtain playSoundName:@"SGQRCode.bundle/sound.caf"];

            ScanSuccessJumpVC *jumpVC = [[ScanSuccessJumpVC alloc] init];
            jumpVC.comeFromVC = ScanSuccessJumpComeFromWB;
            jumpVC.jump_URL = result;
            [weakSelf.navigationController pushViewController:jumpVC animated:YES];
        }
    }];
}

- (void)setupNavigationBar {
    self.navigationItem.title = @"扫一扫";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItenAction)];
}

- (void)rightBarButtonItenAction {
    __weak typeof(self) weakSelf = self;

    [obtain establishAuthorizationQRCodeObtainAlbumWithController:nil];
    if (obtain.isPHAuthorization == YES) {
        [self.scanView removeTimer];
    }
    [obtain setBlockWithQRCodeObtainAlbumDidCancelImagePickerController:^(SGQRCodeObtain *obtain) {
        [weakSelf.view addSubview:weakSelf.scanView];
    }];
    [obtain setBlockWithQRCodeObtainAlbumResult:^(SGQRCodeObtain *obtain, NSString *result) {
        if (result == nil) {
            NSLog(@"暂未识别出二维码");
        } else {
            if ([result hasPrefix:@"http"]) {
                ScanSuccessJumpVC *jumpVC = [[ScanSuccessJumpVC alloc] init];
                jumpVC.comeFromVC = ScanSuccessJumpComeFromWB;
                jumpVC.jump_URL = result;
                [weakSelf.navigationController pushViewController:jumpVC animated:YES];
                
            } else {
                ScanSuccessJumpVC *jumpVC = [[ScanSuccessJumpVC alloc] init];
                jumpVC.comeFromVC = ScanSuccessJumpComeFromWB;
                jumpVC.jump_bar_code = result;
                [weakSelf.navigationController pushViewController:jumpVC animated:YES];
            }
        }
    }];
}

- (SGQRCodeScanView *)scanView {
    if (!_scanView) {
        _scanView = [[SGQRCodeScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _scanView.scanImageName = @"SGQRCode.bundle/QRCodeScanLineGrid";
        _scanView.scanAnimationStyle = ScanAnimationStyleGrid;
        _scanView.cornerColor = [UIColor orangeColor];
    }
    return _scanView;
}
- (void)removeScanningView {
    [self.scanView removeTimer];
    [self.scanView removeFromSuperview];
    self.scanView = nil;
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.backgroundColor = [UIColor clearColor];
        CGFloat promptLabelX = 0;
        CGFloat promptLabelY = 0.73 * self.view.frame.size.height;
        CGFloat promptLabelW = self.view.frame.size.width;
        CGFloat promptLabelH = 25;
        _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _promptLabel.text = @"将二维码/条码放入框内, 即可自动扫描";
    }
    return _promptLabel;
}


@end
