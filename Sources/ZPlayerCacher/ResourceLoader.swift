//
//  ResourceLoader.swift
//
//
//  Created by https://zhgchg.li on 2022/8/26.
//

import AVFoundation
import Combine
import Foundation

final class ResourceLoader: NSObject {

    let loaderQueue = DispatchQueue(label: "playerCacher.resourceLoader.queue")

    private let originScheme: String
    private var cancellables: [AVAssetResourceLoadingRequest: AnyCancellable] = [:]
    private var currentLoadingRequests: [AVAssetResourceLoadingRequest: DataFetcherStrategy] = [:]
    private let logger: PlayerCacherLogger
    private let cacher: Cacher
    
    init(originScheme: String, cacher: Cacher, logger: PlayerCacherLogger) {
        self.originScheme = originScheme
        self.cacher = cacher
        self.logger = logger
    }
}

extension ResourceLoader: AVAssetResourceLoaderDelegate {

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard var url = loadingRequest.request.url else {
            return false
        }
        url = putBackToOriginURL(url: url)

        let local = LocalDataFetcherStrategy(cacher: cacher, url: url)
        let remote = RemoteDataFetcherStrategy(url: url, network: URLSessionNetwork(), dispatchQueue: loaderQueue)
        let compose = ComposeDataFetcherStrategy(local: local, remote: remote)

        if loadingRequest.contentInformationRequest != nil {

            logger.info("shouldWaitForLoadingOfRequestedResource-contentInformationRequest: \(url)")

            let cancellable = compose.fetchMetaData().sink { completion in
                self.logger.info("shouldWaitForLoadingOfRequestedResource-contentInformationRequest-completion: \(url) \(completion)")

                if case let .failure(error) = completion {
                    loadingRequest.finishLoading(with: error)
                } else {
                    loadingRequest.finishLoading()
                }
                self.currentLoadingRequests.removeValue(forKey: loadingRequest)
                self.cancellables.removeValue(forKey: loadingRequest)
            } receiveValue: { assetMetaData in
                self.logger.info("shouldWaitForLoadingOfRequestedResource-contentInformationRequest-receiveValue: \(url) \(assetMetaData)")

                loadingRequest.contentInformationRequest?.contentType = assetMetaData.contentType
                loadingRequest.contentInformationRequest?.contentLength = Int64(assetMetaData.contentLength)
                loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = assetMetaData.isByteRangeAccessSupported
            }
            cancellables[loadingRequest] = cancellable
        } else if loadingRequest.dataRequest != nil {
            let end: DataFetcherRequestLength
            if loadingRequest.dataRequest?.requestsAllDataToEndOfResource == true {
                end = .totalLength
            } else {
                end = .length(loadingRequest.dataRequest?.requestedLength ?? 1)
            }
            let start = loadingRequest.dataRequest?.currentOffset ?? 0

            logger.info("shouldWaitForLoadingOfRequestedResource-dataRequest: \(url) \(start)~\(end)")

            let cancellable = compose.fetchMediaData(start: Int(start), length: end).sink { completion in
                self.logger.info("shouldWaitForLoadingOfRequestedResource-dataRequest-completion: \(url) \(completion)")
                if case let .failure(error) = completion {
                    loadingRequest.finishLoading(with: error)
                } else {
                    loadingRequest.finishLoading()
                }
                self.currentLoadingRequests.removeValue(forKey: loadingRequest)
                self.cancellables.removeValue(forKey: loadingRequest)
            } receiveValue: { data in
                self.logger.info("shouldWaitForLoadingOfRequestedResource-dataRequest-receiveValue: \(url) Length:\(data.count)")
                loadingRequest.dataRequest?.respond(with: data)
            }
            cancellables[loadingRequest] = cancellable
        }
        currentLoadingRequests[loadingRequest] = compose

        return true
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        currentLoadingRequests.first(where: { $0.key == loadingRequest })?.value.cancel()
        cancellables.first(where: { $0.key == loadingRequest })?.value.cancel()
        currentLoadingRequests.removeValue(forKey: loadingRequest)
        cancellables.removeValue(forKey: loadingRequest)

        let urlString: String
        if let url = loadingRequest.request.url {
            urlString = putBackToOriginURL(url: url).absoluteString
        } else {
            urlString = ""
        }
        logger.info("didCancel: \(urlString)")
    }
}

private extension ResourceLoader {
    func putBackToOriginURL(url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }
        components.scheme = originScheme
        return components.url ?? url
    }
}
