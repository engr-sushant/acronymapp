//
//  AcronymViewController.swift
//  AcronymsApp
//
//  Created by SUSHANT KUMAR on 10/02/23.
//

import UIKit

enum SearchState {
    case startYourSearch
    case searchResultFound
    case errorLabel(_ error: String?)
}

final class AcronymViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var startSearchView: UIView!
    @IBOutlet private weak var searchStartedView: UIView!
    @IBOutlet private weak var errorView: UIView!
    @IBOutlet private weak var errorLabel: UILabel!
    
    // MARK: - Properties
    private lazy var viewModel = AcronymViewModel()
    private var workItem: DispatchWorkItem?
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = .acronymsTitle
        configureView(with: .startYourSearch)
    }
}

// MARK: - Private Methods
private extension AcronymViewController {
    /// Handles the differnet UI scenarios for given `SearchState`
    /// Hide & Show different views.
    /// - parameters: Current state of search `SearchState`
    func configureView(with state: SearchState) {
        switch state {
        case .startYourSearch:
            startSearchView.isHidden = false
            searchStartedView.isHidden = true
            tableView.isHidden = true
            errorView.isHidden = true
                        
        case .searchResultFound:
            startSearchView.isHidden = true
            searchStartedView.isHidden = true
            tableView.isHidden = false
            errorView.isHidden = true
            tableView.reloadData()
            searchBar.resignFirstResponder()
            
        case .errorLabel(let error):
            startSearchView.isHidden = true
            searchStartedView.isHidden = true
            tableView.isHidden = true
            errorView.isHidden = false
            errorLabel.text = error
        }
    }
    
    /// Method to find the search result for requested Acronym through view model.
    /// - parameters: Requested search text as `String?`
    func fetchAcronym(for text: String?) {
        viewModel.searchAcronym(for: text) { [weak self] result in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if self.viewModel.isAcronymsAvailable {
                        self.configureView(with: .searchResultFound)
                    } else {
                        self.configureView(with: .errorLabel(.noRecordFoundMsg))
                    }
                case .failure(let error):
                    self.configureView(with: .errorLabel(error.errorMsg))
                }
            }
        }
    }
    
    /// Helps in pre-search preparation that handles the unique search technique
    /// Also known as `DeBounce Search Technique`
    /// - parameters: Requested search text as `String?`
    func prepareForSearch(with text: String?) {
        workItem?.cancel()
        let newWorkItem = DispatchWorkItem { [weak self] in
            self?.fetchAcronym(for: text)
        }
        workItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1,
                                      execute: newWorkItem)
    }
}

// MARK: - TableView Delegates & DataSource methods
extension AcronymViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfAcronyms
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = viewModel.acronym(at: indexPath.row) else {
            return UITableViewCell()
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: .cellIdentifier)
        cell.textLabel?.text = model.lf
        return cell
    }
}

// MARK: - SearchBar Delegates methods
extension AcronymViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if viewModel.isValidSearchInput(text) {
            return true
        } else {
            Alert.display(viewController: self, message: .invalidTextMsg)
            return false
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        workItem?.cancel()
        if searchText == "" {
            configureView(with: .startYourSearch)
        } else {
            prepareForSearch(with: searchText)
        }
    }
    
    /// Delegate method implementation to by-pass pre-search preparation i.e. `prepareForSearch:`
    /// when user intentionally clicks on search button
    /// - parameters: searchBar`UISearchBar`
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        workItem?.cancel()
        fetchAcronym(for: searchBar.text)
        searchBar.resignFirstResponder()
    }
}
