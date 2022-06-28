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
                    ShortcutView(model: repo.next)
                        .fixedSize()
                }
                Spacer()
                HStack{
                    Text(NSLocalizedString("Previous Screen:", comment: ""))
                    ShortcutView(model: repo.previous)
                        .fixedSize()
                }
            }
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
