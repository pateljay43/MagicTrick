//
//  Float.swift
//  MagicTrick
//
//  Created by JAY PATEL on 1/27/18.
//  Copyright © 2018 Jay. All rights reserved.
//

import Foundation

extension Float {
    
    // Check if a float value is inside min, max values
    func isInside(range: (Float, Float)) -> Bool {
        let min = range.0
        let max = range.1
        
        return self >= min && self <= max
    }
}
