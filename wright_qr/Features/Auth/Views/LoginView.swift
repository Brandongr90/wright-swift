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
    
    @State private var showingSupportSheet = false
    
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
                        VStack(spacing: 12) {
                            Image("icontv")
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
                                    showingSupportSheet = true
                                }) {
                                    Text("Don't have an account?")
                                        .font(.footnote)
                                        .foregroundColor(mainColor)
                                }
                            }
                            .sheet(isPresented: $showingSupportSheet) {
                                SupportContactSheet()
                            }
                        }
                        .padding(.horizontal)
                        
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
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
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
            case .success(let user):
                UserManager.shared.saveUser(user)
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
    
    struct SupportContactSheet: View {
        @Environment(\.dismiss) private var dismiss
        private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
        private let supportEmail = "techvisioncomp@gmail.com"
        private let supportPhone = "+524151006711"
        @State private var copiedText: String?
        
        var body: some View {
            NavigationView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 60))
                            .foregroundColor(mainColor)
                        
                        Text("Need an Account?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Contact us to set up your account")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    copiedText = nil
                }
            }
        }
    }
}


//#Preview {
//    LoginView()
//}
