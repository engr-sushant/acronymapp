//
//  AcronymViewModel.swift
//  AcronymsApp
//
//  Created by SUSHANT KUMAR on 10/02/23.
//

import Foundation

final class AcronymViewModel {
    
    // MARK: - Properties
    private var networkCallable: NetworkManager
    private(set) var acronyms = [Acronym]()
    
    // MARK: - Property Initialiser via Initialiser Injection
    init(networkCallable: NetworkManager = NetworkManager()) {
        self.networkCallable = networkCallable
    }
    
    // MARK: - Exposed Methods
    
    /// Provides the total number of current acronyms `Acronym`
    /// - returns: Count of acronyms `Acronym`
    var numberOfAcronyms: Int {
        acronyms.count
    }
    
    /// Returns the Acronym at requested Index from the current Array as `Acronym?`
    /// - parameters: Requested Index
    /// - returns: Acronym found at requested index `Acronym?`
    func acronym(at index: Int) -> Acronym? {
        acronyms[safe: index]
    }
    
    /// Checks if the Acronyms Array is empty or not
    /// - returns: `true` when the Array is not empty
    var isAcronymsAvailable: Bool {
        !acronyms.isEmpty
    }
    
    /// Method to call API for given searchText as `String?`
    /// - parameters: 1. Requested search text
    /// - parameters: 2. Completion `APIResultBlock<AcronymResponse>?`
    func searchAcronym(for searchText: String?, _ completion: APIResultBlock<AcronymResponse>?) {
        networkCallable.processAPIRequest(with: getURL(for: searchText),
                                          AcronymResponse.self) { [weak self] result in
            self?.acronyms = []
            switch result {
            case .success(let response):
                guard let data = response.lfs else {
                    completion?(.success(response))
                    return
                }
                self?.acronyms = data
                completion?(.success(response))

            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    /// Method to construct the search URL for requested search text `String?`
    /// - parameters: search text
    /// - returns: URL constructed for the text as `String?`
    func getURL(for searchText: String?) -> String? {
        [.baseURL, .searchPrefix, "\(searchText ?? "")"].joined()
    }
    
    /// Method to check if the provided search input is valid
    /// - parameters: search text
    /// - returns: `true` if the search text is valid
    func isValidSearchInput(_ text: String) -> Bool {
        !String.invalidText.contains(text)
    }
}

extension Array {
    /// Subscript for avoiding the `index out of bound` exception
    /// - parameters: Requested Index as `Int`
    /// - returns: `nil` if requested index is beyond the array count
    subscript (safe index: Int) -> Element? {
        index < self.count ? self[index] : nil
    }
}
