//
//  AcronymViewController.swift
//  AcronymsApp
//
//  Created by SUSHANT KUMAR on 10/02/23.
//

import UIKit

enum SearchState {
    case startYourSearch
    case searchStarted
    case searchResultFound
    case errorLabel(_ error: String?)
}

final class AcronymViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            searchBar.searchTextField.clearButtonMode = .never
        }
    }
    @IBOutlet private weak var startSearchView: UIView!
    @IBOutlet private weak var searchStartedView: UIView!
    @IBOutlet private weak var errorView: UIView!
    @IBOutlet private weak var errorLabel: UILabel!
    
    // MARK: - Properties
    private lazy var viewModel = AcronymViewModel()
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Acronyms"
        configureView(with: .startYourSearch)
    }
}

// MARK: - Private Methods
private extension AcronymViewController {
    func configureView(with state: SearchState) {
        switch state {
        case .startYourSearch:
            view.isUserInteractionEnabled = true
            startSearchView.isHidden = false
            searchStartedView.isHidden = true
            tableView.isHidden = true
            errorView.isHidden = true
            
        case .searchStarted:
            view.isUserInteractionEnabled = false
            startSearchView.isHidden = true
            searchStartedView.isHidden = false
            tableView.isHidden = true
            errorView.isHidden = true
            
        case .searchResultFound:
            view.isUserInteractionEnabled = true
            startSearchView.isHidden = true
            searchStartedView.isHidden = true
            tableView.isHidden = false
            errorView.isHidden = true
            tableView.reloadData()
            
        case .errorLabel(let error):
            view.isUserInteractionEnabled = true
            startSearchView.isHidden = true
            searchStartedView.isHidden = true
            tableView.isHidden = true
            errorView.isHidden = false
            errorLabel.text = error
        }
    }
    
    func fetchAcronym(for text: String?) {
        // Show Loader
        configureView(with: .searchStarted)
        viewModel.searchAcronym(for: text) { [weak self] result in
            // Hide Loader
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if self.viewModel.isAcronymsAvailable {
                        self.configureView(with: .searchResultFound)
                    } else {
                        self.configureView(with: .errorLabel("No records found. Please search again."))
                    }
                case .failure(let error):
                    self.configureView(with: .errorLabel(error.errorMsg))
                }
            }
        }
    }
}

// MARK: - TableView Delegates & DataSource
extension AcronymViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfAcronyms
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = viewModel.acronym(at: indexPath.row) else {
            return UITableViewCell()
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = model.lf
        return cell
    }
}

// MARK: - SearchBar Delegates
extension AcronymViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let validString = " !@#$%^&*()_+{}[]|\"<>,.~`/:;?-=\\¥'£•¢1234567890"
        if validString.contains(text) || (searchBar.textInputMode?.primaryLanguage == "emoji") {
            return false
        }
        configureView(with: .startYourSearch)
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchAcronym(for: searchBar.text)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = ""
        configureView(with: .startYourSearch)
    }
}
