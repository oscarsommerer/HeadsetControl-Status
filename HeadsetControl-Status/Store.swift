//
//  Store.swift
//  HeadsetControl-Status
//
//  Created by Oscar Sommerer on 20.08.22.
//

import Combine
import SwiftUI
import Defaults

class Store: ObservableObject {
    private var previousHeadsetDetectedState: Bool = false
    
    @Published private(set) var headsetDetected: Bool = false
    @Published private(set) var powerState: BooleanState = BooleanState.Unknown
    @Published private(set) var deviceType: String? = nil
    
    @Published private(set) var capabilities: [Capability] = []
    
    @Published private(set) var batteryLevel: BatteryLevel = BatteryLevel.Unknown
    @Published private(set) var lightsState: BooleanState = BooleanState.Unknown
    @Published private(set) var voicePromptsState: BooleanState = BooleanState.Unknown
    @Published private(set) var rotateToMuteState: BooleanState = BooleanState.Unknown
    @Published private(set) var sideToneState: Int? = nil
    @Published private(set) var inactiveTimeState: Int? = nil
    @Published private(set) var equalizerPresetState: Int? = nil
    
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
        Defaults[.lightsState] = ToBool(state)
    }
    
    func setVoicePrompts(state: BooleanState) throws {
        if (!capabilities.contains(.CAP_VOICE_PROMPTS)) {
            throw HeadsetControlError.UnsupportedFunctionError
        }
        
        try adapter!.setVoicePrompts(state: state)
        voicePromptsState = state
        Defaults[.voicePromptsState] = ToBool(state)
    }
    
    func setRotateToMute(state: BooleanState) throws {
        if (!capabilities.contains(.CAP_ROTATE_TO_MUTE)) {
            throw HeadsetControlError.UnsupportedFunctionError
        }
        
        try adapter!.setRotateToMute(state: state)
        rotateToMuteState = state
        Defaults[.rotateToMuteState] = ToBool(state)
    }
    
    private func update() {
        if (adapter == nil) {
            return
        }
        
        do {
            headsetDetected = try self.adapter!.isAnyDeviceDetected()
            if (!headsetDetected) {
                return resetState()
            }
            
            capabilities = try self.adapter!.getCapabilities()
            
            if (headsetDetected != previousHeadsetDetectedState) {
                try loadPersistedState()
            }
            
            powerState = try self.adapter!.getDevicePowerState()
            deviceType = try self.adapter!.getDeviceType()
            batteryLevel = try self.adapter!.getBatteryLevel()
        }
        catch {
            print(error)
        }
        
        previousHeadsetDetectedState = headsetDetected
    }
    
    private func resetState() {
        self.headsetDetected = false
        self.powerState = BooleanState.Unknown
        self.capabilities = []
        self.batteryLevel = BatteryLevel.Unknown
        self.lightsState = BooleanState.Unknown
        self.voicePromptsState = BooleanState.Unknown
        self.rotateToMuteState = BooleanState.Unknown
        self.sideToneState = nil
        self.inactiveTimeState = nil
        self.equalizerPresetState = nil
    }
    
    public func loadPersistedState() throws {
        if (capabilities.contains(.CAP_LIGHTS)) { try setLights(state: ToBooleanState(Defaults[.lightsState])) }
        if (capabilities.contains(.CAP_VOICE_PROMPTS)) { try setVoicePrompts(state: ToBooleanState(Defaults[.voicePromptsState])) }
        if (capabilities.contains(.CAP_ROTATE_TO_MUTE)) { try setRotateToMute(state: ToBooleanState(Defaults[.rotateToMuteState])) }
    }
}

extension Defaults.Keys {
    static let lightsState = Key<Bool?>("lightsState", default: nil)
    static let voicePromptsState = Key<Bool?>("voicePromptsState", default: nil)
    static let rotateToMuteState = Key<Bool?>("rotateToMuteState", default: nil)
    
    static let sideToneState = Key<Int?>("sideToneState", default: nil)
    static let inactiveTimeState = Key<Int?>("inactiveTimeState", default: nil)
    static let equalizerPresetState = Key<Int?>("equalizerPresetState", default: nil)
}
