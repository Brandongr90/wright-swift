//
//  LoginView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 24/11/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToHome = false
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 12) {
                            Image("logoWT")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 190, height: 190)
                            
                            Text("Welcome Back")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Sign in to continue")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                        
                        // Login Form
                        VStack(spacing: 24) {
                            CustomTextFielda(
                                title: "Email Address",
                                text: $email,
                                icon: "envelope",
                                keyboardType: .emailAddress,
                                autocapitalization: .none,
                                focused: focusedField == .email
                            )
                            .focused($focusedField, equals: .email)
                            
                            CustomTextFielda(
                                title: "Password",
                                text: $password,
                                icon: "lock",
                                isSecure: true,
                                focused: focusedField == .password
                            )
                            .focused($focusedField, equals: .password)
                            
                            HStack {
                                Spacer()
                                Button(action: {
                                    // Forgot password logic
                                }) {
                                    Text("Forgot Password?")
                                        .font(.footnote)
                                        .foregroundColor(mainColor)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Login Button
                        VStack(spacing: 16) {
                            Button(action: handleLogin) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "arrow.right")
                                            .font(.title2)
                                    }
                                    Text("Sign In")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(mainColor)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: mainColor.opacity(0.3), radius: 5, x: 0, y: 2)
                            }
                            .disabled(isLoading)
                            
                            NavigationLink(
                                destination: HomeView(),
                                isActive: $navigateToHome,
                                label: { EmptyView() }
                            )
                            .hidden()
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please complete all fields"
            showAlert = true
            return
        }
        
        isLoading = true
        AuthApiService.shared.login(email: email, password: password) { result in
            isLoading = false
            switch result {
            case .success:
                navigateToHome = true
            case .failure(let error):
                handleAuthError(error)
            }
        }
    }
    
    private func handleAuthError(_ error: AuthError) {
        switch error {
        case .invalidURL:
            alertMessage = "The server URL is invalid. Please contact support."
        case .networkError(let message):
            alertMessage = "Network error: \(message)"
        case .noData:
            alertMessage = "No data received from the server. Please try again later."
        case .decodingError:
            alertMessage = "Failed to decode server response. Please contact support."
        case .serverError(let message):
            alertMessage = "Server error: \(message)"
        }
        showAlert = true
    }
}


//#Preview {
//    LoginView()
//}
