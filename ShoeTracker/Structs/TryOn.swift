//
//  TryOn.swift
//  ShoeTracker
//
//  Created by Matthew Johanson on 10/03/2025.
//

import SwiftUI
import SwiftData

@Model
class TryOn {
    var id: UUID
    var name: String
    var details: String
    var rating: Double
    var purchased: Bool
    var size: String
    var date: Date
    var color: String
    var width: String
    var location: String
    
    init(id: UUID, name: String, details: String, rating: Double, purchased: Bool, size: String, date: Date, color: String, width: String, location: String) {
        self.id = id
        self.name = name
        self.details = details
        self.rating = rating
        self.purchased = purchased
        self.size = size
        self.date = date
        self.color = color
        self.width = width
        self.location = location
    }
}
