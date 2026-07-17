//
//  MosaicApp.swift
//  Mosaic
//
//  Created by Jordan Joseph on 16/7/2026.
//

import SwiftUI
import FirebaseCore

@main
struct MosaicApp: App {
    
    init() {
        FirebaseApp.configure()
    }
 
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
