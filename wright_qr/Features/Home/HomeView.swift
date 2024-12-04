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
        ScrollView {
            VStack(spacing: 20) {
                // Header Profile Area
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(userManager.currentUser?.name ?? "") \(userManager.currentUser?.last_name ?? "")")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Safety Supervisor")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    // Profile Image
                    ZStack {
                        Circle()
                            .fill(mainColor.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(mainColor)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Featured Collection Card
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("General Data")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("02")
                            .font(.subheadline)
                            .padding(8)
                            .background(Color.black.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Text("Here you have a general view")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Stats Cards in a horizontal scroll
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            StatCard(
                                title: "Total Climbing Gear Bags",
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
                    }
                    .padding(.top, 10)
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: Color.black.opacity(0.05), radius: 10)
                .padding(.horizontal)
                
                // Quick Actions Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Quick Actions")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        NavigationLink(destination: GenerateQRView()) {
                            ModernQuickActionCard(
                                icon: "qrcode",
                                title: "Generate QR",
                                description: "Create new QR codes and manage existing ones",
                                color: mainColor
                            )
                        }
                        
                        NavigationLink(destination: ScanQRView()) {
                            ModernQuickActionCard(
                                icon: "qrcode.viewfinder",
                                title: "Scan QR",
                                description: "Scan existing codes",
                                color: mainColor
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
        .overlay {
            if isLoading {
                LoadingView(message: "Loading...", mainColor: mainColor)
            }
        }
        .onAppear {
            bagsCountFunc()
            itemsCountFunc()
        }
    }
    
    // Existing functions remain the same
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

// Modern Quick Action Card with more details
struct ModernQuickActionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .padding(12)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Spacer()
        }
        .padding()
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 10)
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
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 160)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
