//
//  Int+Extensions.swift
//  GitTime
//
//  Created by Kanz on 28/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

extension Int {
    func commaString() -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf.string(from: NSNumber(value: self))!
    }
    
    // https://gist.github.com/gbitaudeau/daa4d6dc46517b450965e9c7e13706a3
    typealias Abbrevation = (threshold: Double, divisor: Double, suffix: String)
    func formatUsingAbbrevation () -> String {
        let numFormatter = NumberFormatter()
        
        let abbreviations: [Abbrevation] = [(0, 1, ""),
                                           (1000.0, 1000.0, "K"),
                                           (100_000.0, 1_000_000.0, "M"),
                                           (100_000_000.0, 1_000_000_000.0, "B")]
        // you can add more !
        let startValue = Double(abs(self))
        let abbreviation: Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if startValue < tmpAbbreviation.threshold {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        }()
        
        let value = Double(self) / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 1
        
        return numFormatter.string(from: NSNumber(value: value))!
    }
}
