//
//  StatusBarController.swift
//  HeadsetControl-Status
//
//  Created by Oscar Sommerer on 19.08.22.
//

import AppKit
import SwiftUI

class StatusBarController {
    @ObservedObject var store: Store
    
    private var statusItem: NSStatusItem
    private var mainView: NSView
    private var statusButtonIcon: NSImage!
    private var advancedSettingsWindowRef: NSWindow? = nil

    init(_ mainView: NSView, store: Store) {
        self.mainView = mainView
        self.store = store
        
        let batteryPercentRemaining: Int?
        switch (store.batteryLevel) {
        case .Draining(let percentRemaining):
            batteryPercentRemaining = percentRemaining
        default:
            batteryPercentRemaining = nil
        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusButtonIcon = NSImage(systemSymbolName: "headphones.circle.fill", accessibilityDescription: nil)!
            .withSymbolConfiguration(iconConfig(batteryPercentRemaining: batteryPercentRemaining))
        
        if let statusBarButton = statusItem.button {
            statusBarButton.image = statusButtonIcon
            statusBarButton.imagePosition = NSControl.ImagePosition.imageLeft
            if batteryPercentRemaining != nil {
                statusBarButton.title = "\(batteryPercentRemaining!)%"
            }
            
            let menuItem = NSMenuItem()
            menuItem.view = mainView
            let menu = NSMenu()
            menu.addItem(menuItem)
            
            menu.addItem(MenuItem(title: "Advanced", action: #selector(openAdvancedMenu), keyEquivalent: "A"))
            menu.addItem(MenuItem(title: "Quit", action: #selector(quitApplication), keyEquivalent: "Q"))
            
            
            statusItem.menu = menu
        }
    }
    
    func iconConfig(batteryPercentRemaining: Int?) -> NSImage.SymbolConfiguration! {
        let config = NSImage.SymbolConfiguration()
            .withScale(scale: .large)
        
        if batteryPercentRemaining != nil {
            if batteryPercentRemaining! < 10 {
                return config!
                    .withColor(NSColor.red)
            }
            else if batteryPercentRemaining! < 25 {
                return config!
                    .withColor(NSColor.yellow)
            }
        }
        
        return config
    }
    
    @objc func openAdvancedMenu() {
        if (advancedSettingsWindowRef != nil) {
            advancedSettingsWindowRef?.close()
        }
        
        advancedSettingsWindowRef = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 420),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView, .utilityWindow],
            backing: .buffered, defer: false)
        
        advancedSettingsWindowRef!.isReleasedWhenClosed = false
        advancedSettingsWindowRef!.contentView = NSHostingView(rootView: SettingsView(store: store))
        advancedSettingsWindowRef!.makeKeyAndOrderFront(nil)
    }
    
    @objc func quitApplication() {
        NSApp.terminate(self)
    }
    
    private func MenuItem(title: String, action: Selector?, keyEquivalent: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.target = self
        return item
    }
}

extension NSImage.SymbolConfiguration {
    func withScale(scale: NSImage.SymbolScale) -> NSImage.SymbolConfiguration! {
        let config = NSImage.SymbolConfiguration(scale: scale)
        return applying(config)
    }
    
    func withColor(_ color: NSColor) -> NSImage.SymbolConfiguration! {
        let config = NSImage.SymbolConfiguration(hierarchicalColor: color)
        return applying(config)
    }
}
