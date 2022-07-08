//
//  ScreenList.swift
//  ScreenJumper
//
//  Created by Tiou Lims on 2020/6/26.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import SwiftUI
import ShortcutRecorder

struct ScreenList: View {
    @EnvironmentObject var repo:ShortcutRepository
    
    var body: some View {
        List{
            ForEach(repo.assigns.enumerated().map { (idx, ele) -> ScreenRowVO in
                let screenName:String?
                if idx < NSScreen.screens.count{
                    screenName = NSScreen.screens[idx].localizedName
                }else{
                    screenName = nil
                }
                return ScreenRowVO(idx:idx,screenName:screenName,shortcut: ele)
            }, id: \.idx){ row in
                ScreenRow(model: row)
            }
            HStack(alignment: .bottom){
                Spacer()
                Button(action:{
                    self.repo.assignSize += 1
                }){
                    Text("+")
                }
                Button(action:{
                    self.repo.assignSize -= 1
                }){
                    Text("-")
                }.disabled( self.repo.assignSize == NSScreen.screens.count)
            }
        }
    }
}

struct ScreenList_Previews: PreviewProvider {
    static var previews: some View {
        ScreenList()
            .environmentObject(ShortcutRepository.shared)
    }
}
