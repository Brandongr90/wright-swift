//
//  MainTabView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 04/12/24.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var userManager = UserManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            NavigationStack {
                GenerateQRView()
            }
            .tabItem {
                Image(systemName: "qrcode")
                Text("Generate")
            }
            .tag(1)
            
            NavigationStack {
                ScanQRView()
            }
            .tabItem {
                Image(systemName: "qrcode.viewfinder")
                Text("Scan")
            }
            .tag(2)
            
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(3)
        }
        .accentColor(Color.main)
    }
}
