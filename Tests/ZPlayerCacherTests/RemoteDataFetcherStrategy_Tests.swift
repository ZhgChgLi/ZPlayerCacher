//
//  RemoteDataFetcherStrategy_Tests.swift
//
//
//  Created by https://zhgchg.li on 2022/8/26.
//

import Combine
@testable import ZPlayerCacher
import XCTest

class RemoteDataFetcherStrategy_Tests: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []
    private let dispatchQueue = DispatchQueue(label: "RemoteDataFetcherStrategy_Tests")

    func testRemoteDataFetcherStrategy_fetchMetaData() throws {
        let mockNetwork = MockNetwork()
        let url = URL(string: "https://zhgchg.li/1.mp4")!
        let remote = RemoteDataFetcherStrategy(url: url, network: mockNetwork, dispatchQueue: dispatchQueue)
        let contentType = "video/mp3"
        let contentLength: Int = 100
        let expectedResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": contentType, "Content-Range": "bytes 0-1/\(String(contentLength))", "Accept-Ranges": "bytes"])
        mockNetwork.expectedResponse = expectedResponse

        let exp = expectation(description: "fetchMetaData() completion")
        remote.fetchMetaData().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }
            XCTAssertEqual(mockNetwork.expectedRequest?.allHTTPHeaderFields?["Range"] as? String, "bytes=0-1")
            exp.fulfill()
        } receiveValue: { assetMetaData in
            XCTAssertEqual(assetMetaData.contentType, contentType)
            XCTAssertEqual(assetMetaData.contentLength, contentLength)
        }.store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }

    func testRemoteDataFetcherStrategy_fetchMediData_toRange() throws {
        let mockNetwork = MockNetwork()
        let url = URL(string: "https://zhgchg.li/1.mp4")!
        let remote = RemoteDataFetcherStrategy(url: url, network: mockNetwork, dispatchQueue: dispatchQueue)

        let exp = expectation(description: "fetchMediData() completion")
        remote.fetchMediaData(start: 12, length: .length(99)).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }
            XCTAssertEqual(mockNetwork.expectedRequest?.allHTTPHeaderFields?["Range"] as? String, "bytes=12-111")
            exp.fulfill()
        } receiveValue: { _ in

        }.store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }

    func testRemoteDataFetcherStrategy_fetchMediData_toEnd() throws {
        let mockNetwork = MockNetwork()
        let url = URL(string: "https://zhgchg.li/1.mp4")!
        let remote = RemoteDataFetcherStrategy(url: url, network: mockNetwork, dispatchQueue: dispatchQueue)

        let exp = expectation(description: "fetchMediData() completion")
        remote.fetchMediaData(start: 12, length: .totalLength).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }

            XCTAssertEqual(mockNetwork.expectedRequest?.allHTTPHeaderFields?["Range"] as? String, "bytes=12-")
            exp.fulfill()
        } receiveValue: { _ in

        }.store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }
}

private class MockNetworkTask: NetworkTask {
    func resume() {}
}

private class MockNetwork: Network {

    weak var delegate: NetworkDelegate?
    var expectedRequest: URLRequest?
    var expectedResponse: HTTPURLResponse?
    var expectedData: Data = Data()
    var cancelCalledCount: Int = 0
    var dataTaskCalledCount: Int = 0

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkTask {
        expectedRequest = request
        completionHandler(expectedData, expectedResponse, nil)
        dataTaskCalledCount += 1
        return MockNetworkTask()
    }

    func dataTask(with request: URLRequest) -> NetworkTask {
        expectedRequest = request
        dataTaskCalledCount += 1

        let dataTask = MockNetworkTask()
        delegate?.network(self, didReceive: expectedData)
        delegate?.network(self, didCompleteWithError: nil)
        return dataTask
    }

    func invalidateAndCancel() {
        cancelCalledCount += 1
    }
}
