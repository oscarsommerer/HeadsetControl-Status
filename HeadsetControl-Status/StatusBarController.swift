//
//  StatusBarController.swift
//  HeadsetControl-Status
//
//  Created by Oscar Sommerer on 19.08.22.
//

import AppKit
import SwiftUI
import Combine

class StatusBarController {
    @ObservedObject var store: Store
    
    private var statusItem: NSStatusItem
    private var mainView: NSView
    private var statusBarButton: NSStatusBarButton?
    private var advancedSettingsWindowRef: NSWindow? = nil
    
    private var batteryLevelCancellable: AnyCancellable? = nil

    init(_ mainView: NSView, @ObservedObject store: Store) {
        self.mainView = mainView
        self.store = store
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarButton = statusItem.button
        
        if statusBarButton != nil {
            statusBarButton!.image = NSImage(systemSymbolName: "headphones.circle.fill", accessibilityDescription: nil)!
                .withSymbolConfiguration(iconConfig(batteryPercentRemaining: nil))
            statusBarButton!.imagePosition = NSControl.ImagePosition.imageLeft
            
            
            let menuItem = NSMenuItem()
            menuItem.view = mainView
            let menu = NSMenu()
            menu.addItem(menuItem)
            
            menu.addItem(MenuItem(title: "Advanced", action: #selector(openAdvancedMenu), keyEquivalent: "A"))
            menu.addItem(MenuItem(title: "Quit", action: #selector(quitApplication), keyEquivalent: "Q"))
            
            statusItem.menu = menu
        }
        
        batteryLevelCancellable = self.store.$batteryLevel.sink { _ in self.updateButton() }
    }
    
    func updateButton() {
        if statusBarButton == nil {
            return
        }
        
        let batteryPercentRemaining: Int?
        switch (store.batteryLevel) {
        case .Draining(let percentRemaining):
            batteryPercentRemaining = percentRemaining
        default:
            batteryPercentRemaining = nil
        }
        
        //statusBarButton!.title = "\(batteryPercentRemaining!)%"
        statusBarButton!.image = NSImage(systemSymbolName: "headphones.circle.fill", accessibilityDescription: nil)!
            .withSymbolConfiguration(iconConfig(batteryPercentRemaining: batteryPercentRemaining))
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
