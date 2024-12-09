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
            VStack(spacing: 24) {
                // Header Profile mejorado
                ProfileHeader(
                    name: "\(userManager.currentUser?.name ?? "") \(userManager.currentUser?.last_name ?? "")",
                    role: "Safety Supervisor"
                )
                
                // Vista general mejorada
                DashboardCard(bagsCount: bagsCount, itemsCount: itemsCount)
                
                // Imagen decorativa
                DecorativeImageView()
            }
            .padding(.vertical)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(uiColor: .systemBackground),
                    Color(uiColor: .systemBackground).opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
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

struct ProfileHeader: View {
    let name: String
    let role: String
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(mainColor.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(mainColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text(role)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct DashboardCard: View {
    let bagsCount: Int
    let itemsCount: Int
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Equipment Overview")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Current status of your climbing gear")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(bagsCount + itemsCount)")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(mainColor.opacity(0.1))
                    .foregroundColor(mainColor)
                    .clipShape(Capsule())
            }
            
            HStack(spacing: 16) {
                EnhancedStatCard(
                    title: "Total Bags",
                    value: bagsCount,
                    icon: "duffle.bag",
                    color: mainColor
                )
                
                EnhancedStatCard(
                    title: "Active Items",
                    value: itemsCount,
                    icon: "cube.box.fill",
                    color: mainColor
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
}


struct EnhancedStatCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(value)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(title)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
}

struct DecorativeImageView: View {
    var body: some View {
        VStack {
            Image(systemName: "figure.climbing")
                .font(.system(size: 120))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.04, green: 0.36, blue: 0.25),
                            Color(red: 0.04, green: 0.36, blue: 0.25).opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(40)
                .background(
                    Circle()
                        .fill(Color(red: 0.04, green: 0.36, blue: 0.25).opacity(0.1))
                )
            
            Text("Safe Climbing")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.04, green: 0.36, blue: 0.25))
            
            Text("Equipment Management System")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
}
