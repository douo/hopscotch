//
//  MapView.swift
//  Demo
//
//  Created by Tiou Lims on 2020/6/24.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import SwiftUI
import ShortcutRecorder

struct ShortcutView: NSViewRepresentable {
    var model:ShortcutModel
    func makeNSView(context: Context) -> RecorderControl {
        let recorder = RecorderControl(frame: .zero)
        let defaults = NSUserDefaultsController.shared
        let options: [NSBindingOption : NSValueTransformerName] = [.valueTransformerName:.keyedUnarchiveFromDataTransformerName]
        model.register()
        recorder.bind(.value, to: defaults, withKeyPath: model.keyPath, options: options)
        return recorder
    }
    
    func updateNSView(_ nsView: RecorderControl, context: Context) {
        //print("update\(context)")
    }
    
    typealias NSViewType = RecorderControl
    
}

struct ShortcutView_Previews: PreviewProvider {
    static var previews: some View {
        ShortcutView(model: ShortcutModel(focusType: .Next, keyPath: "values.shortcut.previous"))
    }
}
