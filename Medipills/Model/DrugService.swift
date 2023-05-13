//
//  DrugService.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 10/04/2023.
//

import Foundation
import Alamofire

class DrugsService {
    
    static let shared = DrugsService()
    private var task: DataRequest?
    private let session: DrugsProtocol

    init(session: DrugsProtocol = DrugSession()) {
        self.session = session
    }

    func getDrugInfo(drugName: String, completion: @escaping (Result<[Drugs], ErrorAPI>) -> Void) {

        let headers: HTTPHeaders = [
            "x-rapidapi-host": "drug-info-and-price-history.p.rapidapi.com",
            "x-rapidapi-key": "2d7c23af45msh07c02b88e450484p18205bjsn0d52627e5b59"
        ]

        let url = URL(string: "https://drug-info-and-price-history.p.rapidapi.com/1/druginfo?drug=\(drugName)")!

        task = session.request(url: url, headers: headers) { dataResponse in

            switch dataResponse.result {
            case .success(let data):
                do {
                    let responseJSON = try JSONDecoder().decode([Drugs].self, from: data)
                    completion(.success(responseJSON))
                    print(responseJSON)
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                    completion(.failure(.decoding))
                }

            case .failure(let error):
                if error.isExplicitlyCancelledError {
                    // ignore cancellation errors
                    return
                }
                print("Error in network request: \(error.localizedDescription)")
                completion(.failure(.network))
            }
        }
    }
}
