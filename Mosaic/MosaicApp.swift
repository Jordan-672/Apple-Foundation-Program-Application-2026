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
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("Missing Firebase clientID — check GoogleService-Info.plist")
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
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
