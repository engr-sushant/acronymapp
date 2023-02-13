//
//  AcronymViewModelTest.swift
//  AcronymsAppTests
//
//  Created by SUSHANT KUMAR on 10/02/23.
//

import XCTest
@testable import AcronymsApp

final class AcronymViewModelTest: XCTestCase {
    private var viewModel: AcronymViewModel!
    private var mockSession: MockURLSesion?
    private var httpClient: NetworkManager?

    override func setUp() {
        super.setUp()
        mockSession = MockURLSesion()
        httpClient = NetworkManager(mockSession!)
        viewModel = AcronymViewModel(networkCallable: httpClient!)
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Test with API Mocking -
    func testAcronymsSearchSuccess() {
        mockSession?.nextData = JSONUtility.jsonData(with: "success_acronyms_search")
        viewModel.searchAcronym(for: "HMM") { _ in
            self.httpClient?.processAPIRequest(with: "HMM",
                                               AcronymResponse.self) { [self] response in
                switch response {
                case .success(let model):
                    XCTAssertNotNil(model)
                    do {
                        let results = try XCTUnwrap(model.lfs)
                        XCTAssertEqual(results.count, 8)
                        XCTAssertTrue(self.viewModel.isAcronymsAvailable)
                        self.itemAtIndexTest()
                    } catch {
                        XCTFail("AcronymResponse unwrap failed")
                    }
                default: break
                }
            }
        }
    }
    
    func testAcronymsZeroSearch() {
        mockSession?.nextData = JSONUtility.jsonData(with: "success_noResult_acronyms_search")
        viewModel.searchAcronym(for: "Xcvb") { _ in
            self.httpClient?.processAPIRequest(with: "Xcvb",
                                               AcronymResponse.self) { response in
                switch response {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    XCTAssertFalse(self.viewModel.isAcronymsAvailable)
                    // Error code for no record found is 202
                    XCTAssertEqual(error.errorCode, 202)
                default: break
                }
            }
        }
    }
    
    func testAcronymsNoLFsFound() {
        mockSession?.nextData = JSONUtility.jsonData(with: "success_noLFS_acronyms_search")
        viewModel.searchAcronym(for: "Xcvb") { _ in
            self.httpClient?.processAPIRequest(with: "Xcvb",
                                               AcronymResponse.self) { response in
                switch response {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    XCTAssertFalse(self.viewModel.isAcronymsAvailable)
                    // Error code for no record found is 202
                    XCTAssertEqual(error.errorCode, 202)
                default: break
                }
            }
        }
    }

    func testAcronymsSearchFailure() {
        mockSession?.nextData = JSONUtility.jsonData(with: "failure_acronyms_search")
        viewModel.searchAcronym(for: "HMM") { _ in
            self.httpClient?.processAPIRequest(with: "HMM",
                                               AcronymResponse.self) { response in
                switch response {
                case .failure(let error):
                    XCTAssertNotNil(error)
                default: break
                }
            }
        }
    }
    
    // MARK: - Custom Methods Testing -
    func testSearchURL() {
        let searchText1 = viewModel.getURL(for: "UPS")
        let searchText2 = viewModel.getURL(for: "HMM")
        let searchText3 = viewModel.getURL(for: nil)
        XCTAssertEqual("http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=UPS", searchText1)
        XCTAssertEqual("http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=HMM", searchText2)
        XCTAssertEqual("http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=", searchText3)
    }
        
    func itemAtIndexTest() {
        let item1 = viewModel.acronym(at: 0)
        let item2 = viewModel.acronym(at: 1)
        let item4 = viewModel.acronym(at: 10)
        XCTAssertNotNil(item1)
        XCTAssertNotNil(item2)
        XCTAssertNil(item4)
    }
        
    func testIsNotValidInput() {
        let status1 = viewModel.isValidSearchInput(" ")
        let status2 = viewModel.isValidSearchInput("@")
        let status3 = viewModel.isValidSearchInput("#")
        let status4 = viewModel.isValidSearchInput("$")
        let status5 = viewModel.isValidSearchInput("&")
        XCTAssertFalse(status1)
        XCTAssertFalse(status2)
        XCTAssertFalse(status3)
        XCTAssertFalse(status4)
        XCTAssertFalse(status5)
    }
    
    func testIsValidInput() {
        let status1 = viewModel.isValidSearchInput("a")
        let status2 = viewModel.isValidSearchInput("A")
        let status3 = viewModel.isValidSearchInput("z")
        let status4 = viewModel.isValidSearchInput("Z")
        XCTAssertTrue(status1)
        XCTAssertTrue(status2)
        XCTAssertTrue(status3)
        XCTAssertTrue(status4)
    }
}

private extension AcronymViewModelTest {
    var noAcronym: [Acronym] {
        let data = JSONUtility.jsonData(with: "success_noResult_acronyms_search")
        let model = try? JSONDecoder().decode([Acronym].self, from: data)
        return model!
    }
    
    var acronyms: [Acronym] {
        let data = JSONUtility.jsonData(with: "success_acronyms_search")
        let model = try? JSONDecoder().decode([Acronym].self, from: data)
        return model!
    }
}
