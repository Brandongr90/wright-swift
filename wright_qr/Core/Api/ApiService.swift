//
//  ApiService.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError
    case decodingError
}

class ApiService {
    // let baseUrl = "https://qr-generator-services.onrender.com"
    let baseUrl = APIConfig.baseURL
    
    // GET BAGS
    func getBags(userId: Int, completion: @escaping ([Bag]) -> Void) {
        guard let url = URL(string: "\(baseUrl)/bags/\(userId)") else {
            print("Invalid URL")
            completion([])
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching bags: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            guard let data = data else {
                print("No data received.")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            do {
                let bags = try JSONDecoder().decode([Bag].self, from: data)
                DispatchQueue.main.async {
                    completion(bags)
                }
            } catch {
                print("Error decoding bags: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }
    
    
    // GET ITEMS BY ID
    func getItemsByBag(for bagId: String, completion: @escaping ([Item]) -> Void) {
        let urlString = "\(baseUrl)/items_by_bag_id/\(bagId)"
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            // print("JSON:", String(data: data, encoding: .utf8) ?? "Error decoding data")
            
            let items = try? JSONDecoder().decode([Item].self, from: data)
            DispatchQueue.main.async {
                completion(items ?? [])
            }
        }.resume()
    }
    
    // POST BAG
    func postBag(_ bag: Bag, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseUrl)/bags"),
              let jsonData = try? JSONEncoder().encode(bag) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }.resume()
    }
    
    // POST ITEM
    func postItem(_ item: Item, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseUrl)/items"),
              let jsonData = try? JSONEncoder().encode(item) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }.resume()
    }
    
    // COUNT BAGS
    func getBagsCount(endpoint: String, userId: Int) async throws -> Int {
        guard let url = URL(string: "\(baseUrl)/\(endpoint)/count/\(userId)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(CountResponse.self, from: data)
        return response.count
    }
    
    struct CountResponse: Codable {
        let count: Int
    }
    
    // UPDATE ITEM
    func updateItem(_ item: Item, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseUrl)/items/\(item.id)") else {
            completion(false)
            return
        }
        
        let itemData: [String: Any] = [
            "item_description": item.itemDescription,
            "model_name": item.modelName,
            "brand": item.brand,
            "comment": item.comment,
            "serial_number": item.serialNumber,
            "condition_o": item.conditionO,
            "inspection": item.inspection,
            "inspection_date": item.inspectionDate,
            "inspector_name": item.inspectorName,
            "inspection_date_1": item.inspectionDate1,
            "expiration_date": item.expirationDate,
            "bag_id": item.bagID
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: itemData)
        } catch {
            print("Error encoding item: \(error)")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }
    
    // Delete Items and Bags
    func delete(_ id: String, direction: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseUrl)/\(direction)/\(id)") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    completion(httpResponse.statusCode == 200)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }
    
    // Get Item By Id
    func getItemById(_ id: Int, completion: @escaping (Item?) -> Void) {
        guard let url = URL(string: "\(baseUrl)/items/\(id)") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    completion(nil)
                    return
                }
                guard let data = data else {
                    completion(nil)
                    return
                }
                do {
                    let item = try JSONDecoder().decode(Item.self, from: data)
                    completion(item)
                } catch {
                    completion(nil)
                }
            }
        }.resume()
    }
}
