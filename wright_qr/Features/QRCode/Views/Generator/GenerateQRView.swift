//
//  GenerateQRView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI

struct GenerateQRView: View {
    @State private var toasts: [Toast] = []
    @State private var isLoading = false
    @State private var bags: [Bag] = []
    @State private var showAddBagForm = false
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    let apiService = ApiService()
    
    var body: some View {
        ZStack {
            // Fondo con gradiente sutil
            LinearGradient(
                colors: [
                    Color(uiColor: .systemBackground),
                    Color(uiColor: .systemBackground).opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header mejorado
                HeaderView()
                    .padding(.top, 20)
                
                if bags.isEmpty {
                    EmptyStateView()
                } else {
                    // Lista de bolsas mejorada
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(bags) { bag in
                                NavigationLink(destination: BagDetailsView(bag: bag)) {
                                    EnhancedBagCard(bag: bag)
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                // Botón de acción mejorado
                VStack(spacing: 12) {
                    ActionButton(
                        title: "Add New Bag",
                        icon: "plus.circle.fill",
                        color: mainColor
                    ) {
                        showAddBagForm = true
                    }
                }
                .padding()
                .background(
                    Rectangle()
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: -5)
                )
            }
            
            if isLoading {
                LoadingView(
                    message: "Loading bags, the first time it might take a while",
                    mainColor: mainColor
                )
            }
        }
        .sheet(isPresented: $showAddBagForm) {
            NewBagFormView(onSave: addBag)
        }
        .onAppear { loadBags() }
        .interactiveToast($toasts)
    }
    
    // Get All Bags
    func loadBags() {
        isLoading = true
        if let userId = UserManager.shared.currentUser?.id {
            apiService.getBags(userId: userId) { loadedBags in
                self.bags = loadedBags
                self.isLoading = false
            }
        } else {
            isLoading = false
        }
    }
    
    // Add New Bag
    func addBag(bagName: String) {
        isLoading = true
        if let userId = UserManager.shared.currentUser?.id {
            let newBag = Bag(
                id: UUID().uuidString,
                name: bagName,
                userId: userId
            )
            apiService.postBag(newBag) { success in
                if success {
                    self.loadBags()
                    withAnimation(.bouncy) {
                        let toast = Toast { id in
                            SuccessToastView(id)
                        }
                        self.toasts.append(toast)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            if let index = self.toasts.firstIndex(where: { $0.id == toast.id }) {
                                withAnimation(.bouncy) {
                                    self.toasts.remove(at: index)
                                }
                            }
                        }
                    }
                } else {
                    withAnimation(.bouncy) {
                        let toast = Toast { id in
                            ErrorToastView(id)
                        }
                        self.toasts.append(toast)
                    }
                }
                self.isLoading = false
            }
        } else {
            isLoading = false
        }
    }
    
    struct HeaderView: View {
        private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
        
        var body: some View {
            VStack(spacing: 16) {
                Circle()
                    .fill(mainColor.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "figure.climbing")
                            .font(.system(size: 36))
                            .foregroundColor(mainColor)
                    )
                
                Text("All Climbing Gear Bags")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Create and manage your bags")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
        }
    }
    
    struct EmptyStateView: View {
        var body: some View {
            VStack(spacing: 16) {
                Image(systemName: "duffle.bag")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                
                Text("No Bags Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Start by adding your first climbing gear bag")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxHeight: .infinity)
        }
    }
    
    struct EnhancedBagCard: View {
        let bag: Bag
        private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
        
        var body: some View {
            HStack(spacing: 16) {
                // Icono mejorado
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(mainColor.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "duffle.bag")
                        .font(.system(size: 24))
                        .foregroundColor(mainColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(bag.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 12))
                        Text("Tap to view details")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    struct ActionButton: View {
        let title: String
        let icon: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color)
                        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
        }
    }
    
    // CUSTOM TOASTS
    // Success
    @ViewBuilder
    func SuccessToastView(_ id: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text("Bolsa creada exitosamente")
                .font(.callout)
            
            Spacer(minLength: 0)
            
            Button {
                $toasts.delete(id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
            }
        }
        .foregroundStyle(Color.primary)
        .padding(.vertical, 12)
        .padding(.leading, 15)
        .padding(.trailing, 10)
        .background {
            Capsule()
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 3, x: -1, y: -3)
                .shadow(color: .black.opacity(0.06), radius: 2, x: 1, y: 3)
        }
        .padding(.horizontal, 15)
    }
    
    // Error
    @ViewBuilder
    func ErrorToastView(_ id: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
            
            Text("Error al crear la bolsa")
                .font(.callout)
            
            Spacer(minLength: 0)
            
            Button {
                $toasts.delete(id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
            }
        }
        .foregroundStyle(Color.primary)
        .padding(.vertical, 12)
        .padding(.leading, 15)
        .padding(.trailing, 10)
        .background {
            Capsule()
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 3, x: -1, y: -3)
                .shadow(color: .black.opacity(0.06), radius: 2, x: 1, y: 3)
        }
        .padding(.horizontal, 15)
    }
}

// Custom Bag Card View
struct BagCard: View {
    let bag: Bag
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "duffle.bag")
                .font(.system(size: 24))
                .foregroundColor(mainColor)
                .frame(width: 50, height: 50)
                .background(mainColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(bag.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Tap to view details")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
