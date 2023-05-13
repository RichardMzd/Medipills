//
//  DrugSession.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 30/04/2023.
//

import Foundation
import Alamofire

protocol DrugsProtocol {
    func request(url: URL, headers: HTTPHeaders, callBack: @escaping (AFDataResponse<Data>) -> Void) -> DataRequest
}

class DrugSession: DrugsProtocol {
    func request(url: URL, headers: HTTPHeaders, callBack: @escaping (AFDataResponse<Data>) -> Void) -> DataRequest {
        return AF.request(url, headers: headers).validate().responseData { dataResponse in
            callBack(dataResponse)
        }
    }
}
