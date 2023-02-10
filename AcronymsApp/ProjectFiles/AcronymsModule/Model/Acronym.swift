//
//  Acronym.swift
//  AcronymsApp
//
//  Created by SUSHANT KUMAR on 10/02/23.
//

import Foundation

struct AcronymResponse: Codable {
    var sf: String?
    var lfs: [Acronym]?
    
    private enum codingKeys: String, CodingKey {
        case word = "sf"
        case data = "lfs"
    }
}

class Acronym: Codable {
    var lf: String?
    
    private enum codingKeys: String, CodingKey {
        case title = "lf"
    }
    
    init(lf: String) {
        self.lf = lf
    }
}
