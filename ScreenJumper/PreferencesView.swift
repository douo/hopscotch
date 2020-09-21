//
//  ContentView.swift
//  Demo
//
//  Created by Tiou Lims on 2020/6/24.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import SwiftUI
import ShortcutRecorder
import LaunchAtLogin


struct PreferencesView: View {
    var displaySize = 4
    @EnvironmentObject var repo:ShortcutRepository
    var body: some View {
        VStack(alignment: .leading){
            HStack(spacing: 0) {
                HStack(alignment: VerticalAlignment.center, spacing: 0){
                    Text(NSLocalizedString("Next Screen:", comment: ""))
                    ShortcutView(model: repo.next).frame(minWidth: 30, idealWidth: 30, maxWidth: 148, minHeight: 30, idealHeight: 30, maxHeight: 30, alignment: .center)
                        .background(Color.green)
//                    Text("long long str")
                }.background(Color.red)
                Spacer()
                HStack{
                    Text(NSLocalizedString("Previous Screen:", comment: ""))
                   ShortcutView(model: repo.previous).frame(minWidth: 30, idealWidth: 30, maxWidth: 148, minHeight: 30, idealHeight: 30, maxHeight: 30, alignment: .center)
                    .background(Color.green)
                    //Text("long long str")
                }.background(Color.red)
            }.background(Color.blue)
            Spacer()
            Text(NSLocalizedString("Assign:", comment: ""))
            ScreenList().environmentObject(repo)
            Spacer()
            HStack{
                Text(NSLocalizedString("Hint:", comment: ""))
                MenuButton(
                    label: Text(repo.hintType.value),
                    content: {
                        ForEach(HintType.allCases, id: \.self){ type in
                            Button(type.value){
                                repo.hintType = type
                            }
                        }
                    }
                )
            }
            LaunchAtLogin.Toggle {
                        Text(NSLocalizedString("Launch at login", comment: ""))
                    }
        }.padding(20)
    }
}


struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
