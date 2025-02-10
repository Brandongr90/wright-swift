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
    @State private var showingSupportSheet = false
    
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
                        
                        Text("BETA 1.0.0")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(mainColor)
                            .clipShape(Capsule())
                    }
                    .padding(.vertical)
                    
                    // Sections
                    VStack(spacing: 24) {
                        // Inventories Section
                        SectionContainer(title: "Inventories") {
                            // My stores (disabled)
                            DisabledMenuRow(title: "My stores", icon: "building.2", iconColor: .gray, badge: "Coming soon")
                            
                            // Support con alerta
                            MenuRow(title: "Support", icon: "questionmark.circle", iconColor: mainColor) {
                                showingSupportSheet = true
                            }
                        }
                        
                        // Preferences Section
                        SectionContainer(title: "Preferences") {
                            // Push Notifications (disabled)
                            DisabledMenuRow(title: "Push notifications", icon: "bell", iconColor: .gray)
                            
                            // Face ID (disabled)
                            DisabledMenuRow(title: "Face ID", icon: "faceid", iconColor: .gray)
                            
                            // PIN Code (disabled)
                            DisabledMenuRow(title: "PIN Code", icon: "lock", iconColor: .gray)
                            
                            // Logout (enabled)
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
            .sheet(isPresented: $showingSupportSheet) {
                SupportContactSheet()
            }
        }
    }
}

struct SupportContactSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    private let supportEmail = "techvisioncomp@gmail.com"
    private let supportPhone = "+524151006711"
    @State private var copiedText: String?
    @State private var showCopiedAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "headset.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(mainColor)
                    
                    Text("Contact Support")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose how you'd like to reach us")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                VStack(spacing: 16) {
                    ContactButton(
                        title: "Send Message",
                        icon: "message.fill",
                        color: .green
                    ) {
                        openMessages()
                    }
                    
                    ContactButton(
                        title: "Send Email",
                        icon: "envelope.fill",
                        color: .blue
                    ) {
                        openEmail()
                    }
                    
                    VStack(spacing: 12) {
                        CopyButton(
                            text: supportEmail,
                            icon: "envelope",
                            label: "Copy Email"
                        ) {
                            copyToClipboard(supportEmail)
                        }
                        
                        CopyButton(
                            text: supportPhone,
                            icon: "phone",
                            label: "Copy Phone"
                        ) {
                            copyToClipboard(supportPhone)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if let copiedText = copiedText {
                    CopiedToast(text: copiedText)
                        .transition(.move(edge: .bottom))
                }
            }
        }
    }
    
    private func openMessages() {
        if let url = URL(string: "sms:\(supportPhone)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openEmail() {
        if let url = URL(string: "mailto:\(supportEmail)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        copiedText = text
        withAnimation {
            showCopiedAlert = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                copiedText = nil
            }
        }
    }
}

struct ContactButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct CopyButton: View {
    let text: String
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                
                Text(text)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct CopiedToast: View {
    let text: String
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("\(text) copied!")
                    .font(.subheadline)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(Capsule())
            .shadow(radius: 5)
            .padding(.bottom, 32)
        }
    }
}

struct DisabledMenuRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    var badge: String? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            Text(title)
                .foregroundColor(.gray)
            
            Spacer()
            
            if let badge = badge {
                Text(badge)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.gray)
                    .clipShape(Capsule())
            } else {
                Text("Coming soon")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        
        Divider()
            .padding(.leading, 56)
    }
}

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
