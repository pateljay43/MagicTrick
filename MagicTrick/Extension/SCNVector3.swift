//
//  SCNVector3.swift
//  MagicTrick
//
//  Created by JAY PATEL on 1/27/18.
//  Copyright © 2018 Jay. All rights reserved.
//

import ARKit

extension SCNVector3 {
    
    // Check if a point (SCNVector) is inside two bounding box points
    func isInside(range: (SCNVector3, SCNVector3)) -> Bool {
        let min = range.0
        let max = range.1
        
        return x.isInside(range: (min.x, max.x)) &&
            y.isInside(range: (min.y, max.y)) &&
            z.isInside(range: (min.z, max.z))
    }
    
    static func - (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
}
