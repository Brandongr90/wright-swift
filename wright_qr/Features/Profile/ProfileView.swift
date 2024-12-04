//
//  ProfileView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 04/12/24.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var userManager = UserManager.shared
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    @State private var isPushNotificationsEnabled = true
    @State private var isFaceIDEnabled = true
    @State private var showingPINSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Avatar
                        Circle()
                            .fill(mainColor.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .foregroundColor(mainColor)
                            )
                        
                        // User Info
                        VStack(spacing: 4) {
                            Text("\(userManager.currentUser?.name ?? "") \(userManager.currentUser?.last_name ?? "")")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text(userManager.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Edit Profile Button
                        Button(action: {
                            // Acción para editar perfil
                        }) {
                            Text("BETA 1.0.0")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                                .background(mainColor)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical)
                    
                    // Sections
                    VStack(spacing: 24) {
                        // Inventories Section
                        SectionContainer(title: "Inventories") {
                            MenuRow(title: "My stores", icon: "building.2", iconColor: mainColor, badge: "2") {
                                // Acción para My stores
                            }
                            
                            MenuRow(title: "Support", icon: "questionmark.circle", iconColor: mainColor) {
                                // Acción para Support
                            }
                        }
                        
                        // Preferences Section
                        SectionContainer(title: "Preferences") {
                            // Push Notifications Toggle
                            ToggleRow(
                                title: "Push notifications",
                                icon: "bell",
                                iconColor: mainColor,
                                isOn: $isPushNotificationsEnabled
                            )
                            
                            // Face ID Toggle
                            ToggleRow(
                                title: "Face ID",
                                icon: "faceid",
                                iconColor: mainColor,
                                isOn: $isFaceIDEnabled
                            )
                            
                            // PIN Code
                            MenuRow(title: "PIN Code", icon: "lock", iconColor: mainColor) {
                                showingPINSettings = true
                            }
                            
                            // Logout
                            MenuRow(
                                title: "Logout",
                                icon: "rectangle.portrait.and.arrow.right",
                                iconColor: .red,
                                showDivider: false
                            ) {
                                userManager.logout()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}

// Helper Views
struct SectionContainer<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.leading, 8)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct MenuRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    var badge: String? = nil
    var showDivider: Bool = true
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .clipShape(Capsule())
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .background(Color(uiColor: .systemBackground))
        
        if showDivider {
            Divider()
                .padding(.leading, 56)
        }
    }
}

struct ToggleRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.main)
        }
        .padding()
        
        Divider()
            .padding(.leading, 56)
    }
}
