//
//  AcronymViewModelTest.swift
//  AcronymsAppTests
//
//  Created by SUSHANT KUMAR on 10/02/23.
//

import XCTest

final class AcronymViewModelTest: XCTestCase {
    private var viewModel: AcronymViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = AcronymViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testSearchURL() {
        let searchText1 = viewModel.getURL(for: "UPS")
        let searchText2 = viewModel.getURL(for: "HMM")
        let searchText3 = viewModel.getURL(for: nil)
        XCTAssertEqual("http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=UPS", searchText1)
        XCTAssertEqual("http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=HMM", searchText2)
        XCTAssertEqual("http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=", searchText3)
    }
    
    func testNumberOfItems() {
        viewModel.setAcronyms(with: noAcronym)
        XCTAssertEqual(0, viewModel.numberOfAcronyms)
        viewModel.setAcronyms(with: acronyms)
        XCTAssertEqual(3, viewModel.numberOfAcronyms)
    }
    
    func testItemAtIndex() {
        viewModel.setAcronyms(with: acronyms)
        let item1 = viewModel.acronym(at: 0)
        let item2 = viewModel.acronym(at: 1)
        let item3 = viewModel.acronym(at: 2)
        let item4 = viewModel.acronym(at: 3)
        XCTAssertEqual("UPS1", item1?.lf)
        XCTAssertEqual("UPS2", item2?.lf)
        XCTAssertEqual("UPS3", item3?.lf)
        XCTAssertNil(item4)
    }
    
    func testIsAcronymsAvailable() {
        viewModel.setAcronyms(with: acronyms)
        XCTAssertTrue(viewModel.isAcronymsAvailable)
        viewModel.setAcronyms(with: noAcronym)
        XCTAssertFalse(viewModel.isAcronymsAvailable)
    }
}

private extension AcronymViewModelTest {
    var noAcronym: [Acronym] {
        []
    }
    
    var acronyms: [Acronym] {
        [Acronym(lf: "UPS1"), Acronym(lf: "UPS2"), Acronym(lf: "UPS3")]
    }
}
