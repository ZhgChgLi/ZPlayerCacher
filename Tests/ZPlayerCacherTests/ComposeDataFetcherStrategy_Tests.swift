//
//  ComposeDataFetcherStrategy_Tests.swift
//
//
//  Created by https://zhgchg.li on 2022/8/27.
//

import Combine
@testable import ZPlayerCacher
import XCTest

class ComposeDataFetcherStrategy_Tests: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []
    private let dispatchQueue: DispatchQueue = DispatchQueue(label: "ComposeDataFetcherStrategy_Tests")

    func testComposeDataFetcherStrategy_fetchMetaData_localNoData() throws {
        let url = URL(string: "https://zhgchg.li/1.mp4")!
        let contentType = "video/mp3"
        let contentLength: Int = 100

        let mockNetwork = MockNetwork()
        let mockCacher = MockCacher()

        let local = LocalDataFetcherStrategy(cacher: mockCacher, url: url)
        let remote = RemoteDataFetcherStrategy(url: url, network: mockNetwork, dispatchQueue: dispatchQueue)
        let compose = ComposeDataFetcherStrategy(local: local, remote: remote)

        let expectedResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": contentType, "Content-Range": "bytes 0-1/\(String(contentLength))", "Accept-Ranges": "bytes"])
        mockNetwork.expectedResponse = expectedResponse

        let exp = expectation(description: "fetchMetaData() completion")
        var receiveDataCount = 0
        compose.fetchMetaData().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }
            XCTAssertEqual(mockNetwork.expectedRequest?.allHTTPHeaderFields?["Range"] as? String, "bytes=0-1")
            XCTAssertEqual(receiveDataCount, 1)
            exp.fulfill()
        } receiveValue: { assetMetaData in
            XCTAssertEqual(assetMetaData.contentType, contentType)
            XCTAssertEqual(assetMetaData.contentLength, contentLength)
            receiveDataCount += 1
        }.store(in: &cancellables)

        waitForExpectations(timeout: 3)

        // will save to local
        let exp2 = expectation(description: "fetchMetaData() completion")
        receiveDataCount = 0
        local.fetchMetaData().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }
            XCTAssertEqual(mockNetwork.expectedRequest?.allHTTPHeaderFields?["Range"] as? String, "bytes=0-1")
            XCTAssertEqual(receiveDataCount, 1)
            exp2.fulfill()
        } receiveValue: { assetMetaData in
            XCTAssertEqual(assetMetaData.contentType, contentType)
            XCTAssertEqual(assetMetaData.contentLength, contentLength)
            receiveDataCount += 1
        }.store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }

    func testComposeDataFetcherStrategy_fetchMetaData_localHasVaildData() throws {
        let url = URL(string: "https://zhgchg.li/1.mp4")!
        let contentType = "video/mp3"
        let contentLength: Int = 100

        let mockNetwork = MockNetwork()
        let mockCacher = MockCacher()

        let local = LocalDataFetcherStrategy(cacher: mockCacher, url: url)
        let remote = RemoteDataFetcherStrategy(url: url, network: mockNetwork, dispatchQueue: dispatchQueue)
        let compose = ComposeDataFetcherStrategy(local: local, remote: remote)

        local.saveMetaData(metaData: AssetMetaData(contentLength: contentLength, contentType: contentType, isByteRangeAccessSupported: true))
        let expectedResponse = HTTPURLResponse(url: url, statusCode: 304, httpVersion: nil, headerFields: [:])
        mockNetwork.expectedResponse = expectedResponse
        mockNetwork.dataTaskCalledCount = 0

        let exp = expectation(description: "fetchMetaData() completion")
        var receiveDataCount = 0
        compose.fetchMetaData().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }
            XCTAssertEqual(receiveDataCount, 1)
            XCTAssertEqual(mockNetwork.dataTaskCalledCount, 0)
            exp.fulfill()
        } receiveValue: { assetMetaData in
            XCTAssertEqual(assetMetaData.contentType, contentType)
            XCTAssertEqual(assetMetaData.contentLength, contentLength)
            receiveDataCount += 1
        }.store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }

    func testComposeDataFetcherStrategy_fetchMediaData_localNoData() throws {
        let url = URL(string: "https://zhgchg.li/1.mp4")!
        let contentType = "video/mp3"
        let contentLength: Int = 100

        let mockNetwork = MockNetwork()
        let mockCacher = MockCacher()

        let local = LocalDataFetcherStrategy(cacher: mockCacher, url: url)
        let remote = RemoteDataFetcherStrategy(url: url, network: mockNetwork, dispatchQueue: dispatchQueue)
        let compose = ComposeDataFetcherStrategy(local: local, remote: remote)

        local.saveMetaData(metaData: AssetMetaData(contentLength: contentLength, contentType: contentType, isByteRangeAccessSupported: true))

        let verifyString = "12345"
        var receiveDataCount = 0
        let expectedResponse = HTTPURLResponse(url: url, statusCode: 304, httpVersion: nil, headerFields: [:])
        mockNetwork.expectedResponse = expectedResponse
        mockNetwork.expectedDatas = [verifyString.data(using: .utf8)!]

        var totaldata = Data()
        let exp = expectation(description: "fetchMediData() completion")
        compose.fetchMediaData(start: 0, length: .totalLength).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }

            XCTAssertEqual(String(data: totaldata, encoding: .utf8), verifyString)
            XCTAssertEqual(receiveDataCount, 1)
            exp.fulfill()
        } receiveValue: { data in
            totaldata.append(data)
            receiveDataCount += 1
        }.store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }

    func testComposeDataFetcherStrategy_fetchMediaData_localDataNotEnough() throws {
        let url = URL(string: "https://zhgchg.li/1.mp4")!
        let contentType = "video/mp3"
        let contentLength: Int = 100

        let mockNetwork = MockNetwork()
        let mockCacher = MockCacher()

        let local = LocalDataFetcherStrategy(cacher: mockCacher, url: url)
        let remote = RemoteDataFetcherStrategy(url: url, network: mockNetwork, dispatchQueue: dispatchQueue)
        let compose = ComposeDataFetcherStrategy(local: local, remote: remote)

        let localData = "12345"
        let remoteData1 = "67"
        let remoteData2 = "89"
        let remoteData3 = "1011"
        local.saveMetaData(metaData: AssetMetaData(contentLength: contentLength, contentType: contentType, isByteRangeAccessSupported: true))
        local.saveMediaData(offset: 0, newData: localData.data(using: .utf8)!)

        var receiveDataCount = 0
        let expectedResponse = HTTPURLResponse(url: url, statusCode: 304, httpVersion: nil, headerFields: [:])
        mockNetwork.expectedResponse = expectedResponse
        mockNetwork.expectedDatas = [remoteData1.data(using: .utf8)!, remoteData2.data(using: .utf8)!, remoteData3.data(using: .utf8)!]

        var totaldata = Data()

        let exp = expectation(description: "fetchMediData() completion")
        compose.fetchMediaData(start: 0, length: .totalLength).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }

            XCTAssertEqual(receiveDataCount, 4)
            XCTAssertEqual(String(data: totaldata, encoding: .utf8), "\(localData)\(remoteData1)\(remoteData2)\(remoteData3)")
            exp.fulfill()
        } receiveValue: { data in
            totaldata.append(data)
            receiveDataCount += 1
        }.store(in: &cancellables)

        waitForExpectations(timeout: 3)

        receiveDataCount = 0
        totaldata = Data()
        let exp2 = expectation(description: "fetchMediData() completion")
        local.fetchMediaData(start: 0, length: .totalLength).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }

            XCTAssertEqual(receiveDataCount, 1)
            XCTAssertEqual(String(data: totaldata, encoding: .utf8), "\(localData)\(remoteData1)\(remoteData2)\(remoteData3)")
            exp2.fulfill()
        } receiveValue: { data in
            totaldata.append(data)
            receiveDataCount += 1
        }.store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }
}

private class MockCacher: Cacher {

    var savedDatas: [String: Data] = [:]

    func set(key: String, data: Data, completion: ((Error?) -> Void)?) {
        savedDatas[key] = data
        completion?(nil)
    }

    func get(key: String) -> Data? {
        return savedDatas[key]
    }
}

private class MockNetworkMetaTask: NetworkTask {
    func resume() {}
}

private class MockNetworkMediTask: NetworkTask {
    let network: Network
    let expectedDatas: [Data]
    init(network: Network, expectedDatas: [Data]) {
        self.network = network
        self.expectedDatas = expectedDatas
    }

    func resume() {

        var expectedDatas = self.expectedDatas
        if let expectedData = expectedDatas.first {
            network.delegate?.network(network, didReceive: expectedData)
        }
        expectedDatas = Array(expectedDatas.dropFirst())

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            expectedDatas.forEach { expectedData in
                self.network.delegate?.network(self.network, didReceive: expectedData)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.network.delegate?.network(self.network, didCompleteWithError: nil)
        }
    }
}

private class MockNetwork: Network {

    weak var delegate: NetworkDelegate?
    var expectedRequest: URLRequest?
    var expectedResponse: HTTPURLResponse?
    var expectedDatas: [Data] = []
    var cancelCalledCount: Int = 0
    var dataTaskCalledCount: Int = 0

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkTask {
        expectedRequest = request
        dataTaskCalledCount += 1
        completionHandler(expectedDatas.first ?? Data(), expectedResponse, nil)
        return MockNetworkMetaTask()
    }

    func dataTask(with request: URLRequest) -> NetworkTask {
        expectedRequest = request
        dataTaskCalledCount += 1

        let dataTask = MockNetworkMediTask(network: self, expectedDatas: expectedDatas)
        return dataTask
    }

    func invalidateAndCancel() {
        cancelCalledCount += 1
    }
}
