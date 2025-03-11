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
    
    @MainActor public init(frame: CGRect) {
        print("MDViewWrapper - 初始化开始")
        markdownView = MarkdownView()
        markdownView.frame = frame
        super.init()
        
        // 设置渲染完成的回调
        print("MDViewWrapper - 设置onRendered回调")
        markdownView.onRendered = { [weak self] height in
            print("MDViewWrapper - onRendered回调被触发，高度: \(height)")
            DispatchQueue.main.async {
                self?.heightCallback?(height)
            }
        }
        print("MDViewWrapper - 初始化完成")
    }
    
    public var view: UIView {
        return markdownView
    }
    
    @MainActor public func load(markdown: String) {
        print("MDViewWrapper - 开始加载Markdown内容")
        markdownView.load(markdown: markdown)
        print("MDViewWrapper - Markdown内容加载方法调用完成")
    }
    
    // 添加设置高度回调的方法
    public func setOnHeightReceived(_ callback: @escaping (CGFloat) -> Void) {
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
