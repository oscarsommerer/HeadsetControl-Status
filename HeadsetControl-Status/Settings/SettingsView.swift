//
//  SettingsView.swift
//  HeadsetControl-Status
//
//  Created by Oscar Sommerer on 21.08.22.
//

import SwiftUI
import LaunchAtLogin

struct SettingsView: View {
    @ObservedObject var store: Store
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15.0) {
            ScrollView {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 7.0) {
                        Text("Detected headset type:")
                        
                        Text("Device capabilities:")
                    }
                    
                    VStack(alignment: .leading, spacing: 7.0) {
                        if (store.headsetDetected) {
                            Text(store.deviceType!)
                            
                            VStack(alignment: .leading) {
                                ForEach(store.capabilities, id: \.self) { cap in
                                    Text(cap.ToString())
                                }
                            }
                        } else {
                            Image(systemName: "questionmark.circle")
                            
                            Image(systemName: "questionmark.circle")
                        }
                    }
                    
                    Spacer()
                }
            }
            Divider()
            
            VStack(alignment: .leading) {
                HStack(alignment: .bottom, spacing: 5.0) {
                    Text("Sidetone")
                        .font(.headline)
                        .opacity(getOpacityForCapability(.CAP_SIDETONE))
                }
                
                Slider(value: $store.sideToneLevel, in: 0...128)
                    .disabled(doesNotHaveCapability(cap: .CAP_SIDETONE))
            }
            
            VStack(alignment: .leading) {
                HStack(alignment: .bottom, spacing: 5.0) {
                    Text("Inactive time")
                        .font(.headline)
                        .opacity(getOpacityForCapability(.CAP_INACTIVE_TIME))
                    
                    Spacer()
                    
                    Toggle("", isOn: $store.inactiveTimeOn)
                        .toggleStyle(.switch)
                        .disabled(doesNotHaveCapability(cap: .CAP_INACTIVE_TIME))
                }
                
                Slider(value: $store.inactiveTime, in: 0...128)
                    .disabled(doesNotHaveCapability(cap: .CAP_INACTIVE_TIME))
            }
            
            VStack(alignment: .leading) {
                Text("Equalizer preset")
                    .font(.headline)
                    .opacity(getOpacityForCapability(.CAP_EQUALIZER_PRESET))
                
                
                Picker(selection: $store.equalizerPreset, label: Text("")) {
                    Text("Default").tag(0)
                    Text("1").tag(1)
                    Text("2").tag(2)
                    Text("3").tag(3)
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .disabled(doesNotHaveCapability(cap: .CAP_EQUALIZER_PRESET))
            }
            
            Divider()
            
            HStack {
                Text("Launch at Login")
                
                Spacer()
                
                LaunchAtLogin.Toggle()
                    .labelsHidden()
                    .toggleStyle(.switch)
            }
        }
        .padding(20.0)
    }
    
    func doesNotHaveCapability(cap: Capability) -> Bool {
        return !store.capabilities.contains(cap)
    }
    
    func getOpacityForCapability(_ cap: Capability) -> Double {
        let hasCapability = store.capabilities.contains(cap)
        
        if (!hasCapability) {
            return 0.50
        }
        
        return 1
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: Store())
            .frame(width: 500, height: nil, alignment: .center)
    }
}
