//
//  NetworkManager.swift
//  AcronymsApp
//
//  Created by SUSHANT KUMAR on 10/02/23.
//

import Foundation

typealias APICompletionBlock = ((Data?, URLResponse?, Error?) -> Void)
typealias APIResultBlock<T: Codable> = (Result<T, CustomError>) -> Void

protocol NetworkCallable {
    func processAPIRequest<T: Codable>(with urlString: String?, _ type: T.Type, _ completion: APIResultBlock<T>?)
}

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
    init(_ errorMsg: String = "Something went wrong. Please try again.", errorCode: Int = 999) {
        self.errorMsg = errorMsg
        self.errorCode = errorCode
    }
}

final class NetworkManager: NetworkCallable {
    private var session: URLSessionProtocol
    
    init(_ session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func processAPIRequest<T: Codable>(with urlString: String?, _ type: T.Type, _ completion: APIResultBlock<T>?) {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            completion?(.failure(CustomError("URL is invalid.")))
            return
        }
        session.dataTask(urlRequest: URLRequest(url: url)) { data, response, error in
            guard let data = data,
                  let dataModels = try? JSONDecoder().decode([T].self, from: data) else {
                completion?(.failure(CustomError()))
                return
            }
            guard let model = dataModels.first else {
                completion?(.failure(CustomError("No records found. Please search again.",
                                                 errorCode: ErrorCode.noResultFound.value)))
                return
            }
            completion?(.success(model))
        }.resume()
    }
}
