//
//  Ball.swift
//  MagicTrick
//
//  Created by JAY PATEL on 1/27/18.
//  Copyright © 2018 Jay. All rights reserved.
//

import UIKit
import ARKit

extension SCNNode {
    
    // Apply force to this node
    func applyForce(_ force: SCNVector4, from camera: ARCamera?) {
        if let cameraTransform = camera?.transform {
            let rotatedForce = simd_mul(cameraTransform, force.simd)
            let directionalForce = SCNVector3(x:rotatedForce.x, y:rotatedForce.y, z:rotatedForce.z)
            self.physicsBody?.applyForce(directionalForce, asImpulse: true)
        }
    }
    
    func applyTransformation(from camera: ARCamera?) {
        let cameraTransform = camera?.transform
        simdTransform = cameraTransform!
    }
    
    // Check if this node is inside another node's bounding box
    func isInside(node: SCNNode) -> Bool {
        let position = self.presentation.worldPosition
        
        // calculate size of node
        var (min, max) = (node.presentation.boundingBox)
        let size = max - min
        
        // adjust x, y, z of min and max using size of the node
        min = SCNVector3((node.presentation.worldPosition.x) - size.x/2,
                         (node.presentation.worldPosition.y),
                         (node.presentation.worldPosition.z) - size.z/2)
        
        max = SCNVector3((node.presentation.worldPosition.x) + size.x/2,
                                       (node.presentation.worldPosition.y) + size.y,
                                       (node.presentation.worldPosition.z) + size.z/2)
        
        return position.isInside(range: (min, max))
    }
}
