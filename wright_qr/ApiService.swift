//
//  ApiService.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import Foundation

class ApiService {
    let baseUrl = "http://localhost:3000"
    
    // GET BAGS
    func getBags(completion: @escaping ([Bag]) -> Void) {
        guard let url = URL(string: "\(baseUrl)/bags") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            let bags = try? JSONDecoder().decode([Bag].self, from: data)
            DispatchQueue.main.async {
                completion(bags ?? [])
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
}
