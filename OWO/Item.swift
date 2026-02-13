//
//  Item.swift
//  OWO
//
//  Created by Katherine Palevich on 2/6/26.
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
