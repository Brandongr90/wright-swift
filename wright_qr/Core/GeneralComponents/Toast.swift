//
//  Toast.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 30/11/24.
//

import SwiftUI

// El componente Toast
struct Toast: View {
    let message: String
    let isSuccess: Bool
    let mainColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundColor(isSuccess ? mainColor : .red)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// El ViewModifier
struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let isSuccess: Bool
    let mainColor: Color
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    Spacer()
                    Toast(message: message, isSuccess: isSuccess, mainColor: mainColor)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .padding(.bottom, 90)
                .animation(.spring(), value: isShowing)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
            }
        }
    }
}

// La extensión de View
extension View {
    func toast(isShowing: Binding<Bool>, message: String, isSuccess: Bool = true, mainColor: Color) -> some View {
        modifier(ToastModifier(isShowing: isShowing, message: message, isSuccess: isSuccess, mainColor: mainColor))
    }
}
