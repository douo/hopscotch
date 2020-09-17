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
    
    var fillColor:NSColor = .clear
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        postsBoundsChangedNotifications = true
        let center = NotificationCenter.default
        center.addObserver(forName: NSView.frameDidChangeNotification, object: self, queue: nil, using: {n in
            self.rippleLayer()?.maximumRadius = max(self.frame.width,self.frame.height)
        })
        wantsLayer = true
    }
    
    override var frame: NSRect{
        get{
            return super.frame
        }
        
        set(v){
            super.frame = v
            let layer = rippleLayer()
            layer?.bounds = self.bounds
            layer?.maximumRadius = max(self.bounds.width,self.bounds.height)/2.0
        }
    }
    
    override func makeBackingLayer() -> CALayer {
        let s = super.makeBackingLayer()
        s.masksToBounds = true
        let layer = SJRippleLayer()
        layer.fillColor = .init(red: 0, green: 0, blue: 0, alpha:0.12)
        layer.opacity = 0
        s.addSublayer(layer)
        return s
    }
    
    func rippleLayer() -> SJRippleLayer?{
        if layer is SJRippleLayer {
            return layer as? SJRippleLayer
        }
        if let result = layer?.sublayers?.first(where: { $0 is SJRippleLayer }) {
            return result as? SJRippleLayer
        }else{
            return nil
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        fillColor.set()
        dirtyRect.fill()
    }
}

