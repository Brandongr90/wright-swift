//
//  GenerateQRView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI

struct GenerateQRView: View {
    /// Toast Handler
    @State private var toasts: [Toast] = []
    
    // Color scheme
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    @State private var isLoading = false
    @State private var bags: [Bag] = []
    @State private var showAddBagForm = false
    
    let apiService = ApiService()
    
    var body: some View {
        ZStack {
            // Background
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            ZStack {
                VStack(spacing: 24) {
                    // Header Area
                    VStack(spacing: 12) {
                        Image(systemName: "bag.fill.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(mainColor)
                        
                        Text("All Bags")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Create and manage the bags")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Bags List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(bags) { bag in
                                NavigationLink(destination: BagDetailsView(bag: bag)) {
                                    BagCard(bag: bag)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Add New Bag Button
                    Button(action: {
                        showAddBagForm = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Add New Bag")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(mainColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: mainColor.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            // Loading
            if isLoading {
                LoadingView(message: "Loading bags, the first time it might take a while", mainColor: mainColor)
            }
        }
        .sheet(isPresented: $showAddBagForm) {
            NewBagFormView(onSave: addBag)
        }
        // onAppear loads when the view charge
        .onAppear {
            loadBags()
        }
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
            Image(systemName: "bag.fill")
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
