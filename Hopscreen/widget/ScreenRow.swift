//
//  DisplayRow.swift
//  ScreenJumper
//
//  Created by Tiou Lims on 2020/6/26.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import SwiftUI

struct ScreenRowVO {
    let idx:Int
    let screenName:String?
    var shortcut:ShortcutModel
    var hasScreen:Bool {
        get {
            screenName != nil
        }
    }
}

struct ScreenRow: View {
    var model:ScreenRowVO
    var body: some View {
        HStack{
            Text(String(format: NSLocalizedString("Screen %d", comment: ""), arguments: [model.idx]))
            Spacer()
            if model.hasScreen {
                Text(model.screenName!)
            }else{
                Text("None")
            }
            Spacer()
            ShortcutView(model: model.shortcut)
                .fixedSize()
        }
    }
}

struct ScreenRow_Previews: PreviewProvider {
    static var previews: some View {
        ScreenRow(model: ScreenRowVO(idx: 0,screenName: "Demo",shortcut:ShortcutModel(focusType:.Index(0),keyPath: "values.test")))
    }
}
