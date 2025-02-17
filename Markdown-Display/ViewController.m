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

@interface ViewController ()

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 读取文件并将其内容转换为字符串
    NSString *filePath = @"./file.md";  // 文件的路径
    NSError *error = nil;
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        NSLog(@"读取文件失败: %@", error.localizedDescription);
        NSString *text = @"然后在markdown里，也有11类样式呀，是都要支持吗？\nDeepSeek 支持以下 Markdown 格式，这些格式可以帮助你更好地组织和呈现内容：\n\n\n### 1. **文本样式**\n\n\n- **粗体**：使用 `**` 或 `__` 包裹文本，例如 **粗体文本**。\n- **斜体**：使用 `*` 或 `_` 包裹文本，例如 *斜体文本*。\n- **加粗斜体**：结合 `**` 和 `*`，例如 ***加粗斜体文本***。\n- **删除线**：使用 `~~` 包裹文本，例如 ~~删除线文本~~。\n\n\n### 2. **列表**\n\n\n- **无序列表**：使用 `-`、`*` 或 `+`，例如：\n\n\n  - 项目1\n  - 项目2\n- **有序列表**：使用数字加点，例如：\n\n\n  1. 项目1\n  2. 项目2\n- **嵌套列表**：缩进添加子项目，例如：\n\n\n  1. 项目1\n     - 子项目1\n     - 子项目2\n\n\n### 3. **链接**\n\n\n- **普通链接**：使用 [链接文本](URL)，例如 [DeepSeek](https://www.deepseek.com)。\n- **带标题的链接**：[链接文本](URL \"标题\")，例如 [DeepSeek](https://www.deepseek.com \"DeepSeek官网\")。\n\n\n### 4. **图片**\n\n\n- 使用 ![替代文本](http://localhost:9529/palogo.png)，例如 ![DeepSeek](http://localhost:9529/palogo.png)。\n\n\n### 5. **代码块**\n\n\n- **行内代码**：使用反引号 `包裹，例如 `print(\"Hello, World!\")`。\n- **代码块**：使用三个反引号 ``` 或 ``````，例如：\n  ```python\n  print(\"Hello, World!\")\n  ```\n- **高亮代码**：指定语言，例如 ```python，支持多种语言高亮。\n\n\n### 6. **表格**\n\n\n- 使用 `|` 和 `-` 创建表格，例如：\n  | 姓名  | 年龄 |\n  | ----- | ---- |\n  | Alice | 30   |\n  | Bob   | 25   |\n- 支持对齐方式：`| 左对齐 | 右对齐 | 居中 |`，使用 `:` 和 `-` 设置。\n\n\n### 7. **块引用**\n\n\n- 使用 `>` 引用文本，例如：\n\n\n  > 这是一个块引用。\n  >\n\n\n### 8. **分割线**\n\n\n- 使用 `---` 创建水平分割线，例如：\n  ---\n\n\n### 9. **任务列表**\n\n\n- 使用 `- [ ]` 创建未完成任务，`- [x]` 创建已完成任务，例如：\n\n\n  - [X] 完成作业\n  - [ ] 开会\n\n\n### 10. **数学公式**\n\n\n- 使用 `$$` 包裹行内公式，例如 $$E=mc^2$$。\n- 使用 `$$` 包裹块级公式，例如：\n  $$\n  \\int_{0}^{1} x^2 dx\n  $$\n\n\n### 11. **LaTeX**\n\n\n- 支持 LaTeX 语法，用于复杂公式，例如：\n  $$\n  \\frac{d}{dx} e^{x} = e^{x}\n  $$\n\n";
        
        [self renderMarkdown_1:text];
    } else {
        NSLog(@"文件内容: %@", fileContent);
        [self renderMarkdown_1:fileContent];
    }
//    NSString *text = @"# 这是标题\n\n这是一些普通文本。\n\n- 列表项1\n- 列表项2";
//    [self renderMarkdown:@"# 这是标题\n\n这是一些普通文本。\n\n- 列表项1\n- 列表项2"];
}

- (void)renderMarkdown:(NSString *)markdown {
    NSError *error = nil;
    
    // 使用MMMarkdown转换Markdown为HTML
    NSString *htmlString = [MMMarkdown HTMLStringWithMarkdown:markdown error:&error];
    
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
    "</style>";
    
    // 组合完整HTML
    NSString *fullHTML = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><meta charset='utf-8'>%@</head><body>%@</body></html>", css, htmlString];
    
    // 加载到WebView
    [self.webView loadHTMLString:fullHTML baseURL:nil];
    [self.view addSubview:self.webView];
}

- (void)AttributedString {
    
    // Markdown 内容
    NSString *markdownText = @"\n\n# 这是标题\n\n这是一些普通文本。\n\n- 列表项1\n- 列表项2";
    
    NSAttributedStringMarkdownParser* parser = [[NSAttributedStringMarkdownParser alloc] init];
    NSAttributedString* attributedText = [parser attributedStringFromMarkdownString: markdownText];
    
    // 显示内容
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)]; // 设置TextView的大小
    textView.center = self.view.center; // 设置TextView的中心为视图的中心
    textView.backgroundColor = UIColor.grayColor;
    textView.attributedText = attributedText;
    textView.editable = false;
    [self.view addSubview:textView];
}

- (void)renderMarkdown_1:(NSString *)markdown {
    NSError *error;
    // 转换 Markdown 为 HTML
    NSString *html = [MMMarkdown HTMLStringWithMarkdown:markdown error:&error];
    
    // 将 HTML 转为 NSAttributedString
    NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithHTMLData:htmlData
                                                                             options:@{DTUseiOS6Attributes: @YES}
                                                                  documentAttributes:nil];
    // 显示内容
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 600)];
    textView.attributedText = attributedText;
    textView.center = self.view.center;
    textView.backgroundColor = UIColor.whiteColor;
    textView.editable = NO;
    [self.view addSubview:textView];
}

@end
