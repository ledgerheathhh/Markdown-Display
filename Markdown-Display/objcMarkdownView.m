//
//  objcobjcMarkdownView.m
//  Markdown-Display
//
//  Created by Ledger Heath on 2025/3/18.
//

// objcMarkdownView.m
#import "objcMarkdownView.h"

@interface UpdateHeightHandler : NSObject <WKScriptMessageHandler>
@property (nonatomic, copy) UpdateHeightHandlerBlock updateBlock;
@end

@implementation UpdateHeightHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.body isKindOfClass:[NSNumber class]]) {
        CGFloat height = [message.body floatValue];
        if (self.updateBlock) {
            self.updateBlock(height);
        }
    }
}
@end

@interface objcMarkdownView () <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UpdateHeightHandler *heightHandler;
@property (nonatomic, nullable) NSNumber *intrinsicContentHeight;
@end

@implementation objcMarkdownView

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _heightHandler = [UpdateHeightHandler new];
    __weak typeof(self) weakSelf = self;
    _heightHandler.updateBlock = ^(CGFloat height) {
        CGFloat currentHeight = weakSelf.intrinsicContentHeight ? [weakSelf.intrinsicContentHeight doubleValue] : 0.0;
        if (height > currentHeight) {
            if (weakSelf.onRendered) {
                weakSelf.onRendered(height);
            }
            weakSelf.intrinsicContentHeight = @(height);
            [weakSelf invalidateIntrinsicContentSize];
        }
    };
}

#pragma mark - 自定义初始化方法
- (instancetype)initWithCSS:(nullable NSString *)css
                   plugins:(nullable NSArray<NSString *> *)plugins
               stylesheets:(nullable NSArray<NSURL *> *)stylesheets
                   styled:(BOOL)styled {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setupWebViewWithCSS:css plugins:plugins stylesheets:stylesheets markdown:nil enableImage:nil styled:styled];
    }
    return self;
}

#pragma mark - 核心方法
- (void)loadMarkdown:(nullable NSString *)markdown
          enableImage:(BOOL)enableImage
                 css:(nullable NSString *)css
             plugins:(nullable NSArray<NSString *> *)plugins
         stylesheets:(nullable NSArray<NSURL *> *)stylesheets
              styled:(BOOL)styled {
    if (!markdown) return;
    
    [self.webView removeFromSuperview];
    [self setupWebViewWithCSS:css
                     plugins:plugins
                 stylesheets:stylesheets
                   markdown:markdown
                 enableImage:@(enableImage)
                      styled:styled];
}

- (void)showMarkdown:(NSString *)markdown {
    NSString *escapedMarkdown = [self escapeMarkdown:markdown];
    NSString *script = [NSString stringWithFormat:@"window.showMarkdown('%@', true);", escapedMarkdown];
    [self.webView evaluateJavaScript:script completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"[objcMarkdownView][Error] %@", error);
        }
    }];
}

#pragma mark - 布局相关
- (CGSize)intrinsicContentSize {
    return self.intrinsicContentHeight ? CGSizeMake(UIViewNoIntrinsicMetric, self.intrinsicContentHeight.floatValue) : CGSizeZero;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        if (self.onTouchLink) {
            decisionHandler(self.onTouchLink(navigationAction.request) ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
        } else {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

#pragma mark - 私有方法
- (void)setupWebViewWithCSS:(nullable NSString *)css
                   plugins:(nullable NSArray<NSString *> *)plugins
               stylesheets:(nullable NSArray<NSURL *> *)stylesheets
                 markdown:(nullable NSString *)markdown
               enableImage:(nullable NSNumber *)enableImage
                    styled:(BOOL)styled {
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.userContentController = [self createContentControllerWithCSS:css
                                                               plugins:plugins
                                                           stylesheets:stylesheets
                                                             markdown:markdown
                                                           enableImage:enableImage];
    [config.userContentController addScriptMessageHandler:self.heightHandler name:@"updateHeight"];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.scrollView.scrollEnabled = self.isScrollEnabled;
    [self addWebViewConstraints];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[self htmlURLForStyled:styled]]];
}

- (WKUserContentController *)createContentControllerWithCSS:(nullable NSString *)css
                                                   plugins:(nullable NSArray<NSString *> *)plugins
                                               stylesheets:(nullable NSArray<NSURL *> *)stylesheets
                                                 markdown:(nullable NSString *)markdown
                                               enableImage:(nullable NSNumber *)enableImage {
    WKUserContentController *controller = [WKUserContentController new];
    
    // CSS 注入
    if (css) {
        NSString *styleScript = [NSString stringWithFormat:
            @"var s = document.createElement('style');"
             "s.innerHTML = `%@`;"
             "document.head.appendChild(s);", css];
        [controller addUserScript:[[WKUserScript alloc] initWithSource:styleScript
                                                         injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                      forMainFrameOnly:YES]];
    }
    
    // 插件注入
    for (NSString *plugin in plugins) {
        NSString *pluginScript = [NSString stringWithFormat:
            @"var _module = {}; var _exports = {};"
             "(function(module, exports) { %@ })(_module, _exports);"
             "window.usePlugin(_module.exports || _exports);", plugin];
        [controller addUserScript:[[WKUserScript alloc] initWithSource:pluginScript
                                                         injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                      forMainFrameOnly:YES]];
    }
    
    // 样式表注入
    for (NSURL *url in stylesheets) {
        NSString *linkScript = [NSString stringWithFormat:
            @"var link = document.createElement('link');"
             "link.href = '%@';"
             "link.rel = 'stylesheet';"
             "document.head.appendChild(link);", url.absoluteString];
        [controller addUserScript:[[WKUserScript alloc] initWithSource:linkScript
                                                         injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                      forMainFrameOnly:YES]];
    }
    
    // Markdown 注入
    if (markdown) {
        NSString *escapedMarkdown = [self escapeMarkdown:markdown];
        BOOL enableImg = enableImage ? enableImage.boolValue : YES;
        NSString *script = [NSString stringWithFormat:
            @"window.showMarkdown('%@', %@);", escapedMarkdown, enableImg ? @"true" : @"false"];
        [controller addUserScript:[[WKUserScript alloc] initWithSource:script
                                                         injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                      forMainFrameOnly:YES]];
    }
    
    return controller;
}

#pragma mark - 工具方法
- (NSURL *)htmlURLForStyled:(BOOL)styled {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *fileName = styled ? @"styled" : @"non_styled";
    return [bundle URLForResource:fileName withExtension:@"html"];
}

- (NSString *)escapeMarkdown:(NSString *)markdown {
    return [markdown stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
}

- (void)addWebViewConstraints {
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.webView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.webView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.webView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.webView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
    ]];
    self.webView.opaque = NO;
    self.webView.backgroundColor = UIColor.clearColor;
    self.webView.scrollView.backgroundColor = UIColor.clearColor;
}

@end
