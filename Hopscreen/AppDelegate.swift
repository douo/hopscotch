//
//  AppDelegate.swift
//  Demo
//
//  Created by Tiou Lims on 2020/6/24.
//  Copyright © 2020 Tiou Lims. All rights reserved.
//

import Cocoa
import SwiftUI
import ShortcutRecorder
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menu: NSMenu?
    
    var statusItem: NSStatusItem?
    
    @IBAction func openPerference(_ sender: Any){
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: .init(stringLiteral: "preferencesID")) as? ViewController else { return }
        let window = NSWindow(contentViewController: vc)
        window.makeKeyAndOrderFront(nil)
    }
    
    /**
     * 重置用户配置
     */
    private func clearData(){
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //clearData()
        ShortcutRepository.shared.register()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        statusItem?.button?.image = NSImage.init(named: "ic_status_bar")
        if let menu = menu {
            statusItem?.menu = menu
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}
