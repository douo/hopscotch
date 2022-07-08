//
//  ScreenFocusHelper.swift
//  Demo
//
//  Created by Tiou Lims on 2020/6/24.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import Cocoa
import Combine
import CoreGraphics

class ScreenFocusHelper: NSObject {
    static let shared =  ScreenFocusHelper()
    var didCenterInCallback: ((NSScreen)->Void)?
    
    override init() {
       
    }
    private func screens() -> [NSScreen]{
        return NSScreen.screens
    }
    
    private func nextOfMain() throws -> NSScreen{
        let scrs = screens()
        guard let main = findMain(), let mIndx = scrs.firstIndex(of: main) else{
            throw NSError(domain: "illegal state of main",code: 1)
        }
        let nextIdx = (mIndx+1) % scrs.count
        return scrs[nextIdx]
    }
    
    /*
     找到鼠标指针所在的显示器，
     FYI：NSScreen.main 获取的是当前应用窗口所在的显示器
     */
    private func findMain() -> Optional<NSScreen>{
        for s in NSScreen.screens {
            // 获取当前显示器在全局显示空间中占的位置
            let rect = s.frameInCGCoordinates()
            // 获取鼠标在全局空间中的坐标，用 NSEvent.mouseLocation 的零点位置与显示器的全局空间零点不同
            if let currentMouseLocation = CGEvent(source: nil)?.location{
                if(rect.contains(currentMouseLocation)){
                    return s
                }
            }
        }
        return nil
    }
    
    
    func axCallWhichCanThrow<T>(_ result: AXError, _ successValue: inout T) throws -> T? {
        switch result {
            case .success: return successValue
            // .cannotComplete can happen if the app is unresponsive; we throw in that case to retry until the call succeeds
        case .cannotComplete: throw NSError.init()
            // for other errors it's pointless to retry
            default: return nil
        }
    }
    
    func attribute<T>(_ key: String, _ _: T.Type) throws -> T? {
        var value: AnyObject?
        return try axCallWhichCanThrow(AXUIElementCopyAttributeValue(self as! AXUIElement, key as CFString, &value), &value) as? T
    }

    /*
     当前键盘焦点所在的窗口所在的屏幕
     按照 API 描述，应该用 NSScreen.main 但是实际上并不可行，
     见 https://github.com/lwouis/alt-tab-macos/issues/1129
    */
    private func findActive() throws -> NSScreen {
        guard
            let pid = NSWorkspace.shared.frontmostApplication?.processIdentifier
        else{
            guard let s = NSScreen.main else {
                    throw NSError(domain: "illegal state of active",code: 1)
            }
            return s
        }
        let ax = AXUIElementCreateApplication(pid)
        guard let fw = try ax.focusedWindow(),
              let pos = try fw.position(),
              let size = try fw.size()
        else{
            guard let s = NSScreen.main else {
                    throw NSError(domain: "illegal state of active",code: 2)
            }
            return s
        }
        let winRect = CGRect(origin: pos, size: size)
        guard let s = NSScreen.screens.first(where:{ winRect.intersects($0.frameInCGCoordinates()) })
        else {
            throw  NSError(domain: "illegal state of main",code: 3)
        }
        return s
    }
    
    private func isAccessibilityEnabled() -> Bool {
        let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        return AXIsProcessTrustedWithOptions(options)
    }
    
    private func previousOfMain() throws -> NSScreen{
        let scrs = screens()
        guard let main = findMain(), let mIndx = scrs.firstIndex(of: main) else{
            throw NSError(domain: "illegal state of main",code: 1)
        }
        let nextIdx = (mIndx-1+scrs.count) % scrs.count
        return scrs[nextIdx]
    }
    
    
    private func centerMouseIn(screen:NSScreen){
        didCenterInCallback?(screen)
        let cX = screen.frame.width/2
        let cY = screen.frame.height/2
        let number = screen.deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")]
        CGDisplayMoveCursorToPoint(number as! CGDirectDisplayID,CGPoint(x: cX ,y: cY))
    }
    
    func isFocus(screen:NSScreen) -> Bool{
        return findMain() == screen
    }
    
    func focusNext(){
        do {
            try centerMouseIn(screen: nextOfMain())
        } catch  {
            print("Focus next failed. cause by: \(error)")
        }
    }
    
    func focusPrevious(){
        do {
            try centerMouseIn(screen: previousOfMain())
        } catch  {
            print("Focus previous failed. cause by: \(error)")
        }
    }
    
    func focusActive(){
        do {
            if(isAccessibilityEnabled()){
                try centerMouseIn(screen: findActive())
            }
        } catch{
            print("Focus active failed. cause by: \(error)")
        }
    }
    
    func focusIndex(index:Int){
        let temp = screens()
        if(index < temp.count){
            centerMouseIn(screen: screens()[index])
        }
    }
}

extension NSScreen{
    func frameInCGCoordinates() -> CGRect{
        let num = deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")]
        // 获取当前显示器在全局显示空间中占的位置
        return CGDisplayBounds(num as! CGDirectDisplayID)
    }
}
