//
//  Models.swift
//  InvestmentTracker
//
//  Created by 招耀華 on 1/6/2021.
//

import Foundation

struct Crypto: Codable {
    let name: String?
    let price: String?
    let price_usd: Float?
//    let last: Double?
    let asset_id: String
}

struct Icon: Codable {
    let asset_id: String
    let url: String
}
