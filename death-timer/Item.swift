//
//  Item.swift
//  death-timer
//
//  Created by Ali Siddique on 11/12/24.
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
