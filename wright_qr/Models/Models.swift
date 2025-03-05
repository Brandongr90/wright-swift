//
//  Models.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import Foundation

struct Bag: Codable, Identifiable {
    let id: String
    let name: String
    let userId: Int
    let assignmentDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "bag_id"
        case name = "bag_name"
        case userId = "user_id"
        case assignmentDate = "assignment_date"
    }
}

struct Item: Identifiable, Codable {
    let id: Int
    let itemDescription, modelName, brand, comment: String
    let serialNumber, conditionO: String
    let inspection: Int
    let inspectionDate, inspectorName, inspectionDate1, expirationDate: String
    let bagID: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case itemDescription = "item_description"
        case modelName = "model_name"
        case brand, comment
        case serialNumber = "serial_number"
        case conditionO = "condition_o"
        case inspection
        case inspectionDate = "inspection_date"
        case inspectorName = "inspector_name"
        case inspectionDate1 = "inspection_date_1"
        case expirationDate = "expiration_date"
        case bagID = "bag_id"
    }
}

struct InspectionHistory: Identifiable, Codable {
    let id: Int
    let itemId: Int
    let inspectionStatus: Int
    let inspectionDate: String
    let inspectorName: String
    let nextInspectionDate: String?
    let comments: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case itemId = "item_id"
        case inspectionStatus = "inspection_status"
        case inspectionDate = "inspection_date"
        case inspectorName = "inspector_name"
        case nextInspectionDate = "next_inspection_date"
        case comments
        case createdAt = "created_at"
    }
}
