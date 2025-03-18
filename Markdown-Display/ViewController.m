//
//  ViewController.m
//  Markdown-Display
//
//  Created by Ledger Heath on 2025/2/17.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <MMMarkdown/MMMarkdown.h>
#import <DTCoreText/DTCoreText.h>
#import "NSAttributedStringMarkdownParser.h"
#import "Markdown_Display-Swift.h"
#import "TSMarkdownParser.h"
#import "objcMarkdownView.h"

@interface ViewController ()

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SwiftLibrary *library = [[SwiftLibrary alloc] init];
    NSString *result = [library method];
    NSLog(@"Swift: %@", result);
    
    // 读取文件并将其内容转换为字符串
    NSString *filePath = @"./file.md";  // 文件的路径
    NSError *error = nil;
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"读取文件失败: %@", error.localizedDescription);
        NSString *text = @"然后在markdown里，也有11类样式呀，是都要支持吗？\nDeepSeek 支持以下 Markdown 格式，这些格式可以帮助你更好地组织和呈现内容：\n\n\n### 1. **文本样式**\n\n\n- **粗体**：使用 `**` 或 `__` 包裹文本，例如 **粗体文本**。\n- **斜体**：使用 `*` 或 `_` 包裹文本，例如 *斜体文本*。\n- **加粗斜体**：结合 `**` 和 `*`，例如 ***加粗斜体文本***。\n- **删除线**：使用 `~~` 包裹文本，例如 ~~删除线文本~~。\n\n\n### 2. **列表**\n\n\n- **无序列表**：使用 `-`、`*` 或 `+`，例如：\n\n\n  - 项目1\n  - 项目2\n- **有序列表**：使用数字加点，例如：\n\n\n  1. 项目1\n  2. 项目2\n- **嵌套列表**：缩进添加子项目，例如：\n\n\n  1. 项目1\n     - 子项目1\n     - 子项目2\n\n\n### 3. **链接**\n\n\n- **普通链接**：使用 [链接文本](URL)，例如 [DeepSeek](https://www.deepseek.com)。\n- **带标题的链接**：[链接文本](URL \"标题\")，例如 [DeepSeek](https://www.deepseek.com \"DeepSeek官网\")。\n\n\n### 4. **图片**\n\n\n- 使用 ![替代文本](http://localhost:9529/palogo.png)，例如 ![DeepSeek](http://localhost:9529/palogo.png)。\n\n\n### 5. **代码块**\n\n\n- **行内代码**：使用反引号 `包裹，例如 `print(\"Hello, World!\")`。\n- **代码块**：使用三个反引号 ``` 或 ``````，例如：\n  ```python\n  print(\"Hello, World!\")\n  ```\n- **高亮代码**：指定语言，例如 ```python，支持多种语言高亮。\n\n\n### 6. **表格**\n\n\n- 使用 `|` 和 `-` 创建表格，例如：\n  | 姓名  | 年龄 |\n  | ----- | ---- |\n  | Alice | 30   |\n  | Bob   | 25   |\n- 支持对齐方式：`| 左对齐 | 右对齐 | 居中 |`，使用 `:` 和 `-` 设置。\n\n\n### 7. **块引用**\n\n\n- 使用 `>` 引用文本，例如：\n\n\n  > 这是一个块引用。\n  >\n\n\n### 8. **分割线**\n\n\n- 使用 `---` 创建水平分割线，例如：\n  ---\n\n\n### 9. **任务列表**\n\n\n- 使用 `- [ ]` 创建未完成任务，`- [x]` 创建已完成任务，例如：\n\n\n  - [X] 完成作业\n  - [ ] 开会\n\n\n### 10. **数学公式**\n\n\n- 使用 `$$` 包裹行内公式，例如 $$E=mc^2$$。\n- 使用 `$$` 包裹块级公式，例如：\n  $$\n  \\int_{0}^{1} x^2 dx\n  $$\n\n\n### 11. **LaTeX**\n\n\n- 支持 LaTeX 语法，用于复杂公式，例如：\n  $$\n  \\frac{d}{dx} e^{x} = e^{x}\n  $$\n\n";
        
        //        text = @"| 1111111 | 22222222 | 33333333 | 4444444444 | 5555555555555555555555555 | 66666666666666666 |\n| - | - | - | - | - | - |\n| a | b | c | d | e | f |\n";
        
        //        text = @"| 姓名  | 年龄 |\n  | ----- | ---- |\n  | Alice | 30   |\n  | Bob   | 25   |\n";
        //        [self AttributedString:text];
        //        [self renderMarkdown_UITextView:text];
        //        [self renderMarkdown_webview:text];
        //        [self testWeb];
        [self renderMarkdown_swiftView:text];
//        [self renderMarkdown_objcMarkdownView:text];
        //        [self renderMarkdown_CustomView:text];
    } else {
        NSLog(@"文件内容: %@", fileContent);
        [self renderMarkdown_UITextView:fileContent];
    }
}

- (void)renderMarkdown_objcMarkdownView:(NSString *)markdown {
    // 使用视图的宽度，但高度设为0，让它根据内容自动调整
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 0);
    objcMarkdownView *mdView = [[objcMarkdownView alloc] initWithFrame:frame];
    
    [mdView loadMarkdown:markdown enableImage:YES css:nil plugins:nil stylesheets:nil styled:YES];
}

- (void)renderMarkdown_swiftView:(NSString *)markdown {
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scrollView.backgroundColor = UIColor.grayColor;
    [self.view addSubview:scrollView];
    
    // 创建 MarkdownView 包装器
    NSLog(@"开始创建MDViewWrapper");
    
    // 使用视图的宽度，但高度设为0，让它根据内容自动调整
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 0);
    MDViewWrapper *mdWrapper = [[MDViewWrapper alloc] initWithFrame:frame];
    
    // 设置高度回调
    NSLog(@"设置高度回调");
//    __weak typeof(self) weakSelf = self;
    [mdWrapper setOnHeightReceived:^(CGFloat height) {
        // 更新MarkdownView的高度
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"MarkdownView 渲染完成，高度为: %f", height);
//            CGRect newFrame = mdWrapper.view.frame;
//            newFrame.size.height = height;
//            mdWrapper.view.frame = newFrame;
//            
//            // 如果需要，可以在这里更新其他UI元素
//            [weakSelf.view setNeedsLayout];
        });
    }];
    
    // 将 MarkdownView 添加到视图层次结构中
    NSLog(@"添加到视图层次结构");
    [scrollView addSubview:[mdWrapper view]];
    
    // 确保所有设置完成后再加载 Markdown 内容
    NSLog(@"准备加载Markdown内容: %@", markdown);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"开始加载Markdown内容");
        [mdWrapper loadWithMarkdown:markdown];
        NSLog(@"Markdown内容加载完成");
    });

}

- (void)renderMarkdown_CustomView:(NSString *)markdownText {
    
    NSAttributedString* attributedText = [self createTableAttributedString: markdownText];
    
    // 显示内容
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 600)];
    textView.center = self.view.center;
    textView.backgroundColor = UIColor.grayColor;
    textView.attributedText = attributedText;
    textView.editable = false;
    [self.view addSubview:textView];
}

- (void)renderMarkdown_webview:(NSString *)markdown {
    NSError *error = nil;
    
    // 使用MMMarkdown转换Markdown为HTML
    //    NSString *htmlString = [MMMarkdown HTMLStringWithMarkdown:markdown error:&error];
    NSString *htmlString = [MMMarkdown HTMLStringWithMarkdown:markdown extensions:MMMarkdownExtensionsGitHubFlavored error:&error];
    
    if (error) {
        NSLog(@"Markdown Error: %@", error);
        return;
    }
    
    // 基础CSS样式
    NSString *css = @"<style>"
    "body {font-family: -apple-system, sans-serif; font-size: 16px; line-height: 1.6; padding: 20px;}"
    "code {background-color: #f6f8fa; padding: 2px 4px; border-radius: 4px;}"
    "pre {background-color: #f6f8fa; padding: 16px; border-radius: 8px; overflow-x: auto;}"
    "pre code {background-color: transparent; padding: 0;}"
    "table {border-collapse: collapse;width: 100%;}"
    "th, td {border: 1px solid black;}"
    "tr {border-bottom: 1px solid black;}"
    "</style>";
    
    // 组合完整HTML
    NSString *fullHTML = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><meta charset='utf-8'>%@</head><body>%@</body></html>", css, htmlString];
    
    // 加载到WebView
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.webView loadHTMLString:fullHTML baseURL:nil];
    self.webView.backgroundColor = UIColor.whiteColor;
    // 禁用滚动
    self.webView.scrollView.scrollEnabled = YES;
    [self.view addSubview:self.webView];
}

- (void)AttributedString:(NSString *)markdownText {
    
    NSAttributedStringMarkdownParser* parser = [[NSAttributedStringMarkdownParser alloc] init];
//    NSAttributedString* attributedText = [parser attributedStringFromMarkdownString: markdownText];
    
    NSAttributedString *string = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:markdownText];
    // 显示内容
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 600)];
    textView.center = self.view.center;
    textView.backgroundColor = UIColor.grayColor;
    textView.attributedText = string;
    textView.editable = false;
    [self.view addSubview:textView];
}

- (void)renderMarkdown_UITextView:(NSString *)markdown {
    NSError *error;
    // 转换 Markdown 为 HTML
    NSString *html = [MMMarkdown HTMLStringWithMarkdown:markdown extensions:MMMarkdownExtensionsGitHubFlavored error:&error];
    
    if (error) {
        NSLog(@"Markdown转HTML出错: %@", error.localizedDescription);
        return;
    }
    
    // 将 HTML 转为 NSAttributedString
    NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    // 配置DTCoreText选项
    NSDictionary *options = @{
        DTUseiOS6Attributes: @(YES),
        DTDefaultFontFamily: @"Helvetica",
        DTDefaultFontSize: @(16.0),
        DTDefaultLinkColor: [UIColor blueColor],
        DTDefaultLinkDecoration: @(YES),
        DTDefaultTextColor: [UIColor blackColor],
        @"DTDefaultTableBorderWidth": @(1.0),
        @"DTDefaultTableBorderColor": [UIColor blackColor],
        @"DTDefaultTableCellPadding": @(8.0),
        @"DTDefaultTableCellBorder": @(1.0)
    };
    
    // 使用DTAttributedTextView替代UITextView
    DTAttributedTextView *textView = [[DTAttributedTextView alloc] initWithFrame:self.view.bounds];
    textView.shouldDrawImages = YES;  // 允许显示图片
    textView.shouldDrawLinks = YES;   // 允许显示链接
//    textView.textDelegate = self;     // 设置代理以处理链接点击等事件
    
    // 创建DTHTMLAttributedStringBuilder并设置属性字符串
    DTHTMLAttributedStringBuilder *builder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:htmlData options:options documentAttributes:nil];
    textView.attributedString = [builder generatedAttributedString];
    
    [self.view addSubview:textView];
}

- (void)testWeb {
    // 初始化 WKWebView
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    
    // 禁用滚动
    self.webView.scrollView.scrollEnabled = NO;
    
    // 加载网页
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    
    // 添加 KVO 监听 contentSize 变化
    [self.webView.scrollView addObserver:self
                              forKeyPath:@"contentSize"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    
}

// 监听 contentSize 变化
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGSize contentSize = [change[NSKeyValueChangeNewKey] CGSizeValue];
        
        // 根据 contentSize 更新 webView 的高度
        CGRect frame = self.webView.frame;
        frame.size.height = contentSize.height;
        self.webView.frame = frame;
        
        // 触发父视图的布局更新
        [self.view setNeedsLayout];
    }
}

// 在 dealloc 方法中移除 KVO 观察者
- (void)dealloc {
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (NSAttributedString *)createTableAttributedString:(NSString *)tableMarkdown {
    // 解析表格Markdown
    NSArray *lines = [tableMarkdown componentsSeparatedByString:@"\n"];
    NSMutableArray *rows = [NSMutableArray array];
    
    for (NSString *line in lines) {
        if ([line hasPrefix:@"|"] && ![line containsString:@"|-"]) {
            NSArray *cells = [line componentsSeparatedByString:@"|"];
            NSMutableArray *cellContents = [NSMutableArray array];
            
            for (NSString *cell in cells) {
                NSString *trimmedCell = [cell stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (trimmedCell.length > 0) {
                    [cellContents addObject:trimmedCell];
                }
            }
            
            if (cellContents.count > 0) {
                [rows addObject:cellContents];
            }
        }
    }
    
    // 创建表格的NSAttributedString
    NSMutableAttributedString *tableString = [[NSMutableAttributedString alloc] init];
    
    // 表格样式
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineSpacing = 5.0;
    
    // 遍历行
    for (NSArray *row in rows) {
        NSMutableAttributedString *rowString = [[NSMutableAttributedString alloc] init];
        
        // 遍历单元格
        for (NSString *cell in row) {
            NSAttributedString *cellString = [[NSAttributedString alloc]
                                              initWithString:[NSString stringWithFormat:@"%@\t", cell]
                                              attributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                NSParagraphStyleAttributeName: paragraphStyle
            }];
            [rowString appendAttributedString:cellString];
        }
        
        // 添加换行
        [rowString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [tableString appendAttributedString:rowString];
    }
    
    return tableString;
}

@end
