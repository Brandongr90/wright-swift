//
//  AuthApiService.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 24/11/24.
//

import SwiftUI
import Foundation

enum AuthError: Error {
    case invalidURL
    case networkError(String)
    case noData
    case decodingError
    case serverError(String)
}

struct AuthResponse: Decodable {
    let success: Bool
    let message: String
    let user: User?
}

struct User: Decodable {
    let id: Int
    let name: String
    let last_name: String
    let email: String
}

class AuthApiService {
    static let shared = AuthApiService()
    private init() {}
    
    func login(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        // guard let url = URL(string: "http://localhost:3000/auth") else {
        guard let url = URL(string: "https://qr-generator-services.onrender.com/auth") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error.localizedDescription)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                    if authResponse.success, let user = authResponse.user {
                        completion(.success(user))
                    } else {
                        completion(.failure(.serverError(authResponse.message)))
                    }
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }
        task.resume()
    }
}
