//
//  ViewController.m
//  ImgAdaptationDemo
//
//  Created by zry on 2018/4/18.
//  Copyright © 2018年 zry. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configureWeb];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadImgs];
    
}

-(void)configureWeb
{
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:wkWebConfig];
    webView.backgroundColor = [UIColor clearColor];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
}


-(void)loadImgs
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"item_detail.html" ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    [self.webView loadRequest:request];
}

#pragma mark - WKNavigationDelegate
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    //图片宽度适配
        NSString *js = @"function imgAutoFit() { \
            var maxwidth = %f;\
            var imgs = document.getElementsByTagName('img'); \
            for (var i = 0; i < imgs.length; ++i) {\
                var img = imgs[i];   \
                if(img.width > maxwidth){ \
                    img.width = maxwidth;   \
                }\
            } \
        }";
    
        js = [NSString stringWithFormat:js, webView.frame.size.width];
        [webView evaluateJavaScript:js completionHandler:nil];
        [webView evaluateJavaScript:@"imgAutoFit();"completionHandler:nil];
        [webView evaluateJavaScript:@"document.body.offsetHeight;" completionHandler:^(id _Nullable any, NSError * _Nullable error) {

        }];
    
    webView.scrollView.contentOffset = CGPointZero;
}

// 页面加载失败时调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"加载失败");
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSMutableURLRequest *request = [navigationAction.request mutableCopy];
    NSLog(@"request————————>%@",request.URL.absoluteString);
    
    if ([request.URL.absoluteString containsString:@"blank"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)dealloc
{
    self.webView.UIDelegate = nil;
    self.webView.navigationDelegate = nil;
    [self.webView stopLoading];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
