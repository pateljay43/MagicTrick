//
//  SCNVector4.swift
//  MagicTrick
//
//  Created by JAY PATEL on 1/27/18.
//  Copyright © 2018 Jay. All rights reserved.
//

import ARKit

extension SCNVector4 {
    
    // Convert vector to simd_float4
    var simd: simd_float4 {
        return simd_make_float4(x, y, z, w)
    }
    
}
