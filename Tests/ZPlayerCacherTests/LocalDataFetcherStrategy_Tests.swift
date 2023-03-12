//
//  LocalDataFetcherStrategy_Tests.swift
//
//
//  Created by https://zhgchg.li on 2022/8/27.
//

import Combine
@testable import ZPlayerCacher
import XCTest

class LocalDataFetcherStrategy_Tests: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []

    func testLocalDataFetcherStrategy_fetchMetaData_no_data() throws {
        let mockCacher = MockCacher()
        let url = URL(string: "https://zhgchg.li/1.mp4")!
        let local = LocalDataFetcherStrategy(cacher: mockCacher, url: url)

        let exp = expectation(description: "fetchMetaData() completion")
        local.fetchMetaData().sink { completion in
            if case let .failure(error) = completion, case let PlayerCacherError.metaDataNotFound(notFoundURL) = error {
                XCTAssertEqual(notFoundURL, url.absoluteString)
            } else {
                XCTFail("unexcepted error")
            }
            exp.fulfill()
        } receiveValue: { _ in
            XCTFail("unexcepted error")
        }.store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }

    func testLocalDataFetcherStrategy_fetchMetaData_has_data() throws {
        let mockCacher = MockCacher()
        let url = URL(string: "https://zhgchg.li/1.mp4")!
        let local = LocalDataFetcherStrategy(cacher: mockCacher, url: url)
        let contentType = "video/mp3"
        let contentLength: Int = 100

        local.saveMetaData(metaData: AssetMetaData(contentLength: contentLength, contentType: contentType, isByteRangeAccessSupported: true))

        let exp = expectation(description: "fetchMetaData() completion")
        local.fetchMetaData().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }
            exp.fulfill()
        } receiveValue: { assetMetaData in
            XCTAssertEqual(assetMetaData.contentType, contentType)
            XCTAssertEqual(assetMetaData.contentLength, contentLength)
        }.store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }

    func testLocalDataFetcherStrategy_fetchMediaData() throws {
        let mockCacher = MockCacher()
        let url = URL(string: "https://zhgchg.li/1.mp4")!
        let local = LocalDataFetcherStrategy(cacher: mockCacher, url: url)
        let contentType = "video/mp3"
        let contentLength: Int = 100

        local.saveMetaData(metaData: AssetMetaData(contentLength: contentLength, contentType: contentType, isByteRangeAccessSupported: true))
        let verifyString = "123456789"
        local.saveMediaData(offset: 0, newData: verifyString.data(using: .utf8)!)

        let toEndExp = expectation(description: "fetchMediaData(toEnd) completion")
        local.fetchMediaData(start: 0, length: .totalLength).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }
            toEndExp.fulfill()
        } receiveValue: { data in
            XCTAssertEqual(verifyString, String(data: data, encoding: .utf8))
        }.store(in: &cancellables)

        let from3To7Exp = expectation(description: "fetchMediaData(3~7) completion")
        local.fetchMediaData(start: 3, length: .length(4)).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }
            from3To7Exp.fulfill()
        } receiveValue: { data in
            XCTAssertEqual("4567", String(data: data, encoding: .utf8))
        }.store(in: &cancellables)

        let from7To15Exp = expectation(description: "fetchMediaData(7~15) completion")
        local.fetchMediaData(start: 7, length: .length(15)).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }
            from7To15Exp.fulfill()
        } receiveValue: { data in
            XCTAssertEqual("89", String(data: data, encoding: .utf8))
        }.store(in: &cancellables)

        let from5To1Exp = expectation(description: "fetchMediaData(5~(5+1)) completion")
        local.fetchMediaData(start: 5, length: .length(1)).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }
            from5To1Exp.fulfill()
        } receiveValue: { data in
            XCTAssertEqual("6", String(data: data, encoding: .utf8))
        }.store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }

    func testLocalDataFetcherStrategy_saveMediData() throws {
        let mockCacher = MockCacher()
        let url = URL(string: "https://zhgchg.li/1.mp4")!
        let local = LocalDataFetcherStrategy(cacher: mockCacher, url: url)
        let contentType = "video/mp3"
        let contentLength: Int = 100

        local.saveMetaData(metaData: AssetMetaData(contentLength: contentLength, contentType: contentType, isByteRangeAccessSupported: true))

        let verifyString = "1234"
        local.saveMediaData(offset: 0, newData: verifyString.data(using: .utf8)!)

        let from0To4Exp = expectation(description: "fetchMediaData(0~4) completion")
        local.fetchMediaData(start: 0, length: .length(4)).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }
            from0To4Exp.fulfill()
        } receiveValue: { data in
            XCTAssertEqual(verifyString, String(data: data, encoding: .utf8))
        }.store(in: &cancellables)

        let verifyStringAppend = "56789"

        // won't save if not continute
        local.saveMediaData(offset: 10, newData: verifyStringAppend.data(using: .utf8)!)
        let toEndExp = expectation(description: "fetchMediaData(0~End) completion")
        local.fetchMediaData(start: 0, length: .totalLength).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }
            toEndExp.fulfill()
        } receiveValue: { data in
            XCTAssertEqual(verifyString, String(data: data, encoding: .utf8))
        }.store(in: &cancellables)

        // save if continute
        local.saveMediaData(offset: 4, newData: verifyStringAppend.data(using: .utf8)!)
        let toEndExp2 = expectation(description: "fetchMediaData(0~End) completion")
        local.fetchMediaData(start: 0, length: .totalLength).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }
            toEndExp2.fulfill()
        } receiveValue: { data in
            XCTAssertEqual("\(verifyString)\(verifyStringAppend)", String(data: data, encoding: .utf8))
        }.store(in: &cancellables)

        // test not override
        // 123456789
        //       123789
        // 123456789789
        local.saveMediaData(offset: 7, newData: verifyStringAppend.data(using: .utf8)!)
        let toEndExp3 = expectation(description: "fetchMediaData(0~End) completion")
        local.fetchMediaData(start: 0, length: .totalLength).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("unexcepted error: \(error)")
            }
            toEndExp3.fulfill()
        } receiveValue: { data in
            XCTAssertEqual("123456789789", String(data: data, encoding: .utf8))
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
