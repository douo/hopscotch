//
//  NotifierView.swift
//  ScreenJumper
//
//  Created by tiou on 2020/9/14.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import Foundation
import Cocoa
class NotifierView : NSView{
    
    var fillColor:NSColor = .blue
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        fillColor.set()
        dirtyRect.fill()
    }
}
