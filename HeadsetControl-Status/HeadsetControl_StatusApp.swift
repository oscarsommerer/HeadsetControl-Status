//
//  HeadsetControl_StatusApp.swift
//  HeadsetControl-Status
//
//  Created by Oscar Sommerer on 19.08.22.
//

import SwiftUI

@main
struct HeadsetControl_StatusApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBar: StatusBarController?
    
    let store = Store(HeadsetControlAdapter())

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let popupView = NSHostingView(rootView: StatusbarMenu(store: store))
        popupView.frame = NSRect(x: 0, y: 0, width: 200, height: 160)
        statusBar = StatusBarController(popupView, store: store)
        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(onWake), name: NSWorkspace.didWakeNotification, object: nil)
    }

func applicationWillTerminate(_ aNotification: Notification) {
         // Insert code here to tear down your application
    }
    
    @objc func onWake(_ n: NSNotification) { store.restorePersistedState() }
}
