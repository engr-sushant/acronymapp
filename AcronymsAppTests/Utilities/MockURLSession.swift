//
//  MockURLSesion.swift
//  AcronymsAppTests
//
//  Created by SUSHANT KUMAR on 13/02/23.
//

import Foundation
@testable import AcronymsApp

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    var resumeWasCalled = false
    func resume() {
        resumeWasCalled = true
    }
}

class MockURLSesion: URLSessionProtocol {
    // This variable will be used to compare the passed URL of the URL request
    var lastUrl: URL?
    
    // this will be passed from the Test function on the basis of the success and failure test cases of the response.
    var nextData: Data?
    
    // This error message will be passed on the basis of success and failure testing of the response.
    var nextError: Error?
    
    // Every time a new data task will be created for making the API call.
    var nextDataTask = MockURLSessionDataTask()
    
    func successResponse(_ urlRequest: URLRequest) -> URLResponse {
        return HTTPURLResponse(url: urlRequest.url!,
                               statusCode: 200,
                               httpVersion: "HTTP/1.1",
                               headerFields: nil)!
    }
    
    func dataTask(urlRequest: URLRequest, completionHandler: @escaping APICompletionBlock) -> URLSessionDataTaskProtocol {
        lastUrl = urlRequest.url
        completionHandler(nextData, successResponse(urlRequest), nextError)
        return nextDataTask
    }
}
