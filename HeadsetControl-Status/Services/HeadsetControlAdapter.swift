//
//  HeadsetControlService.swift
//  HeadsetControl-Status
//
//  Created by Oscar Sommerer on 19.08.22.
//

import Foundation
import Subprocess

struct HeadsetControlAdapter {
    private let parser: HeadsetControlDataParser = HeadsetControlDataParser()
    
    func isAnyDeviceDetected() throws -> Bool {
        do {
            let _ = try runCommand(command: nil)
        }
        catch HeadsetControlError.NoDeviceDetectedError {
            return false
        }
        catch {
            throw error
        }
        
        return true
    }
    
    func getDevicePowerState() throws -> BooleanState {
        let raw = try runCommand(command: "-b")
        return parser.parseBatteryStatusForPowerState(raw: raw)
    }
    
    func getCapabilities() throws -> DeviceCapabilities {
        let raw = try runCommand(command: "--capabilities")
        return parser.parseDeviceCapabilities(raw: raw)
    }
    
    func getBatteryLevel() throws -> BatteryLevel {
        let raw = try runCommand(command: "-b")
        return parser.parseBatteryLevel(raw: raw)
    }
    
    func getDeviceType() throws -> String {
        let raw = try runCommand(command: nil, machineReadable: false)
        return try parser.parseDeviceType(raw: raw)
    }
    
    func setLights(state: BooleanState) throws -> Void {
        var command: String = ""
        switch (state) {
        case .On:
            command = "1"
        default:
            command = "0"
        }
        let _ = try runCommand(command: "-l \(command)")
    }
    
    func setVoicePrompts(state: BooleanState) throws -> Void {
        var command: String = ""
        switch (state) {
        case .On:
            command = "1"
        default:
            command = "0"
        }
        let _ = try runCommand(command: "-v \(command)")
    }
    
    func setRotateToMute(state: BooleanState) throws -> Void {
        var command: String = ""
        switch (state) {
        case .On:
            command = "1"
        default:
            command = "0"
        }
        let _ = try runCommand(command: "-r \(command)")
    }
    
    func setSideTone(level: Int?) throws {
        let _ = try runCommand(command: "-s \(level ?? 0)")
    }
    
    func setInactiveTime(time: Int?) throws {
        let _ = try runCommand(command: "-i \(time ?? 0)")
    }
    
    func setEqualizerPreset(preset: Int?) throws {
        let _ = try runCommand(command: "-p \(preset ?? 0)")
    }
    
    private func runCommand(command: String?, machineReadable: Bool = true) throws -> String {
        let input = ["/opt/homebrew/bin/headsetcontrol", machineReadable ? "-c" : nil, command].compactMap { $0 }
        
        do {
            let data = try Shell(input).exec(options: .combined, encoding: .utf8)
            return data.trimmingCharacters(in: ["\n"])
        }
        catch SubprocessError.exitedWithNonZeroStatus(let code, var out) {
            out = out.trimmingCharacters(in: ["\n"])
            
            if (isNoDeviceDetectedError(str: out)) {
                throw HeadsetControlError.NoDeviceDetectedError
            }
            else if(isUnsupportedFunctionError(str: out)) {
                throw HeadsetControlError.UnsupportedFunctionError
            }
            
            throw SubprocessError.exitedWithNonZeroStatus(code, out)
        }
        catch {
            throw error
        }
    }
    
    private func isUnsupportedFunctionError(str: String) -> Bool {
        return str.starts(with: "Error: This headset doesn't support")
    }
    
    private func isNoDeviceDetectedError(str: String) -> Bool {
        return str == "No supported headset found"
    }
}

struct HeadsetControlDataParser {
    func parseDeviceCapabilities(raw: String) -> DeviceCapabilities {
        raw.compactMap {
            return Capability.init(rawValue: $0)
        }
    }
    
    func parseBatteryLevel(raw: String) -> BatteryLevel {
        let level = Int.init(raw)
        
        if (level == nil) {
            return BatteryLevel.Unknown
        }
        
        if (level! == -1) {
            return BatteryLevel.Charging(percentFull: nil)
        }
        else if (level! == -2) {
            return BatteryLevel.Unknown
        }
        
        return BatteryLevel.Draining(percentRemaining: level!)
    }
    
    func parseBatteryStatusForPowerState(raw: String) -> BooleanState {
        let level = Int.init(raw)
        
        if (level == nil || level! == -1) {
            return BooleanState.Unknown
        }
        
        if (level == -2) {
            return BooleanState.Off
        }
        
        return BooleanState.On
    }
    
    func parseDeviceType(raw: String) throws -> String {
        let regex = try NSRegularExpression(pattern: "Found (.*) Headset Device!", options: .caseInsensitive)
        if let match = regex.firstMatch(in: raw, range: NSRange(location: 0, length: raw.utf16.count)) {
            if let typeRange = Range(match.range(at: 1), in: raw) {
                return String(raw[typeRange])
            }
        }
        
        throw HeadsetControlError.ParsingError
    }
}
