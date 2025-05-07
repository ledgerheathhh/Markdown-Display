//
//  ViewController.m
//  Markdown-Display
//
//  Created by Ledger Heath on 2025/2/17.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "Markdown_Display-Swift.h"
#import "objcMarkdownView.h"
#import "NSString+MarkdownStripper.h"

@interface ViewController ()

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSBundle *bundle = [NSBundle mainBundle];
    // 读取文件并将其内容转换为字符串
    NSString *filePath = [bundle pathForResource:@"file" ofType:@"md"];  // 文件的路径
    NSError *error = nil;
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if (!error) {
        NSLog(@"读取文件失败: %@", error.localizedDescription);
        NSString *text = @"然后在markdown里，也有11类样式呀，是都要支持吗？\nDeepSeek 支持以下 Markdown 格式，这些格式可以帮助你更好地组织和呈现内容：\n\n\n### 1. **文本样式**\n\n\n- **粗体**：使用 `**` 或 `__` 包裹文本，例如 **粗体文本**。\n- **斜体**：使用 `*` 或 `_` 包裹文本，例如 *斜体文本*。\n- **加粗斜体**：结合 `**` 和 `*`，例如 ***加粗斜体文本***。\n- **删除线**：使用 `~~` 包裹文本，例如 ~~删除线文本~~。\n\n\n### 2. **列表**\n\n\n- **无序列表**：使用 `-`、`*` 或 `+`，例如：\n\n\n  - 项目1\n  - 项目2\n- **有序列表**：使用数字加点，例如：\n\n\n  1. 项目1\n  2. 项目2\n- **嵌套列表**：缩进添加子项目，例如：\n\n\n  1. 项目1\n     - 子项目1\n     - 子项目2\n\n\n### 3. **链接**\n\n\n- **普通链接**：使用 [链接文本](URL)，例如 [DeepSeek](https://www.deepseek.com)。\n- **带标题的链接**：[链接文本](URL \"标题\")，例如 [DeepSeek](https://www.deepseek.com \"DeepSeek官网\")。\n\n\n### 4. **图片**\n\n\n- 使用 ![替代文本](http://localhost:9529/palogo.png)，例如 ![DeepSeek](http://localhost:9529/palogo.png)。\n\n\n### 5. **代码块**\n\n\n- **行内代码**：使用反引号 `包裹，例如 `print(\"Hello, World!\")`。\n- **代码块**：使用三个反引号 ``` 或 ``````，例如：\n  ```python\n  print(\"Hello, World!\")\n  ```\n- **高亮代码**：指定语言，例如 ```python，支持多种语言高亮。\n\n\n### 6. **表格**\n\n\n- 使用 `|` 和 `-` 创建表格，例如：\n  | 姓名  | 年龄 |\n  | ----- | ---- |\n  | Alice | 30   |\n  | Bob   | 25   |\n- 支持对齐方式：`| 左对齐 | 右对齐 | 居中 |`，使用 `:` 和 `-` 设置。\n\n\n### 7. **块引用**\n\n\n- 使用 `>` 引用文本，例如：\n\n\n  > 这是一个块引用。\n  >\n\n\n### 8. **分割线**\n\n\n- 使用 `---` 创建水平分割线，例如：\n  ---\n\n\n### 9. **任务列表**\n\n\n- 使用 `- [ ]` 创建未完成任务，`- [x]` 创建已完成任务，例如：\n\n\n  - [X] 完成作业\n  - [ ] 开会\n\n\n### 10. **数学公式**\n\n\n- 使用 `$$` 包裹行内公式，例如 $$E=mc^2$$。\n- 使用 `$$` 包裹块级公式，例如：\n  $$\n  \\int_{0}^{1} x^2 dx\n  $$\n\n\n### 11. **LaTeX**\n\n\n- 支持 LaTeX 语法，用于复杂公式，例如：\n  $$\n  \\frac{d}{dx} e^{x} = e^{x}\n  $$\n\n";
        
        //        text = @"| 1111111 | 22222222 | 33333333 | 4444444444 | 5555555555555555555555555 | 66666666666666666 |\n| - | - | - | - | - | - |\n| a | b | c | d | e | f |\n";
        
        //        text = @"| 姓名  | 年龄 |\n  | ----- | ---- |\n  | Alice | 30   |\n  | Bob   | 25   |\n";
        [self renderMarkdown_swiftView:text];
        
        NSString *plainText = [text stringByStrippingMarkdown];
        NSLog(@"%@", plainText);
//        [self renderMarkdown_objcMarkdownView:text];
    } else {
        NSLog(@"文件内容: %@", fileContent);
        [self renderMarkdown_swiftView:fileContent];
    }
}

- (void)renderMarkdown_objcMarkdownView:(NSString *)markdown {
    // 使用视图的宽度，但高度设为0，让它根据内容自动调整
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 0);
    objcMarkdownView *mdView = [[objcMarkdownView alloc] initWithFrame:frame];
    
    [mdView loadMarkdown:markdown enableImage:YES css:nil plugins:nil stylesheets:nil styled:YES];
}

- (void)renderMarkdown_swiftView:(NSString *)markdown {
    
//    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
//    scrollView.backgroundColor = UIColor.grayColor;
//    [self.view addSubview:scrollView];
    
    // 使用视图的宽度，但高度设为0，让它根据内容自动调整
//    CGRect frame = CGRectMake(0, 0, 10, 100);
    MarkdownView *mdView = [[MarkdownView alloc] initWithFrame:self.view.frame];
    mdView.isScrollEnabled = NO;
    
    // 将 MarkdownView 添加到视图层次结构中
    NSLog(@"添加到视图层次结构");
    [self.view addSubview:mdView];
    
    // 确保所有设置完成后再加载 Markdown 内容
    NSLog(@"准备加载Markdown内容: %@", markdown);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"开始加载Markdown内容");
        [mdView loadWithMarkdown:markdown enableImage:YES css:nil plugins:nil stylesheets:nil styled:YES];
        NSLog(@"Markdown内容加载完成");
    });

}

@end
