//
//  ContentView.swift
//  Demo
//
//  Created by Tiou Lims on 2020/6/24.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import SwiftUI
import ShortcutRecorder



struct ContentView: View {
    var displaySize = 4
    var body: some View {
        VStack(alignment: .leading){
            HStack(spacing: 0) {
                HStack{
                    Text(NSLocalizedString("Focus Next Screen", comment: ""))
                    ShortcutView(focusType: .Next, keyPath: "values.shortcut.next")
                        .frame(minWidth: 30, idealWidth: 80, maxWidth: 120, minHeight: 10, idealHeight: 30, maxHeight: 100, alignment: .center)
                }
                Spacer()
                HStack{
                    Text(NSLocalizedString("Focus Previous Screen", comment: ""))
                    ShortcutView(focusType: .Previous, keyPath: "values.shortcut.previous")
                        .frame(minWidth: 30, idealWidth: 80, maxWidth: 120, minHeight: 10, idealHeight: 30, maxHeight: 100, alignment: .center)
                }
            }
            Spacer()
            Text(NSLocalizedString("Assign", comment: ""))
            ScreenList().environmentObject(ScreenListModel())
        }.padding(20)
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
