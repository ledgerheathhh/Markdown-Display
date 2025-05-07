//
//  NSString+MarkdownStripper.m
//  Markdown-Display
//
//  Created by Ledger Heath on 2025/5/3.
//

#import "NSString+MarkdownStripper.h"

// 定义一个不太可能在普通文本中出现的 <br> 占位符
#define BR_PLACEHOLDER @"%%BR_NEWLINE_PLACEHOLDER%%"

@implementation NSString (MarkdownStripper)

- (NSString *)stringByStrippingMarkdown {
    NSString *text = self;

    // --- 0. <br> 标签预处理 ---
    // 将 <br>, <br/>, <br /> 替换为占位符，忽略大小写
    text = [self replaceRegex:@"<br\\s*/?>"
                 withTemplate:BR_PLACEHOLDER
                     inString:text
                      options:NSRegularExpressionCaseInsensitive];

    // --- 1. 表格处理 START ---
    // 1a. 移除表格的对齐/分隔行 (例如 |---|---| 或 ---|--- 或 |:--:|:--:|)
    //     这个正则表达式尝试匹配多种形式的分隔行。
    //     替换为空字符串，因为行本身的换行符（如果存在）会由原始文本保留，
    //     或者如果 \n? 匹配了它，后续的行会自然连接。
    text = [self replaceRegex:@"^\\s*[|\\s:-]*[-]{2,}[|\\s:-]*\\s*$\\n?"
                 withTemplate:@"" // 直接移除该行
                     inString:text
                      options:NSRegularExpressionAnchorsMatchLines];

    // 1b. 处理表格内容行（包括表头行）
    //     目标：移除包围的'|'和单元格间的'|'，用制表符'\t'分隔单元格内容。
    //     这些操作需要在 NSRegularExpressionAnchorsMatchLines 上下文中谨慎处理，
    //     或者通过更复杂的逻辑（如逐行处理）。
    //     这里采用一系列替换：

    //     i. 移除行首的 '|' (以及可选的后续空格)
    text = [self replaceRegex:@"^\\s*\\|\\s?"
                 withTemplate:@""
                     inString:text
                      options:NSRegularExpressionAnchorsMatchLines];

    //     ii. 移除行尾的 '|' (以及可选的前导空格)
    text = [self replaceRegex:@"\\s?\\|\\s*$"
                 withTemplate:@""
                     inString:text
                      options:NSRegularExpressionAnchorsMatchLines];

    //     iii. 将内部的 '|' (单元格分隔符) 替换为制表符 '\t'
    //          这会影响所有行内剩余的'|'。假设此时它们主要就是单元格分隔符。
    text = [self replaceRegex:@"\\s*\\|\\s*"
                 withTemplate:@"\t" // 使用制表符作为单元格分隔
                     inString:text
                      options:0]; // 全局替换，非仅限行首尾
    // --- 表格处理 END ---

    // --- 2. 其他 Markdown 标记去除 ---
    // 移除 HTML 标签 (可选，如果你的 Markdown 可能包含 HTML，但注意不要移除之前处理过的 <br> 占位符)
    // 这个规则应该更精确，避免移除我们的占位符，但简单起见，先这样。
    // 如果担心，可以将 HTML 标签移除放到 <br> 处理之前，或让 <br> 占位符更独特。
    text = [self replaceRegex:@"<(?![Bb][Rr]\\s*\\/?)[^>]+>" withTemplate:@"" inString:text options:NSRegularExpressionCaseInsensitive];


    // 图片: ![alt text](url) -> alt text
    text = [self replaceRegex:@"!\\[([^\\]]*)\\]\\([^\\)]+\\)" withTemplate:@"$1" inString:text options:0];

    // 链接: [text](url) -> text
    text = [self replaceRegex:@"\\[([^\\]]+)\\]\\([^\\)]+\\)" withTemplate:@"$1" inString:text options:0];

    // 标题 (H1-H6): # Header -> Header
    text = [self replaceRegex:@"^#{1,6}\\s+" withTemplate:@"" inString:text options:NSRegularExpressionAnchorsMatchLines];

    // 加粗 (**text** 或 __text__)
    text = [self replaceRegex:@"\\*{2}(.+?)\\*{2}" withTemplate:@"$1" inString:text options:0];
    text = [self replaceRegex:@"_{2}(.+?)_{2}" withTemplate:@"$1" inString:text options:0];

    // 斜体 (*text* 或 _text_)
    text = [self replaceRegex:@"\\*(.+?)\\*" withTemplate:@"$1" inString:text options:0];
    text = [self replaceRegex:@"_(.+?)_" withTemplate:@"$1" inString:text options:0];

    // 删除线 (~~text~~)
    text = [self replaceRegex:@"~~(.+?)~~" withTemplate:@"$1" inString:text options:0];

    // 行内代码 (`code`)
    text = [self replaceRegex:@"`(.+?)`" withTemplate:@"$1" inString:text options:0];
    
    // 代码块 (```...```) - 简单移除围栏，保留内容。
    // 需要确保这不会意外捕获行内代码的反引号。
    // 匹配以 ``` 开头（可选语言标记）到 ``` 结尾的块
    // 这个正则比较复杂，简单的剥离可能不完美，特别是嵌套或行内```的情况
    // 先移除围栏：
    text = [self replaceRegex:@"^```[a-zA-Z]*\\n" withTemplate:@"" inString:text options:NSRegularExpressionAnchorsMatchLines]; // 开头
    text = [self replaceRegex:@"\\n```\\s*$" withTemplate:@"" inString:text options:NSRegularExpressionAnchorsMatchLines]; // 结尾


    // 引用 (> quote)
    text = [self replaceRegex:@"^>\\s?" withTemplate:@"" inString:text options:NSRegularExpressionAnchorsMatchLines];

    // 列表 (* item, - item, + item, 1. item)
    text = [self replaceRegex:@"^\\s*[*+-]\\s+" withTemplate:@"" inString:text options:NSRegularExpressionAnchorsMatchLines];
    text = [self replaceRegex:@"^\\s*\\d+\\.\\s+" withTemplate:@"" inString:text options:NSRegularExpressionAnchorsMatchLines];

    // 水平分割线 (---, ***, ___) - 在表格分隔行处理之后，避免冲突
    text = [self replaceRegex:@"^\\s*([*_-])(\\s*\\1\\s*){2,}\\s*$" withTemplate:@"" inString:text options:NSRegularExpressionAnchorsMatchLines];


    // --- 3. 恢复 <br> 占位符为真实换行符 ---
    text = [text stringByReplacingOccurrencesOfString:BR_PLACEHOLDER withString:@"\n"];


    // --- 4. 通用清理 START ---
    // 移除每行行首的多余空格 (可能由移除列表标记、引用标记等产生)
    text = [self replaceRegex:@"^\\s+" withTemplate:@"" inString:text options:NSRegularExpressionAnchorsMatchLines];
    // 移除每行行尾的多余空格
    text = [self replaceRegex:@"\\s+$" withTemplate:@"" inString:text options:NSRegularExpressionAnchorsMatchLines];

    // 将多个连续空格（非制表符）替换为单个空格。制表符通常用于表格列分隔，应保留。
    text = [self replaceRegex:@" {2,}" withTemplate:@" " inString:text options:0];
    
    // 规范化换行符：
    // 1. 移除完全空行（只包含空白字符的行）若它们是多余的。
    //    例如，连续多个空行变一个，或者如果表格处理后留下了一些只有空格的行。
    //    先将只有空白的行变成真正的空行：
    text = [self replaceRegex:@"^\\s+$\\n" withTemplate:@"\n" inString:text options:NSRegularExpressionAnchorsMatchLines];
    // 2. 将3个或更多连续换行符替换为2个换行符（保留段落间的空行）。
    //    单个换行符（来自<br>或表格行）将被保留。
    text = [self replaceRegex:@"\\n{3,}" withTemplate:@"\n\n" inString:text options:0];
    
    // 最后去除整个字符串首尾的空白和换行符
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // --- 通用清理 END ---

    return text;
}

// 辅助方法执行正则替换 (与之前相同)
- (NSString *)replaceRegex:(NSString *)pattern
             withTemplate:(NSString *)templateString
                 inString:(NSString *)sourceString
                  options:(NSRegularExpressionOptions)options {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:options
                                                                             error:&error];
    if (error) {
        // NSLog(@"Error creating regex for pattern '%@': %@", pattern, error); // 可选的日志
        return sourceString; // 出错时返回原字符串
    }

    return [regex stringByReplacingMatchesInString:sourceString
                                           options:0
                                             range:NSMakeRange(0, [sourceString length])
                                      withTemplate:templateString];
}

@end
