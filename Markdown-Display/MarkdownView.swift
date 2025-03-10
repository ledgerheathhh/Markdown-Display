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
    
    @MainActor public init(frame: CGRect) {
        markdownView = MarkdownView()
        markdownView.frame = frame
        super.init()
    }
    
    public var view: UIView {
        return markdownView
    }
    
    @MainActor public func load(markdown: String) {
        markdownView.load(markdown: markdown)
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
