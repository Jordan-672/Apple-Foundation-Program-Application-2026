//
//  MosaicApp.swift
//  Mosaic
//
//  Created by Jordan Joseph on 16/7/2026.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct MosaicApp: App {

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
