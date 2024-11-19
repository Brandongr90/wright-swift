//
//  GenerateQRView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI

struct GenerateQRView: View {
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
    }
    
    // Get All Bags
    func loadBags() {
        isLoading = true
        apiService.getBags { loadedBags in
            self.bags = loadedBags
            self.isLoading = false
        }
    }
    
    // Add New Bag
    func addBag(bagName: String) {
        isLoading = true
        let newBag = Bag(id: UUID().uuidString, name: bagName)
        apiService.postBag(newBag) { success in
            if success {
                loadBags()
                self.isLoading = false
            }
        }
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

#Preview {
    GenerateQRView()
}
