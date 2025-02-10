//
//  GenerateQRView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI

struct GenerateQRView: View {
    @State private var toasts: [Toast] = []
    @State private var isToastSystemReady = false
    @State private var isViewReady = false
    @State private var isLoading = false
    @State private var bags: [Bag] = []
    @State private var showAddBagForm = false
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    let apiService = ApiService()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(uiColor: .systemBackground),
                    Color(uiColor: .systemBackground).opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if isViewReady {
                // Reorganizamos la estructura completa
                VStack(spacing: 0) {
                    // Header fijo
                    HeaderView()
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .systemBackground))
                    
                    // Contenido scrolleable en un GeometryReader
                    GeometryReader { geometry in
                        if isLoading {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(0..<3, id: \.self) { _ in
                                        SkeletonBagCard()
                                    }
                                }
                                .padding()
                            }
                        } else if bags.isEmpty {
                            EmptyStateView()
                        } else {
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
                    }
                    
                    // Botón de acción
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
            }
        }
        .sheet(isPresented: $showAddBagForm) {
            NewBagFormView(onSave: addBag)
        }
        .onAppear {
            loadBags()
            // Retrasamos la activación del sistema de toasts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isViewReady = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    isToastSystemReady = true
                }
            }
        }
        .modifier(ToastModifier(isEnabled: isToastSystemReady, toasts: $toasts))
    }
    
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
                    // Simplificamos el manejo de los toasts
                    DispatchQueue.main.async {
                        let toast = Toast { id in
                            SuccessToastView(id)
                        }
                        withAnimation(.easeInOut(duration: 0.3)) {  // Cambiamos .bouncy por .easeInOut
                            self.toasts.append(toast)
                        }
                        // Removemos el toast después de 5 segundos
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.toasts.removeAll { $0.id == toast.id }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        let toast = Toast { id in
                            ErrorToastView(id)
                        }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.toasts.append(toast)
                        }
                    }
                }
                self.isLoading = false
            }
        } else {
            isLoading = false
        }
    }
    
    struct ToastModifier: ViewModifier {
        let isEnabled: Bool
        @Binding var toasts: [Toast]
        
        func body(content: Content) -> some View {
            if isEnabled {
                content.interactiveToast($toasts)
            } else {
                content
            }
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
                    .fixedSize()  // Añadimos esto para evitar redimensionamientos
                
                Text("All Climbing Gear Bags")
                    .font(.title2)
                    .fontWeight(.bold)
                    .fixedSize(horizontal: true, vertical: false)  // Y esto
                
                Text("Create and manage your bags")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: true, vertical: false)  // Y esto
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

struct SkeletonEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: phase - 0.2),
                        .init(color: .white, location: phase),
                        .init(color: .clear, location: phase + 0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

struct SkeletonBagCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 56, height: 56)
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 20)
                    .frame(width: 120)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .frame(width: 100)
            }
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 8, height: 16)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .modifier(SkeletonEffect())
    }
}
