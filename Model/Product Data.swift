//
//  Product Data.swift
//  WishList
//
//  Created by 이유진 on 4/16/24.
//

import Foundation

struct RemoteProduct: Decodable {
    let id: Int
    let title, description: String
    let price: Double
    let discountPercentage, rating: Double?
    let stock: Int
    let brand, category: String
    let thumbnail: String
    let images: [String]
}

