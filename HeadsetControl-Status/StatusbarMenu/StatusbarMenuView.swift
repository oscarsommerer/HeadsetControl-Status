//
//  ContentView.swift
//  HeadsetControl-Status
//
//  Created by Oscar Sommerer on 19.08.22.
//

import SwiftUI

struct StatusbarMenu: View {
    @ObservedObject var store: Store
    
    @State private var advancedSettingsWindowRef: NSWindow? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            HStack(spacing: 10.0) {
                if (!store.headsetDetected) {
                    Circle()
                        .foregroundColor(.red)
                        .opacity(0.50)
                        .frame(width: 10, height: 10)
                    Text("No headset detected")
                        .opacity(0.5) // TODO: Find right color
                }
                else if (store.powerState == BooleanState.Off) {
                    Circle()
                        .foregroundColor(.orange)
                        .opacity(0.50)
                        .frame(width: 10, height: 10)
                    Text("Headset off")
                        .opacity(0.5)
                }
                else {
                    Circle()
                        .foregroundColor(.green)
                        .opacity(0.50)
                        .frame(width: 10, height: 10)
                    Text("Headset connected")
                        .opacity(0.5)
                }
            }
            
            Divider()
            
            BatteryComponent(store: store)
            
            Divider()
            
            HStack {
                Toggle(isOn: booleanStateToBool(state: store.lightsState, action: store.setLights)) {}
                    .toggleStyle(.switch)
                    .disabled(doesNotHaveCapability(cap: .CAP_LIGHTS))
                
                Text("Lights")
                    .opacity(doesNotHaveCapability(cap: .CAP_LIGHTS) ? 0.50 : 1)
            }
            
            HStack {
                Toggle(isOn: booleanStateToBool(state: store.voicePromptsState, action: store.setVoicePrompts)) {}
                    .toggleStyle(.switch)
                    .disabled(doesNotHaveCapability(cap: .CAP_VOICE_PROMPTS))
                
                Text("Voice prompts")
                    .opacity(doesNotHaveCapability(cap: .CAP_VOICE_PROMPTS) ? 0.50 : 1)
            }
            
            HStack {
                Toggle(isOn: booleanStateToBool(state: store.rotateToMuteState, action: store.setRotateToMute)) {}
                    .toggleStyle(.switch)
                    .disabled(doesNotHaveCapability(cap: .CAP_ROTATE_TO_MUTE))
                
                Text("Rotate to mute")
                    .opacity(doesNotHaveCapability(cap: .CAP_ROTATE_TO_MUTE) ? 0.50 : 1)
            }
            
            Divider()
        }
        .padding(.vertical, 10.0)
        .padding(.horizontal, 15.0)
    
    }
    
    func booleanStateToBool(state: BooleanState, action: @escaping (BooleanState) throws -> Void) -> Binding<Bool> {
        return Binding<Bool>(
            get : { state == BooleanState.On },
            set: {
                do {
                    try action($0 ? BooleanState.On : BooleanState.Off)
                }
                catch {
                    // TODO: Handle
                }
            })
    }
    
    func doesNotHaveCapability(cap: Capability) -> Bool {
        return !store.capabilities.contains(cap)
    }
}

struct StatusbarMenu_Previews: PreviewProvider {
    static var previews: some View {
        StatusbarMenu(store: Store())
            .frame(width: 200.0, height: 180)
            
    }
}
