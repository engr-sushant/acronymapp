//
//  AcronymViewModel.swift
//  AcronymsApp
//
//  Created by SUSHANT KUMAR on 10/02/23.
//

import Foundation

private let baseURL = "http://www.nactem.ac.uk/software/acromine/dictionary.py"

final class AcronymViewModel {
    
    // MARK: - Properties
    private var networkCallable: NetworkCallable
    private(set) var acronyms = [Acronym]()
    
    // MARK: - Property Initialiser
    init(networkCallable: NetworkCallable = NetworkManager()) {
        self.networkCallable = networkCallable
    }
    
    // MARK: - Exposed Methods
    var numberOfAcronyms: Int {
        acronyms.count
    }
    
    func acronym(at index: Int) -> Acronym? {
        acronyms[safe: index]
    }
    
    var isAcronymsAvailable: Bool {
        !acronyms.isEmpty
    }
    
    func searchAcronym(for searchText: String?, _ completion: APIResultBlock<AcronymResponse>?) {
        networkCallable.processAPIRequest(with: getURL(for: searchText),
                                          AcronymResponse.self) { [weak self] result in
            self?.setAcronyms(with: [])
            switch result {
            case .success(let response):
                guard let data = response.lfs else {
                    completion?(.success(response))
                    return
                }
                self?.setAcronyms(with: data)
                completion?(.success(response))

            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    func setAcronyms(with data: [Acronym]) {
        acronyms = data
    }
    
    func getURL(for searchText: String?) -> String? {
        [baseURL, "?sf=\(searchText ?? "")"].joined()
    }
    
    func isValidSearchInput(_ text: String) -> Bool {
        let invalidItems = " !@#$%^&*()_+{}[]|\"<>,.~`/:;?-=\\¥'£•¢1234567890"
        return !invalidItems.contains(text)
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        index < self.count ? self[index] : nil
    }
}
