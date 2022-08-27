//
//  Store.swift
//  HeadsetControl-Status
//
//  Created by Oscar Sommerer on 20.08.22.
//

import Combine
import SwiftUI

class Store: ObservableObject {
    @Published private(set) var headsetDetected: Bool = false
    @Published private(set) var powerState: BooleanState = BooleanState.Unknown
    @Published private(set) var deviceType: String? = nil
    
    @Published private(set) var capabilities: [Capability] = []
    
    @Published private(set) var batteryLevel: BatteryLevel = BatteryLevel.Unknown
    @Published private(set) var lightsState: BooleanState = BooleanState.Unknown
    @Published private(set) var voicePromptsState: BooleanState = BooleanState.Unknown
    @Published private(set) var rotateToMuteState: BooleanState = BooleanState.Unknown
    
    private let adapter: HeadsetControlAdapter?
    
    init(_ cliAdapter: HeadsetControlAdapter? = nil) {
        adapter = cliAdapter
        
        // TODO: Remove timer if no supported USB Device is connected & wait for USB Device connected signal
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in self.update() }
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func setLights(state: BooleanState) throws {
        if (!capabilities.contains(.CAP_LIGHTS)) {
            throw HeadsetControlError.UnsupportedFunctionError
        }
        
        try adapter!.setLights(state: state)
        lightsState = state
    }
    
    func setVoicePrompts(state: BooleanState) throws {
        if (!capabilities.contains(.CAP_VOICE_PROMPTS)) {
            throw HeadsetControlError.UnsupportedFunctionError
        }
        
        try adapter!.setVoicePrompts(state: state)
        voicePromptsState = state
    }
    
    func setRotateToMute(state: BooleanState) throws {
        if (!capabilities.contains(.CAP_ROTATE_TO_MUTE )) {
            throw HeadsetControlError.UnsupportedFunctionError
        }
        
        try adapter!.setRotateToMute(state: state)
        rotateToMuteState = state
    }
    
    private func update() {
        if (adapter == nil) {
            return
        }
        
        do {
            self.headsetDetected = try self.adapter!.isAnyDeviceDetected()
            if (!headsetDetected) {
                return resetState()
            }
            
            self.powerState = try self.adapter!.getDevicePowerState()
            self.deviceType = try self.adapter!.getDeviceType()
            self.capabilities = try self.adapter!.getCapabilities()
            self.batteryLevel = try self.adapter!.getBatteryLevel()
        }
        catch {
            print(error)
        }
    }
    
    private func resetState() {
        self.headsetDetected = false
        self.powerState = BooleanState.Unknown
        self.capabilities = []
        self.batteryLevel = BatteryLevel.Unknown
        self.lightsState = BooleanState.Unknown
        self.voicePromptsState = BooleanState.Unknown
        self.rotateToMuteState = BooleanState.Unknown
    }
}
