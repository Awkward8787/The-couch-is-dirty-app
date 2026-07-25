//
//  Item.swift
//  The Couch is Dirty podcast app
//
//  Created by Anthony Jones on 7/25/26.
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
