//
//  Shoe.swift
//  ShoeTracker
//
//  Created by Matthew Johanson on 10/03/2025.
//

import SwiftUI
import SwiftData

struct Shoe {
    var name: String // name of shoe
    var size: Int // size of shoe, default is US
    var price: Int // price of shoe
    var width: String // width of shoe - using D, 2E, 4E, 6E, 8E
    var brand: String // brand of shoe
    var color: String // color of shoe
    var category: String  // e.g., "Running", "Casual", "Formal"
    var gender: String?   // "Men's", "Women's", "Unisex"
    var material: String?
    var dateAdded: Date // the try on struct has a date field - may be redundant
}


