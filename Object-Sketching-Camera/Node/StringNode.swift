//
//  StringNode.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 8/17/21.
//

import UIKit
import SpriteKit
import ARKit

class StringNode: SKNode {
    var bodyA: SKNode?
    var bodyB: SKNode?
    
    var anchorA: CGPoint?
    var anchorB: CGPoint?
    
    var anchorInA: CGPoint?
    var anchorInB: CGPoint?
    
    var stringNode: SKShapeNode?
    
    func setup() {
        anchorInA = bodyA?.parent?.convert(anchorA!, to: bodyA!)
        anchorInB = bodyB?.parent?.convert(anchorB!, to: bodyB!)
        stringNode = SKShapeNode()
        
        stringNode?.lineWidth = 3
        stringNode?.strokeColor = App.state.strokeColor
        
        stringNode?.name = "string"
        
        update()
    }
    
    func update() {
        let anchorANew = bodyA?.parent?.convert(anchorInA!, from: bodyA!)
        let anchorBNew = bodyB?.parent?.convert(anchorInB!, from: bodyB!)
        
        let path = CGMutablePath()
        path.move(to: anchorANew!)
        path.addLine(to: anchorBNew!)
        
        stringNode?.path = path
    }
}
