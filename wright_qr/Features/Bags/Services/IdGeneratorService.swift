//
//  IdGeneratorService.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import Foundation

class IdGeneratorService {
    private var usedIds: Set<String> = []

    func generateUniqueId(prefix: String = "ITEM") -> String {
        let date = Date(timeIntervalSince1970: Date().timeIntervalSince1970)
        let timestamp = date.formatted(.dateTime.year().month().day().hour().minute().second())
        let randomStr = UUID().uuidString.prefix(8).uppercased()
        let newId = "\(prefix)-\(timestamp)-\(randomStr)"

        usedIds.insert(newId)
        return newId
    }

    func idExists(_ id: String) -> Bool {
        return usedIds.contains(id)
    }
}
