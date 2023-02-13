//
//  JSONUtility.swift
//  AcronymsAppTests
//
//  Created by SUSHANT KUMAR on 13/02/23.
//

import Foundation
@testable import AcronymsApp

// MARK: - Type -
typealias JSON = [String: Any]

class JSONUtility {
    // MARK: - Convert file data to JSON object
    static func jsonDictionary(with file: String) -> [String: Any] {
        let bundle = Bundle(for: JSONUtility.self)
        guard let file = bundle.path(forResource: file, ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: file), options: []),
              let object = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
              let validObject = object as? JSON
        else {
            return [:]
        }
        return validObject
    }
    
    static func jsonData(with filename: String) -> Data {
        let bundle = Bundle(for: JSONUtility.self)
        let path = bundle.url(forResource: filename, withExtension: "json")
        let data = try? Data(contentsOf: path!)
        return data!
    }
}
