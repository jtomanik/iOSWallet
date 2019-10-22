//
//  MockEOSAccountCardModel.swift
//  Wallet
//
//  Created by Jakub Tomanik on 22/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation

func mockEOSAccountCardModel() -> EOSAccountCardModel {
    return EOSAccountCardModel(
        name: "jakubtomanik",
        balance: "19.81 EOS",
        value: "≈ 99 $",
        net: EOSAccountCardModel.Resource(name: "NET",
                                          utilisation: "0%",
                                          value: 0,
                                          used: "281 bytes",
                                          available: "148 KB",
                                          staked: "0.2000 EOS"),
        cpu: EOSAccountCardModel.Resource(name: "CPU",
                                          utilisation: "0%",
                                          value: 0,
                                          used: "280 us",
                                          available: "106.798 ms",
                                          staked: "0.8000 EOS"),
        ram: EOSAccountCardModel.Resource(name: "RAM",
                                          utilisation: "68%",
                                          value: 68,
                                          used: "3.02 KB",
                                          available: "4.39 KB",
                                          staked: nil))
}
