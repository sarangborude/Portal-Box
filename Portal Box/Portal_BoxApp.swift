//
//  Portal_BoxApp.swift
//  Portal Box
//
//  Created by Sarang Borude on 8/10/24.
//

import SwiftUI

@main
struct Portal_BoxApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
