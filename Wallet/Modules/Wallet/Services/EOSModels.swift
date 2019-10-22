//
//  EOSModels.swift
//  Wallet
//
//  Created by Jakub Tomanik on 22/10/2019.
//  Copyright © 2019 Jakub Tomanik. All rights reserved.
//

import Foundation

public enum EOSInt64: Codable {
    case int64(Int64)
    case string(String)

    public var value: Int64 {
        switch self {
        case .int64(let value):
            return value
        case .string(let str):
            let val: Int64? = Int64(str)
            return val ?? 0
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = try .int64(container.decode(Int64.self))
        } catch DecodingError.typeMismatch {
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(EOSInt64.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int64(let int64):
            try container.encode(int64)
        case .string(let string):
            try container.encode(string)
        }
    }
}

struct EOSTotalResourcesResponse: Decodable {
    var netWeight: String = ""
    var cpuWeight: String = ""
    var ramBytes: EOSInt64 = EOSInt64.int64(0)

    enum CodingKeys: String, CodingKey {
        case netWeight = "net_weight"
        case cpuWeight = "cpu_weight"
        case ramBytes = "ram_bytes"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        netWeight = try container.decodeIfPresent(String.self, forKey: .netWeight) ?? ""
        cpuWeight = try container.decodeIfPresent(String.self, forKey: .cpuWeight) ?? ""
        ramBytes = try container.decodeIfPresent(EOSInt64.self, forKey: .ramBytes) ?? EOSInt64.int64(0)
    }
}

struct EOSLimitResponse: Decodable {
    var used: EOSInt64 = EOSInt64.int64(0)
    var available: EOSInt64 = EOSInt64.int64(0)
    var max: EOSInt64 = EOSInt64.int64(0)

    enum CodingKeys: String, CodingKey {
        case used
        case available
        case max
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        used = try container.decodeIfPresent(EOSInt64.self, forKey: .used) ?? EOSInt64.int64(0)
        available = try container.decodeIfPresent(EOSInt64.self, forKey: .available) ?? EOSInt64.int64(0)
        max = try container.decodeIfPresent(EOSInt64.self, forKey: .max) ?? EOSInt64.int64(0)
    }
}

struct EOSAccountResponse: Decodable {
    var accountName: String
    var coreLiquidBalance: String = ""
    var ramQuota: EOSInt64 = EOSInt64.int64(0)
    var netWeight: EOSInt64 = EOSInt64.int64(0)
    var cpuWeight: EOSInt64 = EOSInt64.int64(0)
    var netLimit: EOSLimitResponse
    var cpuLimit: EOSLimitResponse
    var ramUsage: EOSInt64 = EOSInt64.int64(0)
    var totalResources: EOSTotalResourcesResponse?

    enum CodingKeys: String, CodingKey {
        case accountName = "account_name"
        case coreLiquidBalance = "core_liquid_balance"
        case ramQuota = "ram_quota"
        case netWeight = "net_weight"
        case cpuWeight = "cpu_weight"
        case netLimit = "net_limit"
        case cpuLimit = "cpu_limit"
        case ramUsage = "ram_usage"
        case totalResources = "total_resources"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        accountName = try container.decode(String.self, forKey: .accountName)
        coreLiquidBalance = try container.decodeIfPresent(String.self, forKey: .coreLiquidBalance) ?? ""
        ramQuota = try container.decodeIfPresent(EOSInt64.self, forKey: .ramQuota) ?? EOSInt64.int64(0)
        netWeight = try container.decodeIfPresent(EOSInt64.self, forKey: .netWeight) ?? EOSInt64.int64(0)
        cpuWeight = try container.decodeIfPresent(EOSInt64.self, forKey: .cpuWeight) ?? EOSInt64.int64(0)

        netLimit = try container.decode(EOSLimitResponse.self, forKey: .netLimit)
        cpuLimit = try container.decode(EOSLimitResponse.self, forKey: .cpuLimit)

        ramUsage = try container.decodeIfPresent(EOSInt64.self, forKey: .ramUsage) ?? EOSInt64.int64(0)
        totalResources = try container.decodeIfPresent(EOSTotalResourcesResponse.self, forKey: .totalResources)
    }
}
