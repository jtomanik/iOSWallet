//
//  PriceFeed.swift
//  Wallet
//
//  Created by Jakub Tomanik on 22/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PriceFeed: PriceFeedProvider {

    private let network: NetworkRequestProvider

    init(network: NetworkRequestProvider) {
        self.network = network
    }

    func fetch() -> Observable<Double> {
        let feed = "https://apiv2.bitcoinaverage.com/indices/tokens/ticker/EOSUSD"
        guard let feedURL = URL(string: feed) else {
            return Observable.empty()
        }
        let request = URLRequest(url: feedURL)
        return network.request(request)
            .map { self.network.parse(json: $0) }
            .filterNil()
            .map { $0 as? [String: Any] }
            .filterNil()
            .map { self.transform(raw: $0) }
            .filterNil()
    }

    fileprivate func transform(raw feed: [String: Any]) -> Double? {
        guard let element = feed["last"],
            let value = element as? Double else {
                return nil
        }
        return value
    }
}
