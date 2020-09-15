//
//  HightlightHelper.swift
//  系统处于键盘输入状态时，mac 会隐藏鼠标光标，无法分辨当前焦点屏幕，需要额外视觉效果
//  这就是这个类所做的事
//  ScreenJumper
//
//  Created by tiou on 2020/9/14.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import Foundation
import Cocoa

class HightlightHelper {
    static let singleton = HightlightHelper()
    let windowController:NSWindowController
    var closeHandler : (() -> Void)?
    init(){
        windowController = {
            class Anonymous:NSWindowController{
                
            }
            return Anonymous()
        }()
    }
    func notify(screen:NSScreen){
        closeHandler?()
        let w = prepareWindow(screen: screen)
        windowController.window = w
        closeHandler = ImageHighlight().self.showOn(window: w)
    }
    
    
    /// 创建一个全屏幕透明的 Window
    private func prepareWindow(screen: NSScreen) -> NSWindow{
        let rect = NSMakeRect(0,
                              0,
                              screen.frame.width,
                              screen.frame.height)
        let w = NSWindow(contentRect: rect,
                         styleMask: [.fullSizeContentView], //隐藏标题栏
                         backing: .buffered,
                         defer: false,
                         screen: screen)
        w.isOpaque = false
        w.backgroundColor = NSColor.clear
        w.hasShadow = false
        w.level = .floating
        w.ignoresMouseEvents = true
        w.makeKeyAndOrderFront(nil)
        return w;
    }
}

private class ImageHighlight : Highlight{
    private let DELAY:Double = 0.5 // second
    func showOn(window:NSWindow) -> (() -> Void) {
        view.frame = NSMakeRect(
            (window.frame.width - view.frame.width)/2,
            (window.frame.height - view.frame.height)/2,
             view.frame.width,  view.frame.height)
        window.contentView?.addSubview(view)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1
            self.view.animator().alphaValue = 0
        }, completionHandler: {
            window.close()
        })
//        DispatchQueue.main.asyncAfter(deadline: .now() + DELAY){
//            window.close()
//        }
        
        return {
            window.close()
        }
    }
    
    let view: NSView
    init() {
        let i = NSImage(named: "ic_status_bar")
        let size = i?.size ?? NSMakeSize(0, 0)
        let iv = NSImageView(frame: NSMakeRect(0, 0, size.width, size.height))
        iv.image = i
        view = iv
    }
}
/// highlight 需要关注怎么显示和显示多久
protocol Highlight {
    
    ///
    /// - Returns: close handle
    func showOn(window:NSWindow) -> (() -> Void)
}
