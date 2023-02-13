//
//  NetworkManager.swift
//  AcronymsApp
//
//  Created by SUSHANT KUMAR on 10/02/23.
//

import Foundation

typealias APICompletionBlock = ((Data?, URLResponse?, Error?) -> Void)
typealias APIResultBlock<T: Codable> = (Result<T, CustomError>) -> Void

protocol URLSessionProtocol {
    func dataTask(urlRequest: URLRequest, completionHandler: @escaping APICompletionBlock) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    func dataTask(urlRequest: URLRequest, completionHandler: @escaping APICompletionBlock) -> URLSessionDataTaskProtocol {
        dataTask(with: urlRequest, completionHandler: completionHandler)
    }
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

enum ErrorCode: Int {
    case noResultFound = 202
    var value: Int {
        self.rawValue
    }
}

struct CustomError: Error {
    var errorCode: Int
    var errorMsg: String
    init(_ errorMsg: String = .somethingWentWrongMsg, errorCode: Int = 999) {
        self.errorMsg = errorMsg
        self.errorCode = errorCode
    }
}

final class NetworkManager {
    private var session: URLSessionProtocol
    
    init(_ session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    /// `NetworkCallable` Protocol confirmance to process the API request for provided URL as `String?`
    /// `processAPIRequest` is a generic method which accepts the `Codable` types
    /// - parameters: 1. Requested URL as string `String?`
    /// - parameters: 2. `T.Type` as codable
    /// - parameters: 3. `APIResultBlock<T>?`
    func processAPIRequest<T: Codable>(with urlString: String?, _ type: T.Type, _ completion: APIResultBlock<T>?) {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            completion?(.failure(CustomError(.invalidURLMsg)))
            return
        }
        session.dataTask(urlRequest: URLRequest(url: url)) { data, response, error in
            guard let data = data,
                  let dataModels = try? JSONDecoder().decode([T].self, from: data) else {
                completion?(.failure(CustomError()))
                return
            }
            guard let model = dataModels.first else {
                completion?(.failure(CustomError(.noRecordsFoundMsg,
                                                 errorCode: ErrorCode.noResultFound.value)))
                return
            }
            completion?(.success(model))
        }.resume()
    }
}
