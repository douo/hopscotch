//
//  ScreenList.swift
//  ScreenJumper
//
//  Created by Tiou Lims on 2020/6/26.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import SwiftUI

class ScreenListModel: ObservableObject {
    @Published var data:[RowModel]
    var screenSize:Int{
        get {
            data.count
        }
        
        set {
            let size = max(NSScreen.screens.count,newValue)
            while(size < self.data.count){
                let ele = self.data.removeLast()
                let defaults = NSUserDefaultsController.shared
                defaults.setValue(nil,forKeyPath: ele.key)
            }
            while(size > self.data.count){
                let screenName:String?
                let index = self.data.count
                if index < NSScreen.screens.count{
                    screenName = NSScreen.screens[index].localizedName
                }else{
                    screenName = nil
                }
                self.data.append(RowModel(idx: index, screenName: screenName))
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
    
    @EnvironmentObject var model:ScreenListModel
    
    var body: some View {
        List{
            ForEach(model.data,id: \.idx){ row in
                ScreenRow(model: row)
            }
            HStack(alignment: .bottom){
                Spacer()
                Button(action:{
                    self.model.screenSize += 1
                }){
                    Text("+")
                }
                Button(action:{
                    self.model.screenSize -= 1
                }){
                    Text("-")
                }.disabled(model.screenSize == NSScreen.screens.count)
            }
        }
    }
}

struct ScreenList_Previews: PreviewProvider {
    static var previews: some View {
        ScreenList()
            .environmentObject(ScreenListModel())
    }
}
