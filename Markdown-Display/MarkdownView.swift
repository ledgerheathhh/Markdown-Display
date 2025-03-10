//
//  MarkdownView.swift
//  Markdown-Display
//
//  Created by Ledger Heath on 2025/3/10.
//

import Foundation

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
