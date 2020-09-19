//
//  ShortcutHelper.swift
//  ScreenJumper
//
//  Created by Tiou Lims on 2020/6/26.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import Foundation
import Cocoa
import ShortcutRecorder
import Combine
import LaunchAtLogin

enum FocusType{
    case Next
    case Previous
    case Index(Int)
}

private let kHintTypeKey = "values.hintType"
private let kLaunchAtLoginKey = "values.launchAtLogin"
private let kScreenSizeKey = "values.screenSize"
private let kNextKey = "values.shortcut.next"
private let kPreviousKey = "values.shortcut.previous"


class ShortcutRepository: ObservableObject {
    static let shared = ShortcutRepository()
    
    let next:ShortcutModel
    let previous:ShortcutModel
    
    @Published var hintType: HintType
    @Published var assigns:[ShortcutModel]
    
    var assignSize: Int{
        get {
            assigns.count
        }
        set {
            let size = max(NSScreen.screens.count, newValue)
            while(size < assigns.count){
                let ele = assigns.removeLast()
                let defaults = NSUserDefaultsController.shared
                defaults.setValue(nil,forKeyPath: ele.keyPath)
            }
            while(size > assigns.count){
                let index = assigns.count
                let sm = ShortcutModel(focusType:.Index(index),keyPath:"values.shortcut.screen_\(index)")
                assigns.append(sm)
            }
            updateSize(size)
        }
    }
    
    
    private var subscribers = Set<AnyCancellable>()
    
    init() {
        next = createBase(for: .Next,keyPath: kNextKey,shortcutStr: "⌃⇧.")
        previous = createBase(for: .Previous,keyPath: kPreviousKey,shortcutStr: "⌃⇧,")
        let size = restoreSize()
        assigns = []
        hintType = restoreHintType()
        
        assignSize = size
        
        CGDisplayRegisterReconfigurationCallback({ (id, flags, pointer) in
            print("wtf:\(id) \(flags)")
            //TODO 只监听显示器增减还不能覆盖所有情况，比如镜像显示器。暂不继续深入
            //                   if ((flags.rawValue & (CGDisplayChangeSummaryFlags.addFlag.rawValue | CGDisplayChangeSummaryFlags.removeFlag.rawValue)) != 0) {
            let size = restoreSize()
            ShortcutRepository.shared.assigns = []
            ShortcutRepository.shared.assignSize = size
            //                   }
        }, nil)
        
        self.$hintType
            .map{$0.value}
            .sink{
                print("sink:\($0)")
                let defaults = NSUserDefaultsController.shared.defaults
                defaults.set($0, forKey: kHintTypeKey)}
            .store(in: &subscribers) // 不 store 的话， 订阅器会主动取消，可能是没有引用导致被 ARC 回收
        
        ScreenFocusHelper.shared.didCenterInCallback = { screen in
            HintHelper.shared.notify(screen: screen, type: self.hintType)
        }
        
        LaunchAtLogin.isEnabled = restoreLaunchAtLogin()
        LaunchAtLogin.publisher
            .sink{
                let defaults = NSUserDefaultsController.shared.defaults
                defaults.set($0, forKey: kLaunchAtLoginKey)}
            .store(in: &subscribers)
    }
    
    func register() {
        next.register()
        previous.register()
        for item in assigns {
            item.register()
        }
    }
}
private func createBase(for focusType: FocusType, keyPath:String, shortcutStr:String) -> ShortcutModel{
    let data = ShortcutModel(focusType: focusType, keyPath: keyPath)
    let defaults = NSUserDefaultsController.shared
    let obj = defaults.value(forKeyPath: keyPath)
    if(obj == nil){
        let options: [NSBindingOption : NSValueTransformerName] = [.valueTransformerName:.keyedUnarchiveFromDataTransformerName]
        let recorder = RecorderControl()
        //FIXME 不通过 RecorderControl 设置默认值
        recorder.bind(.value, to: defaults, withKeyPath: keyPath, options: options)
        recorder.objectValue = Shortcut(keyEquivalent: shortcutStr)
        recorder.unbind(.value)
    }
    return data
}

private func updateSize(_ size:Int){
    let defaults = NSUserDefaultsController.shared.defaults
    defaults.set(size, forKey: kScreenSizeKey)
}

private  func restoreSize() -> Int{
    let defaults = NSUserDefaultsController.shared.defaults
    var size = defaults.integer(forKey: kScreenSizeKey)
    if(size == 0 || size < NSScreen.screens.count){
        size = NSScreen.screens.count
        updateSize(size)
    }
    return size
}

private  func restoreLaunchAtLogin() -> Bool{
    let defaults = NSUserDefaultsController.shared.defaults
    return defaults.bool(forKey: kLaunchAtLoginKey)
}

private func restoreHintType() -> HintType{
    let defaults = NSUserDefaultsController.shared.defaults
    
    if let value = defaults.string(forKey: kHintTypeKey) {
        return HintType.from(value)
    }else{
        return .Ripple
    }
}



struct ShortcutModel{
    var focusType: FocusType
    var keyPath:String
    var action:ShortcutAction
    
    func register() {
        GlobalShortcutMonitor.shared.addAction(action, forKeyEvent: .down)
    }
    
    init(focusType:FocusType,keyPath:String) {
        self.focusType = focusType
        self.keyPath = keyPath
        let defaults = NSUserDefaultsController.shared
        switch focusType {
        case .Next:
            action =  ShortcutAction(keyPath: keyPath, of: defaults) { _ in
                ScreenFocusHelper.shared.focusNext()
                return true
            }
        case .Previous:
            action =  ShortcutAction(keyPath: keyPath, of: defaults) { _ in
                ScreenFocusHelper.shared.focusPrevious()
                return true
            }
        case .Index(let idx):
            action =  ShortcutAction(keyPath: keyPath, of: defaults) { _ in
                ScreenFocusHelper.shared.focusIndex(index: idx)
                return true
            }
        }
    }
}
