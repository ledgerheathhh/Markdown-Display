//
//  MarkdownView.swift
//  Markdown-Display
//
//  Created by Ledger Heath on 2025/3/10.
//

import Foundation
import MarkdownView
import UIKit

@objcMembers
public class MDViewWrapper: NSObject {
    private var markdownView: MarkdownView
    private var heightCallback: ((CGFloat) -> Void)?
    
    private var heightConstraint: NSLayoutConstraint?
    
    @MainActor public init(frame: CGRect) {
        print("MDViewWrapper - 初始化开始")
        markdownView = MarkdownView()
        markdownView.isScrollEnabled = false
        super.init()
        testClass.testClassMethod()
        // 设置自动布局
        markdownView.translatesAutoresizingMaskIntoConstraints = false
        
        // 创建一个容器视图
        let containerView = UIView(frame: frame)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // 将MarkdownView添加到容器视图
        containerView.addSubview(markdownView)
        
        // 设置MarkdownView的约束
        heightConstraint = markdownView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            markdownView.topAnchor.constraint(equalTo: containerView.topAnchor),
            markdownView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            markdownView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            heightConstraint!,
            containerView.bottomAnchor.constraint(equalTo: markdownView.bottomAnchor)
        ])
        
        // 设置渲染完成的回调
        print("MDViewWrapper - 设置onRendered回调")
        markdownView.onRendered = { [weak self] height in
            print("MDViewWrapper - onRendered回调被触发，高度: \(height)")
            DispatchQueue.main.async {
                // 更新高度约束
                self?.heightConstraint?.constant = height
                self?.heightConstraint?.isActive = true
                
                // 调用外部设置的高度回调
                self?.heightCallback?(height)
                
                // 强制更新布局
                containerView.layoutIfNeeded()
            }
        }
        print("MDViewWrapper - 初始化完成")
    }
    
    public var view: UIView {
        return markdownView
    }
    
    @MainActor @objc(loadWithMarkdown:) public func load(markdown: String) {
        print("MDViewWrapper - 开始加载Markdown内容")
        markdownView.load(markdown: markdown)
        print("MDViewWrapper - Markdown内容加载方法调用完成")
    }
    
    @MainActor @objc(showWithMarkdown:) public func show(markdown: String) {
        markdownView.show(markdown: markdown)
    }
    
    // 添加设置高度回调的方法
    @objc public func setOnHeightReceived(_ callback: @escaping @convention(block) (CGFloat) -> Void) {
        print("MDViewWrapper - 设置高度回调")
        self.heightCallback = callback
        print("MDViewWrapper - 高度回调设置完成")
    }
}

@objcMembers
public class SwiftLibrary: NSObject {
    public var property: String = "Hello"
  
    public func method() -> String {
        return "Swift Method Called"
    }
  
    @objc(customMethodWithParam:)
    public func method(with param: String) -> String {
        return "Received: \(param)"
    }
}
