//
//  Item.swift
//  FlipMaster
//
//  Created by Lauro Pimentel on 03/03/25.
//

import Foundation
import SwiftData

@Model
class Item {
    var timestamp: Date
    var result: String // "Heads" or "Tails"

    init(timestamp: Date, result: String) {
        self.timestamp = timestamp
        self.result = result
    }
}
