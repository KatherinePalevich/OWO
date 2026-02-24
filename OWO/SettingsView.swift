//
//  SettingsView.swift
//  OWO
//
//  Created by Katherine Palevich on 2/23/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("About")) {
                    Text("OWO Kaomoji Generator")
                    Text("Version 1.0")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
