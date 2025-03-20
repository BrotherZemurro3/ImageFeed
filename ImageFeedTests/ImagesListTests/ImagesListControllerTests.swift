import XCTest
@testable import ImageFeed

class ImagesListViewControllerTests: XCTestCase {
    var sut: ImagesListViewController!
    var presenterSpy: ImagesListPresenterSpy!
    
    override func setUp() {
        super.setUp()
        presenterSpy = ImagesListPresenterSpy(view: ImagesListViewControllerSpy())
        sut = ImagesListViewController()
        sut.presenter = presenterSpy
    }
    
    override func tearDown() {
        sut = nil
        presenterSpy = nil
        super.tearDown()
    }
    
    func testViewDidLoad_CallsPresenterViewDidLoad() {
        // When
        sut.viewDidLoad()
        
        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled, "viewDidLoad() should be called on presenter")
    }
    
    func testUpdateTableViewAnimated_InsertsRows() {
        // Given
        let tableViewSpy = TableViewSpy()
        sut.tableView = tableViewSpy
        
        // When
        sut.updateTableViewAnimated(oldCount: 2, newCount: 5)
        
        // Then
        XCTAssertTrue(tableViewSpy.insertRowsCalled, "insertRows should be called")
        XCTAssertEqual(tableViewSpy.insertedIndexPaths.count, 3, "Three new rows should be inserted")
    }
    
    func testShowLikeErrorAlert_PresentsAlert() {
        // When
        sut.showLikeErrorAlert()
        
        // Then
        XCTAssertTrue(sut.presentedViewController is UIAlertController, "UIAlertController should be presented")
    }
}

class TableViewSpy: UITableView {
    var insertRowsCalled = false
    var insertedIndexPaths: [IndexPath] = []
    
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertRowsCalled = true
        insertedIndexPaths = indexPaths
    }
}

class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled = false
    var showLikeErrorAlertCalled = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
    
    func showLikeErrorAlert() {
        showLikeErrorAlertCalled = true
    }
}
