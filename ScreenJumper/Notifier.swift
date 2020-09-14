//
//  Notifier.swift
//  ScreenJumper
//
//  Created by tiou on 2020/9/14.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import Foundation
import Cocoa
let SFNotifier = ScreenFocusNotifier()

class ScreenFocusNotifier {
    let windowController:NSWindowController
    var window:NSWindow?
    init(){
        windowController = NSWindowController()
    }
    func hellow(screen:NSScreen){
        let windowSize = NSSize(width: 480, height: 480)
        print(screen)
        let screenSize = screen.frame.size
        let rect = NSMakeRect(screenSize.width/2 - windowSize.width/2,
                              screenSize.height/2 - windowSize.height/2,
                              windowSize.width,
                              windowSize.height)
        if(window != nil){
            window?.close()
        }
        let w = NSWindow(contentRect: rect,
                         styleMask: [.miniaturizable, .closable, .resizable, .titled],
                         backing: .buffered,
                         defer: false,
                         screen: screen)
        w.isOpaque = false
        w.titlebarAppearsTransparent = true
        w.titleVisibility = .hidden
        w.backgroundColor = NSColor.clear
        w.hasShadow = true
        w.level = .floating
        w.ignoresMouseEvents = true
        let iv = NSImageView(frame: NSMakeRect(200,200,100,100))
        iv.image = NSImage(named: "ic_status_bar")
        w.contentView?.addSubview(iv)
        w.makeKeyAndOrderFront(nil)
        windowController.window = w
        window = w
    }
}
