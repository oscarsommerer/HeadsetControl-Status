//
//  ContentView.swift
//  HeadsetControl-Status
//
//  Created by Oscar Sommerer on 19.08.22.
//

import SwiftUI

struct StatusbarMenu: View {
    @ObservedObject var store: Store
    
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
                Toggle(isOn: $store.lightsOn) {}
                    .toggleStyle(.switch)
                    .disabled(doesNotHaveCapability(cap: .CAP_LIGHTS))
                
                Text("Lights")
                    .opacity(getOpacityForCapability(.CAP_LIGHTS))
            }
            
            HStack {
                Toggle(isOn: $store.voicePromptsOn) {}
                    .toggleStyle(.switch)
                    .disabled(doesNotHaveCapability(cap: .CAP_VOICE_PROMPTS))
                
                Text("Voice prompts")
                    .opacity(getOpacityForCapability(.CAP_VOICE_PROMPTS))
            }
            
            HStack {
                Toggle(isOn: $store.rotateToMuteOn) {}
                    .toggleStyle(.switch)
                    .disabled(doesNotHaveCapability(cap: .CAP_ROTATE_TO_MUTE))
                
                Text("Rotate to mute")
                    .opacity(getOpacityForCapability(.CAP_ROTATE_TO_MUTE))
            }
            
            Divider()
        }
        .padding(.vertical, 10.0)
        .padding(.horizontal, 15.0)
    
    }
    
    func getOpacityForCapability(_ cap: Capability) -> Double {
        let hasCapability = store.capabilities.contains(cap)
        
        if (!hasCapability) {
            return 0.50
        }
        
        return 1
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
