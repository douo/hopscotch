//
//  MapView.swift
//  Demo
//
//  Created by Tiou Lims on 2020/6/24.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import SwiftUI
import ShortcutRecorder

enum FocusType{
    case Next
    case Previous
    case Index(Int)
}

struct ShortcutView: NSViewRepresentable {
    var focusType: FocusType
    var keyPath:String
    
    func makeNSView(context: Context) -> RecorderControl {
        let recorder = RecorderControl(frame: .zero)
        let defaults = NSUserDefaultsController.shared
        let options: [NSBindingOption : NSValueTransformerName] = [.valueTransformerName:.keyedUnarchiveFromDataTransformerName]
        let action:ShortcutAction
        switch focusType {
        case .Next:
            action = ShortcutAction(keyPath: keyPath, of: defaults) { _ in
                SFHelper.focusNext()
                return true
            }
        case .Previous:
            action = ShortcutAction(keyPath: keyPath, of: defaults) { _ in
                SFHelper.focusPrevious()
                return true
            }
        case .Index(let idx):
            action = ShortcutAction(keyPath: keyPath, of: defaults) { _ in
                SFHelper.focusIndex(index: idx)
                return true
            }
        }
        GlobalShortcutMonitor.shared.addAction(action, forKeyEvent: .down)
        recorder.bind(.value, to: defaults, withKeyPath: keyPath, options: options)
        //recorder.objectValue = Shortcut(keyEquivalent: "⇧^.")
        return recorder
    }
    
    func updateNSView(_ nsView: RecorderControl, context: Context) {
        //print("update\(context)")
    }
    
    typealias NSViewType = RecorderControl
    
}

struct ShortcutView_Previews: PreviewProvider {
    static var previews: some View {
        ShortcutView(focusType: .Next, keyPath: "values.shortcut.previous")
    }
}
