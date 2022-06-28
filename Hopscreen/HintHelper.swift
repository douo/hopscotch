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

class HintHelper {
    static let shared = HintHelper()
    let windowController:NSWindowController
    var closeHandler : (() -> Void)?
    init(){
        windowController = {
            class Anonymous:NSWindowController{
                
            }
            return Anonymous()
        }()
    }
    func notify(screen:NSScreen, type:HintType){
        print("screen:\(screen.description):\(screen.frame)")
        closeHandler?()
        guard type != .None else {
            return
        }
        let highlight:Hint
        switch type {
        case .RedSpot:
            highlight = RedspotHint()
        case .Ripple:
            highlight = RippleHint()
        case .Logo:
            highlight = ImageHint()
        default:
            highlight = RippleHint()
        }
        let w = prepareWindow(screen: screen)
        windowController.window = w
        closeHandler = highlight.self.showOn(window: w)
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

private class RippleHint: Hint{
    func showOn(window:NSWindow) -> (() -> Void) {
        print("window:\(window.frame)")
        let layer = SJRippleLayer()
        layer.fillColor = .init(red: 0.5, green: 0.5, blue: 0.5, alpha:0.12)
        layer.opacity = 0
        layer.bounds = NSMakeRect(0, 0, window.frame.width, window.frame.height)
        layer.maximumRadius = max(window.frame.width, window.frame.height)/2.0 //window frame 坐标是相对全局（多屏整合）显示
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.addSublayer(layer)
        layer.startRipple(at: CGPoint(x:layer.bounds.midX,y:layer.bounds.midY), animated: true, completion: {
            window.close()
        })
        return {
            window.close()
        }
    }
}

private class RedspotHint : Hint{
    func showOn(window: NSWindow) -> (() -> Void) {
        
        let layer = CAShapeLayer()
        layer.bounds = NSMakeRect(0, 0, window.frame.width, window.frame.height)
        layer.fillColor = .clear
        layer.lineWidth = 3
        
        layer.strokeColor = .init(red: 1, green: 0, blue: 0, alpha: 1)
        layer.allowsEdgeAntialiasing = true
        let path = CGMutablePath()
        let center = CGPoint.init(x: layer.bounds.midX, y: layer.bounds.midY)
        layer.position = center
        print("point:\(center)")
        path.addArc(center: center, radius: 5, startAngle: 0, endAngle: 360, clockwise: false)
        
        layer.path = path
        layer.opacity = 0
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.addSublayer(layer)
        
        CATransaction.begin()
        let fadeOutAnim = CABasicAnimation(keyPath: "opacity")
        fadeOutAnim.fromValue = 1
        fadeOutAnim.toValue = 0
        fadeOutAnim.duration = CFTimeInterval(0.65)
        fadeOutAnim.timingFunction = .init(name: .linear)
        CATransaction.setCompletionBlock({
            window.close()
        })
        layer.add(fadeOutAnim, forKey: nil)
        CATransaction.commit()
        
        return {
            window.close()
        }
    }
}

private class ImageHint : Hint{
    private let DELAY:Double = 0.5 // second
    func showOn(window:NSWindow) -> (() -> Void) {
        let i = NSImage(named: "ic_status_bar")
        let size = i?.size ?? NSMakeSize(0, 0)
        let iv = NSImageView(frame: NSMakeRect(
                                (window.frame.width - size.width)/2,
                                (window.frame.height - size.height)/2,
                                size.width,  size.height))
        iv.image = i
        window.contentView?.addSubview(iv)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1
            iv.animator().alphaValue = 0
        }, completionHandler: {
            window.close()
        })
        return {
            window.close()
        }
    }
}
enum HintType: CaseIterable{
    case None
    case Ripple
    case RedSpot
    case Logo
    
    var value: String{
        switch self {
        case .None:
            return "None"
        case .Logo:
            return "Logo"
        case .RedSpot:
            return "Redspot"
        case .Ripple:
            return "Ripple"
            
        }
    }
    
    static func from(_ vaule:String) -> HintType{
        switch vaule {
        case "None":
            return .None
        case "Logo":
            return .Logo
        case "Redspot":
            return .RedSpot
        case "Ripple":
            return .Ripple
        default:
            return .None
        }
    }
}

protocol Hint {
    ///
    /// - Returns: close handle
    func showOn(window:NSWindow) -> (() -> Void)
}
