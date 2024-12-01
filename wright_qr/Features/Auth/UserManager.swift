//
//  UserManager.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 30/11/24.
//

import SwiftUI

class UserManager: ObservableObject {
    static let shared = UserManager()
    @Published var currentUser: User?
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let userId = "userId"
        static let userName = "userName"
        static let userLastName = "userLastName"
        static let userEmail = "userEmail"
    }
    
    init() {
        loadUserFromDefaults()
    }
    
    func saveUser(_ user: User) {
        userDefaults.set(user.id, forKey: Keys.userId)
        userDefaults.set(user.name, forKey: Keys.userName)
        userDefaults.set(user.last_name, forKey: Keys.userLastName)
        userDefaults.set(user.email, forKey: Keys.userEmail)
        currentUser = user
    }
    
    func loadUserFromDefaults() {
        guard
            let id = userDefaults.object(forKey: Keys.userId) as? Int,
            let name = userDefaults.string(forKey: Keys.userName),
            let lastName = userDefaults.string(forKey: Keys.userLastName),
            let email = userDefaults.string(forKey: Keys.userEmail)
        else { return }
        
        currentUser = User(id: id, name: name, last_name: lastName, email: email)
    }
    
    func logout() {
        userDefaults.removeObject(forKey: Keys.userId)
        userDefaults.removeObject(forKey: Keys.userName)
        userDefaults.removeObject(forKey: Keys.userLastName)
        userDefaults.removeObject(forKey: Keys.userEmail)
        currentUser = nil
    }
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
}
