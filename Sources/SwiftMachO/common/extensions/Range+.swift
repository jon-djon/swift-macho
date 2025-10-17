//
//  Range+.swift
//  swift-macho
//
//  Created by jon on 10/15/25.
//

import Foundation

extension Range<Int> {
    public var hexDescription: String {
        "\(lowerBound.hexDescription) - \(upperBound.hexDescription)"
    }
}
