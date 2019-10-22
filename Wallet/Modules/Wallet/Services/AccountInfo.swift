//
//  AccountInfo.swift
//  Wallet
//
//  Created by Jakub Tomanik on 22/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AccountInfo: AccountInfoProvider {

    private let network: NetworkRequestProvider

    init(network: NetworkRequestProvider) {
        self.network = network
    }

    func fetch(for accountName: String) -> Observable<EOSAccountResponse> {
        let endpoint = "https://api.eosnewyork.io/v1/chain/get_account"
        guard let endpointURL = URL(string: endpoint) else {
            return Observable.empty()
        }

        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = "{\"account_name\":\"\(accountName)\"}".data(using: String.Encoding.utf8)


        return network.request(request)
            .map { self.transform($0) }
            .filterNil()
    }

    fileprivate func transform(_ data: Data) -> EOSAccountResponse? {
        let jsonDecoder = JSONDecoder()
        let result = try? jsonDecoder.decode(EOSAccountResponse.self, from: data)
        return result
    }
}
