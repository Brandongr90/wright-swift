//
//  CustomTextFielda.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 24/11/24.
//

import SwiftUI

struct CustomTextFielda: View {
    let title: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .sentences
    var isSecure: Bool = false
    let focused: Bool
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(mainColor)
                
                if isSecure {
                    SecureField(title, text: $text)
                        .autocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                } else {
                    TextField(title, text: $text)
                        .autocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focused ? mainColor : Color.clear, lineWidth: 2)
            )
        }
    }
}
