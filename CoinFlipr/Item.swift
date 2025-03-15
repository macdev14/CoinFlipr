//
//  Item.swift
//  CoinFlipr
//
//  Created by Lauro Pimentel on 15/03/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
