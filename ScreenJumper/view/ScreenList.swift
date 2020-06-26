//
//  ScreenList.swift
//  ScreenJumper
//
//  Created by Tiou Lims on 2020/6/26.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import SwiftUI

class ScreenListModel {
    var data:[RowModel]
    var screenSize:Int{
        get {
            data.count
        }
        
        set {
            let count = max(NSScreen.screens.count,newValue)
            while(count < self.data.count){
                self.data.removeLast()
            }
            while(count > self.data.count){
                let screenName:String?
                let index = self.data.count
                if index < NSScreen.screens.count{
                    screenName = NSScreen.screens[index].localizedName
                }else{
                    screenName = nil
                }
                self.data.append(RowModel(idx: index, screenName: screenName))
            }
        }
    }
    
    init(_ screenSize:Int) {
         data = []
         for idx in 0..<NSScreen.screens.count {
             data.append(RowModel(idx: idx, screenName:  NSScreen.screens[idx].localizedName))
         }
         self.screenSize = screenSize
     }
     
}


struct ScreenList: View {

    let model:ScreenListModel
    
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
                }
            }
            
        }
    }
}

struct ScreenList_Previews: PreviewProvider {
    static var previews: some View {
        ScreenList(model: ScreenListModel(4))
    }
}
