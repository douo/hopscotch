//
//  ScreenFocusHelper.swift
//  Demo
//
//  Created by Tiou Lims on 2020/6/24.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import Cocoa

let SFHelper = ScreenFocusHelper()

class ScreenFocusHelper: NSObject {
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
            let num = s.deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")]
            // 获取当前显示器在全局显示空间中占的位置
            let rect = CGDisplayBounds(num as! CGDirectDisplayID)
            // 获取鼠标在全局空间中的坐标，用 NSEvent.mouseLocation 的零点位置与显示器的全局空间零点不同
            if let currentMouseLocation = CGEvent(source: nil)?.location{
                if(rect.contains(currentMouseLocation)){
                    return s
                }
            }
        }
        return nil
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
        SFNotifier.hellow(screen: screen)
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
            print("User creation failed with error: \(error)")
        }
    }
    
    func focusPrevious(){
        do {
            try centerMouseIn(screen: previousOfMain())
        } catch  {
            print("User creation failed with error: \(error)")
        }
    }
    
    func focusIndex(index:Int){
        let temp = screens()
        if(index < temp.count){
            centerMouseIn(screen: screens()[index])
        }
    }
}
