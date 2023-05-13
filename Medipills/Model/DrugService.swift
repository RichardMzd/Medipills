//
//  DrugService.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 10/04/2023.
//

import Foundation

class DrugsService {
    
    static let shared = DrugsService()
    private init() {}
    
    private var task: URLSessionDataTask?
    
    private var session = URLSession(configuration: .default)
    init(session: URLSession) {
        self.session = session
    }
    
    func getDrugInfo(drugName: String, completion: @escaping (Result<[Drugs], ErrorAPI>) -> Void) {
            
            var request = URLRequest(url: URL(string: "https://drug-info-and-price-history.p.rapidapi.com/1/druginfo?drug=\(drugName)")!)
            var headers = request.allHTTPHeaderFields ?? [String:String]()
            headers["x-rapidapi-host"] = "drug-info-and-price-history.p.rapidapi.com"
            headers["x-rapidapi-key"] = "2d7c23af45msh07c02b88e450484p18205bjsn0d52627e5b59"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                DispatchQueue.main.async {
                    guard let data = data, error == nil else {
                        completion(.failure(.server))
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                        completion(.failure(.network))
                        return
                    }
                    
                    do {
                        let responseJSON = try JSONDecoder().decode([Drugs].self, from: data)
                        completion(.success(responseJSON))
                    } catch {
                        print("Failed to decode response: \(error.localizedDescription)")
                        completion(.failure(.decoding))
                    }
                }
            })
            dataTask.resume()
        }

    
//    func getDrugInfo(drugName: String, completion: @escaping (Result<[Drugs], ErrorAPI>) -> Void) {
//
//        let request = NSMutableURLRequest(url: NSURL(string: "https://drug-info-and-price-history.p.rapidapi.com/1/druginfo?drug=\(drugName)")! as URL)
//        request.httpMethod = "GET"
//        let headers = [
//            "x-rapidapi-host": "drug-info-and-price-history.p.rapidapi.com",
//            "x-rapidapi-key": "2d7c23af45msh07c02b88e450484p18205bjsn0d52627e5b59"
//        ]
//        request.allHTTPHeaderFields = headers
//
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//            DispatchQueue.main.async {
//                guard let data = data, error == nil else {
//                    completion(.failure(.server))
//                    return
//                }
//
//                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//                    completion(.failure(.network))
//                    return
//                }
//
//                do {
//                    let responseJSON = try JSONDecoder().decode([Drugs].self, from: data)
//                    completion(.success(responseJSON))
//                } catch {
//                    print("Failed to decode response: \(error.localizedDescription)")
//                    completion(.failure(.decoding))
//                }
//            }
//        })
//        dataTask.resume()
//    }
}
