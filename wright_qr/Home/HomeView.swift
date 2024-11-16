//
//  HomeView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI

struct HomeView: View {
    // Color scheme
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo/Header Area
                    VStack(spacing: 12) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 80))
                            .foregroundColor(mainColor)
                        
                        Text("QR Manager")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Organize and track your items easily")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Main Actions
                    VStack(spacing: 16) {
                        NavigationLink(destination: GenerateQRView()) {
                            ActionButton(
                                icon: "plus.square.fill",
                                title: "Bags | Generate QR",
                                subtitle: "Create a new QR code for your items",
                                color: mainColor
                            ).multilineTextAlignment(.leading)
                        }
                        
                        NavigationLink(destination: ScanQRView()) {
                            ActionButton(
                                icon: "qrcode.viewfinder",
                                title: "Scan QR",
                                subtitle: "Scan an existing QR code",
                                color: mainColor
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recent Activity Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<3) { _ in
                                    RecentActivityCard()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Add settings action here
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(mainColor)
                    }
                }
            }
        }
    }
}

// Custom Action Button View
struct ActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Recent Activity Card View
struct RecentActivityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "bag.fill")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text("Bag Name")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("3 items")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("2 min ago")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 140)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
}
