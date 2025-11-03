//
//  GeneralizedTime+.swift
//  swift-macho
//
//  Created by jon on 10/31/25.
//

import SwiftASN1


extension GeneralizedTime {
    public var stringValue: String {
        "\(year.description)/\(month.description)/\(day.description) \(hours.description):\(minutes.description):\(seconds.description).\(fractionalSeconds.description)"
    }
}
