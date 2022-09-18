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
    @Published private(set) var headsetDetected: Bool = false
    @Published private(set) var powerState: BooleanState = BooleanState.Unknown
    @Published private(set) var batteryLevel: BatteryLevel = BatteryLevel.Unknown
    @Published private(set) var deviceType: String? = nil
    @Published private(set) var capabilities: [Capability] = []
    
    @Published var lightsOn: Bool = false
    @Published var voicePromptsOn: Bool = false
    @Published var rotateToMuteOn: Bool = false
    @Published var inactiveTimeOn: Bool = false

    @Published var sideToneLevel: Double = 0.0
    @Published var inactiveTime: Double = 0.0
    @Published var equalizerPreset: Int = 0
    
    private var _previousHeadsetDetectedState: Bool = false
    private let _adapter: HeadsetControlAdapter?
    
    private var cancellabels: [AnyCancellable] = []
    
    init(_ cliAdapter: HeadsetControlAdapter? = nil) {
        _adapter = cliAdapter
        
        // TODO: Remove timer if no supported USB Device is connected & wait for USB Device connected signal
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in self.update() }
        RunLoop.main.add(timer, forMode: .common)
        
        $lightsOn
            .print("lightsOn")
            .sink(receiveValue: { value in self.setLights(state: BooleanState.FromBool(value)) })
            .store(in: &cancellabels)
        
        $voicePromptsOn
            .sink(receiveValue: { value in self.setVoicePrompts(state: BooleanState.FromBool(value)) })
            .store(in: &cancellabels)
        
        $rotateToMuteOn
            .sink(receiveValue: { value in self.setRotateToMute(state: BooleanState.FromBool(value)) })
            .store(in: &cancellabels)
        
        $inactiveTimeOn
            .sink(receiveValue: { value in self.setInactiveTimeOn(on: value) })
            .store(in: &cancellabels)
        
        $sideToneLevel
            .sink(receiveValue: { value in self.setSideTone(level: value) })
            .store(in: &cancellabels)
        
        $inactiveTime
            .sink(receiveValue: { value in self.setInactiveTime(time: value) })
            .store(in: &cancellabels)
        
        $equalizerPreset
            .sink(receiveValue: { value in self.setEqualizerPreset(preset: value) })
            .store(in: &cancellabels)
    }
    
    private func setLights(state: BooleanState) {
        if (!capabilities.contains(.CAP_LIGHTS)) {
            return
        }
        
        do {
            try _adapter!.setLights(state: state)
            Defaults[.lightsOn] = state.AsBool()
        }
        catch {
            // TODO
        }
    }
    
    private func setVoicePrompts(state: BooleanState) {
        if (!capabilities.contains(.CAP_VOICE_PROMPTS)) {
            return
        }
        
        do {
            try _adapter!.setVoicePrompts(state: state)
            Defaults[.voicePromptsOn] = state.AsBool()
        }
        catch {
            // TODO
        }
    }
    
    private func setInactiveTimeOn(on: Bool) {
        if (!capabilities.contains(.CAP_INACTIVE_TIME)) {
            return
        }
        
        let value = on ? Int(self.inactiveTime) : nil
        
        do {
            try _adapter!.setInactiveTime(time: value)
            Defaults[.inactiveTimeOn] = on
        }
        catch {
            // TODO
        }
    }
    
    private func setRotateToMute(state: BooleanState) {
        if (!capabilities.contains(.CAP_ROTATE_TO_MUTE)) {
            return
        }
        
        do {
            try _adapter!.setRotateToMute(state: state)
            Defaults[.rotateToMuteOn] = state.AsBool()
        }
        catch {
            // TODO
        }
    }
    
    private func setSideTone(level: Double) {
        if (!capabilities.contains(.CAP_SIDETONE)) {
            return
        }
        
        do {
            try _adapter!.setSideTone(level: Int(level))
            Defaults[.sideToneLevel] = level
        }
        catch {
            // TODO
        }
    }
    
    private func setInactiveTime(time: Double) {
        if (!capabilities.contains(.CAP_INACTIVE_TIME)) {
            return
        }
        
        if (!self.inactiveTimeOn) {
            self.inactiveTimeOn = true
        }
        
        do {
            try _adapter!.setInactiveTime(time: Int(time))
            Defaults[.inactiveTime] = time
        }
        catch {
            // TODO
        }
    }
    
    private func setEqualizerPreset(preset: Int) {
        if (!capabilities.contains(.CAP_EQUALIZER_PRESET)) {
            return
        }
        
        do {
            try _adapter!.setEqualizerPreset(preset: preset)
            Defaults[.equalizerPreset] = preset
        }
        catch {
            // TODO
        }
    }
    
    private func update() {
        if (_adapter == nil) {
            return
        }
        
        do {
            headsetDetected = try self._adapter!.isAnyDeviceDetected()
            if (!headsetDetected) {
                return resetState()
            }
            
            capabilities = try self._adapter!.getCapabilities()
            
            if (headsetDetected.toNative() != _previousHeadsetDetectedState) {
                restorePersistedState()
            }
            
            powerState = try self._adapter!.getDevicePowerState()
            deviceType = try self._adapter!.getDeviceType()
            batteryLevel = try self._adapter!.getBatteryLevel()
        }
        catch {
            // TODO
            print(error)
        }
        
        _previousHeadsetDetectedState = headsetDetected
    }
    
    private func resetState() {
        self.headsetDetected = false
        self.powerState = BooleanState.Unknown
        self.capabilities = []
        self.batteryLevel = BatteryLevel.Unknown
        self.lightsOn = false
        self.voicePromptsOn = false
        self.rotateToMuteOn = false
        self.inactiveTimeOn = false
        self.sideToneLevel = 0.0
        self.inactiveTime = 0.0
        self.equalizerPreset = 0
    }
    
    public func restorePersistedState() {
        if (capabilities.contains(.CAP_LIGHTS)) { self.lightsOn = Defaults[.lightsOn] }
        if (capabilities.contains(.CAP_VOICE_PROMPTS)) { self.voicePromptsOn = Defaults[.voicePromptsOn] }
        if (capabilities.contains(.CAP_ROTATE_TO_MUTE)) { self.rotateToMuteOn = Defaults[.rotateToMuteOn] }
        if (capabilities.contains(.CAP_SIDETONE)) { self.sideToneLevel = Defaults[.sideToneLevel] }
        if (capabilities.contains(.CAP_INACTIVE_TIME)) { self.inactiveTimeOn = Defaults[.inactiveTimeOn] }
        if (capabilities.contains(.CAP_INACTIVE_TIME)) { self.inactiveTime = Defaults[.inactiveTime] }
        if (capabilities.contains(.CAP_EQUALIZER_PRESET)) { self.equalizerPreset = Defaults[.equalizerPreset] }
    }
}

extension Defaults.Keys {
    static let lightsOn = Key<Bool>("lightsOn", default: false)
    static let voicePromptsOn = Key<Bool>("voicePromptsOn", default: false)
    static let rotateToMuteOn = Key<Bool>("rotateToMuteOn", default: true)
    static let inactiveTimeOn = Key<Bool>("inactiveTimeOn", default: false)
    
    static let sideToneLevel = Key<Double>("sideToneLevel", default: 0.0)
    static let inactiveTime = Key<Double>("inactiveTime", default: 0.0)
    static let equalizerPreset = Key<Int>("equalizerPreset", default: 0)
}
