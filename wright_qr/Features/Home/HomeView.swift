//
//  HomeView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var userManager = UserManager.shared
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    @State private var selectedTab = 0
    @State private var isLoading = false
    @State private var bagsCount: Int = 0
    @State private var itemsCount: Int = 0
    let apiService = ApiService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Header Profile
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Welcome back,")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("\(userManager.currentUser?.name ?? "") \(userManager.currentUser?.last_name ?? "")")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            Circle()
                                .fill(mainColor.opacity(0.1))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "person.crop.circle.fill")
                                        .foregroundColor(mainColor)
                                        .font(.title2)
                                )
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Quick Actions Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            NavigationLink(destination: GenerateQRView()) {
                                QuickActionCard(
                                    icon: "plus.square.fill",
                                    title: "Generate QR",
                                    color: mainColor
                                )
                            }
                            
                            NavigationLink(destination: ScanQRView()) {
                                QuickActionCard(
                                    icon: "qrcode.viewfinder",
                                    title: "Scan QR",
                                    color: mainColor
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Stats Overview
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Overview")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            HStack(spacing: 16) {
                                StatCard(
                                    title: "Total Bags",
                                    value: bagsCount,
                                    icon: "bag.fill",
                                    color: .blue
                                )
                                
                                StatCard(
                                    title: "Active Items",
                                    value: itemsCount,
                                    icon: "shippingbox.fill",
                                    color: .green
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                // Loading
                if isLoading {
                    LoadingView(message: "Loading...", mainColor: mainColor)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {}) {
                            Label("Settings", systemImage: "gear")
                        }
                        Button(action: { userManager.logout() }) {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(mainColor)
                    }
                }
            }
        }
        .onAppear {
            bagsCountFunc()
            itemsCountFunc()
        }
    }
    
    // Functions
    func bagsCountFunc() {
        isLoading = true
        let userId = UserManager.shared.currentUser?.id ?? 0
        Task {
            do {
                bagsCount = try await apiService.getBagsCount(endpoint: "bags",userId: userId)
                isLoading = false
            } catch {
                print("Error getting bags count: \(error)")
            }
        }
    }
    
    func itemsCountFunc() {
        isLoading = true
        let userId = UserManager.shared.currentUser?.id ?? 0
        Task {
            do {
                itemsCount = try await apiService.getBagsCount(endpoint: "items", userId: userId)
                isLoading = false
            } catch {
                print("Error getting bags count: \(error)")
            }
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                )
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct StatCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(color)
                    )
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            
            Text(String(value))
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
