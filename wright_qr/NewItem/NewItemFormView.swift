//
//  NewItemFormView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI

struct NewItemFormView: View {
    @State private var itemName: String = ""
    var bag: Bag
    var onSave: (Item) -> Void
    
    @State private var itemDescription: String = ""
    @State private var modelName: String = ""
    @State private var brand: String = ""
    @State private var comment: String = ""
    @State private var serialNumber: String = ""
    @State private var conditionO: String = ""
    @State private var inspection: Int = 0
    @State private var inspectionDate: String = ""
    @State private var inspectorName: String = ""
    @State private var inspectionDate1: String = ""
    @State private var expirationDate: String = ""
    
    let apiService = ApiService()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Description", text: $itemDescription)
                    TextField("Model Name", text: $modelName)
                    TextField("Brand", text: $brand)
                    TextField("Comment", text: $comment)
                }
                
                Section(header: Text("Specifications")) {
                    TextField("Serial Number", text: $serialNumber)
                    TextField("Condition", text: $conditionO)
                    Stepper(value: $inspection, in: 0...10) {
                        Text("Inspection: \(inspection)")
                    }
                }
                
                Section(header: Text("Inspection Details")) {
                    TextField("Inspection Date", text: $inspectionDate)
                    TextField("Inspector Name", text: $inspectorName)
                    TextField("Inspection Date 1", text: $inspectionDate1)
                    TextField("Expiration Date", text: $expirationDate)
                }
                
                Button(action: {
                    addItem()
                }) {
                    Text("Add Item")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func addItem() {
        let newItem = Item(
            id: 0, // Se ignora porque el servidor lo genera
            itemDescription: itemDescription,
            modelName: modelName,
            brand: brand,
            comment: comment,
            serialNumber: serialNumber,
            conditionO: conditionO,
            inspection: inspection,
            inspectionDate: inspectionDate,
            inspectorName: inspectorName,
            inspectionDate1: inspectionDate1,
            expirationDate: expirationDate,
            bagID: String(bag.id) // Se pasa como el `bag_id` relacionado
        )
        
        apiService.postItem(newItem) { success in
            if success {
                print("Item Added Successfully")
                onSave(newItem)
            } else {
                print("Failed to add item")
            }
        }
    }
}
