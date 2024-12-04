//
//  ContentView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userManager = UserManager.shared
    
    var body: some View {
        Group {
            if userManager.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}
