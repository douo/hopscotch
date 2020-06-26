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

enum FocusType{
    case Next
    case Previous
    case Index(Int)
}

class ShortcutRepository: ObservableObject {
    static let shared = ShortcutRepository()
    
    let next:ShortcutModel
    let previous:ShortcutModel
    
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
            ShortcutRepository.updateSize(size)
        }
    }
    
    private static func createBase
        (focusType: FocusType, keyPath:String, shortcutStr:String) -> ShortcutModel{
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
    
    init() {
        next = ShortcutRepository.createBase(focusType: .Next,keyPath: "values.shortcut.next",shortcutStr: "⌃⇧.")
        previous = ShortcutRepository.createBase(focusType: .Previous,keyPath: "values.shortcut.previous",shortcutStr: "⌃⇧,")
        let size = ShortcutRepository.restoreSize()
        assigns = []
        assignSize = size
    }
    
    func register() {
        next.register()
        previous.register()
        for item in assigns {
            item.register()
        }
    }
    
    private static func updateSize(_ size:Int){
        let defaults = NSUserDefaultsController.shared.defaults
        defaults.set(size, forKey: "values.screenSize")
    }
    
    private  static func restoreSize() -> Int{
        let defaults = NSUserDefaultsController.shared.defaults
        var size = defaults.integer(forKey: "values.screenSize")
        if(size == 0 || size < NSScreen.screens.count){
            size = NSScreen.screens.count
            updateSize(size)
        }
        return size
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
                SFHelper.focusNext()
                return true
            }
        case .Previous:
            action =  ShortcutAction(keyPath: keyPath, of: defaults) { _ in
                SFHelper.focusPrevious()
                return true
            }
        case .Index(let idx):
            action =  ShortcutAction(keyPath: keyPath, of: defaults) { _ in
                SFHelper.focusIndex(index: idx)
                return true
            }
        }
    }
}
