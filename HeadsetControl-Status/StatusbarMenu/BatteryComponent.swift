//
//  BatteryComponentt.swift
//  HeadsetControl-Status
//
//  Created by Oscar Sommerer on 20.08.22.
//

import SwiftUI

struct BatteryComponent: View {
    @ObservedObject var store: Store
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("Battery")
                    .font(.headline)
                
                switch store.batteryLevel {
                case .Unknown, .Draining:
                    Text("Not charging")
                        .font(.footnote)
                case .Charging:
                    Text("Charging")
                        .font(.footnote)
                }
            }
            
            Spacer()
            
            switch store.batteryLevel {
            case .Unknown:
                Image(systemName: "questionmark.circle")
            case .Charging(let percent):
                if (percent == nil) {
                    Image(systemName: "questionmark.circle")
                }
                else {
                    Text("\(percent!)" + "%")
                        .font(.callout)
                }
            case .Draining(let percent):
                Text("\(percent)" + "%")
                    .font(.callout)
            }
        }
        .frame(height: 27.0, alignment: .top)
    }
}

struct BatteryComponent_Previews: PreviewProvider {
    static var previews: some View {
        BatteryComponent(store: Store())
    }
}
