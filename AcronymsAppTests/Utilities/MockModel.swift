//
//  MockModel.swift
//  AcronymsAppTests
//
//  Created by SUSHANT KUMAR on 13/02/23.
//

import XCTest
@testable import AcronymsApp

class MockModel {
    static func format<T: Codable>(fileName: String, type _: T.Type) -> T {
        let json = JSONUtility.jsonData(with: fileName)
        let model = try? JSONDecoder().decode(T.self, from: json)
        return model!
    }
}
