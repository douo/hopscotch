//
//  ScreenList.swift
//  ScreenJumper
//
//  Created by Tiou Lims on 2020/6/26.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import SwiftUI
import ShortcutRecorder

class ScreenListModel: ObservableObject {
    @Published var data:[ScreenRowVO]
    var screenSize:Int{
        get {
            data.count
        }
        
        set {
            let size = max(NSScreen.screens.count,newValue)
            while(size < self.data.count){
                let ele = self.data.removeLast()
                let defaults = NSUserDefaultsController.shared
                defaults.setValue(nil,forKeyPath: ele.shortcut.keyPath)
            }
            while(size > self.data.count){
                let screenName:String?
                let index = self.data.count
                if index < NSScreen.screens.count{
                    screenName = NSScreen.screens[index].localizedName
                }else{
                    screenName = nil
                }
                self.data.append(ScreenRowVO(idx: index, screenName: screenName,shortcut:ShortcutModel(focusType: .Next, keyPath:"")))
            }
            ScreenListModel.updateSize(size)
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
    
    init() {
        let size = ScreenListModel.restoreSize()
        data = []
        self.screenSize = size
    }
    
}


struct ScreenList: View {
    @EnvironmentObject var repo:ShortcutRepository
    
    var body: some View {
        List{
            ForEach(repo.assigns.enumerated().map {(idx, ele) in
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
