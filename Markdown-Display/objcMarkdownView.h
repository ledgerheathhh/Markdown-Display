//
//  objcobjcMarkdownView.h
//  Markdown-Display
//
//  Created by Ledger Heath on 2025/3/18.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^UpdateHeightHandlerBlock)(CGFloat height);
typedef BOOL (^OnTouchLinkHandler)(NSURLRequest *request);

@interface objcMarkdownView : UIView

@property (nonatomic, assign) BOOL isScrollEnabled;
@property (nonatomic, copy, nullable) OnTouchLinkHandler onTouchLink;
@property (nonatomic, copy, nullable) void (^onRendered)(CGFloat height);

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

// 初始化方法（对应 Swift 的 convenience init）
- (instancetype)initWithCSS:(nullable NSString *)css
                   plugins:(nullable NSArray<NSString *> *)plugins
               stylesheets:(nullable NSArray<NSURL *> *)stylesheets
                   styled:(BOOL)styled;

// 加载方法（对应 Swift 的 load 方法）
- (void)loadMarkdown:(nullable NSString *)markdown
          enableImage:(BOOL)enableImage
                 css:(nullable NSString *)css
             plugins:(nullable NSArray<NSString *> *)plugins
         stylesheets:(nullable NSArray<NSURL *> *)stylesheets
              styled:(BOOL)styled;

// 显示方法（对应 Swift 的 show 方法）
- (void)showMarkdown:(NSString *)markdown;

@end

NS_ASSUME_NONNULL_END
