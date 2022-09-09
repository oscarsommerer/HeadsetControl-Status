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
    
    @State var sideToneLevel: Float = 0.0
    @State var inactiveTimeLevel: Float = 0.0
    @State var inactiveTimeSet: Bool = false
    
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
                                    Text(capabilityToString(cap))
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
                        .opacity(doesNotHaveCapability(cap: .CAP_SIDETONE) ? 0.50 : 1)
                }
                
                Slider(
                    value: $sideToneLevel,
                    in: 0...128) { _ in onSideToneLevelChanged() }
                    .disabled(doesNotHaveCapability(cap: .CAP_SIDETONE))
            }
            
            VStack(alignment: .leading) {
                HStack(alignment: .bottom, spacing: 5.0) {
                    Text("Inactive time")
                        .font(.headline)
                        .opacity(doesNotHaveCapability(cap: .CAP_INACTIVE_TIME) ? 0.50 : 1)
                    
                    Spacer()
                    
                    Toggle("", isOn: $inactiveTimeSet)
                        .onChange(of: inactiveTimeSet, perform: onInactiveTimeToggled)
                        .toggleStyle(.switch)
                        .disabled(doesNotHaveCapability(cap: .CAP_INACTIVE_TIME))
                }
                
                Slider(
                    value: $inactiveTimeLevel,
                    in: 0...128) { _ in onInactiveTimeChanged() }
                    .disabled(doesNotHaveCapability(cap: .CAP_INACTIVE_TIME))
            }
            
            VStack(alignment: .leading) {
                Text("Equalizer preset")
                    .font(.headline)
                    .opacity(doesNotHaveCapability(cap: .CAP_EQUALIZER_PRESET) ? 0.50 : 1)
                
                
                Picker(selection: .constant(0), label: Text("")) {
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
        .onAppear {
            sideToneLevel = store.sideToneState ?? 0.0
            inactiveTimeLevel = store.inactiveTimeState ?? 0.0
            inactiveTimeSet = store.inactiveTimeState != nil
        }
    }
    
    func doesNotHaveCapability(cap: Capability) -> Bool {
        return !store.capabilities.contains(cap)
    }
    
    func onSideToneLevelChanged() {
        do {
            try store.setSideTone(level: sideToneLevel)
        }
        catch {
            // TODO
        }
    }
    
    func onInactiveTimeChanged() {
        do {
            try store.setInactiveTime(time: inactiveTimeLevel)
        }
        catch {
            // TODO
        }
    }
    
    func onInactiveTimeToggled(_ value: Bool) {
        do {
            if value == false {
                try store.setInactiveTime(time: nil)
            }
            else {
                try store.setInactiveTime(time: inactiveTimeLevel)
            }
        }
        catch {
            // TODO
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: Store())
            .frame(width: 500, height: nil, alignment: .center)
    }
}
