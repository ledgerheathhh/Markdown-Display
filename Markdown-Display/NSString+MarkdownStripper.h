//
//  NSString+MarkdownStripper.h
//  Markdown-Display
//
//  Created by Ledger Heath on 2025/5/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MarkdownStripper)


/**
 * @brief 移除字符串中的 Markdown 标记，返回纯文本。
 * @return 移除了 Markdown 标记的纯文本字符串。
 */
- (NSString *)stringByStrippingMarkdown;

@end

NS_ASSUME_NONNULL_END
