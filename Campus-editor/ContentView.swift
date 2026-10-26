//
//  ContentView.swift
//  Campus-editor
//
//  Created by Кулнаме on 29.09.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("TimeFlow працює!")
                    .padding()
                    .onAppear {
                        runTimeFlowScenario()
        }
    }
}
