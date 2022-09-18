//
//  Models.swift
//  HeadsetControl-Status
//
//  Created by Oscar Sommerer on 19.08.22.
//

enum Capability: String.Element {
    case CAP_SIDETONE           = "s"
    case CAP_BATTERY_STATUS     = "b"
    case CAP_NOTIFICATION_SOUND = "n"
    case CAP_LIGHTS             = "l"
    case CAP_INACTIVE_TIME      = "i"
    case CAP_CHATMIX_STATUS     = "m"
    case CAP_VOICE_PROMPTS      = "v"
    case CAP_ROTATE_TO_MUTE     = "r"
    case CAP_EQUALIZER_PRESET   = "p"
    
    func ToString() -> String {
        switch self {
        case .CAP_SIDETONE:
            return "Sidetone"
        case .CAP_BATTERY_STATUS:
            return "Battery status"
        case .CAP_NOTIFICATION_SOUND:
            return "Notification sounds"
        case .CAP_LIGHTS:
            return "Lights"
        case .CAP_INACTIVE_TIME:
            return "Inactive time"
        case .CAP_CHATMIX_STATUS:
            return "Chatmix"
        case .CAP_VOICE_PROMPTS:
            return "Voice prompts"
        case .CAP_ROTATE_TO_MUTE:
            return "Rotate to mute"
        case .CAP_EQUALIZER_PRESET:
            return "Equalizer presets"
        }
    }
}

typealias DeviceCapabilities = [Capability]

enum HeadsetControlError: Error {
    case NoDeviceDetectedError
    case UnsupportedFunctionError
    case ParsingError
}

enum BatteryLevel {
    case Charging(percentFull: Int?)
    case Draining(percentRemaining: Int)
    case Unknown
}

enum BooleanState {
    case On
    case Off
    case Unknown
    
    func AsBool() -> Bool {
        switch self {
        case .On:
            return true
        case .Off:
            return false
        case .Unknown:
            return false
        }
    }
    
    static func FromBool(_ state: Bool?) -> BooleanState {
        switch state {
        case true:
            return BooleanState.On
        case false:
            return BooleanState.Off
        default:
            return BooleanState.Unknown
        }
    }
}
