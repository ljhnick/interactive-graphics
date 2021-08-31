//
//  AnnotationNode.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 8/2/21.
//

import UIKit
import ARKit
import SpriteKit

class JointNode: SKNode {
    var links = [ArticulatedLink]()
    var joint = SKShapeNode()
    var angle = CGFloat()
    var arc: SKShapeNode?
    
    func updateAngle() {
        let link1 = links[0]
        let link2 = links[1]
        
        let posJoint = joint.position
        let posLink1 = (link1.nodes[0].position + link1.nodes[1].position) / 2
        let posLink2 = (link2.nodes[0].position + link2.nodes[1].position) / 2
        
        let link1Vec = CGVector(dx: posLink1.x-posJoint.x, dy: posLink1.y-posJoint.y)
        let link2Vec = CGVector(dx: posLink2.x-posJoint.x, dy: posLink2.y-posJoint.y)
        
        let ang1 = (atan2(link1Vec.dy, link1Vec.dx) >= 0) ? atan2(link1Vec.dy, link1Vec.dx) : 2 * .pi + atan2(link1Vec.dy, link1Vec.dx)
        
        let ang2 = (atan2(link2Vec.dy, link2Vec.dx) >= 0) ? atan2(link2Vec.dy, link2Vec.dx) : 2 * .pi + atan2(link2Vec.dy, link2Vec.dx)
        
        let ang = ang1 - ang2
        
        var cwFlag = true
        
        if ang2 > .pi && ang1 < .pi {
            cwFlag = ang > 0
        } else {
            cwFlag = ang < 0
        }
        
        
        let arcPath = UIBezierPath(arcCenter: CGPoint.zero, radius: 20, startAngle: ang1, endAngle: ang2, clockwise: cwFlag)
        arc?.path = arcPath.cgPath
        
        angle = abs(ang)
        
    }
    
    func setupArc() {
        let link1 = links[0]
        let link2 = links[1]
        
        let centerPos = joint.position
        let link1Pos = (link1.nodes[0].position + link1.nodes[1].position) / 2
        let link2Pos = (link2.nodes[0].position + link2.nodes[1].position) / 2
        
        var ang1 = atan2(link1Pos.y - centerPos.y, link1Pos.x - centerPos.x)
        var ang2 = atan2(link2Pos.y - centerPos.y, link2Pos.x - centerPos.x)
        
        ang1 = (ang1 >= 0) ? ang1 : ang1 + 2 * .pi
        ang2 = (ang2 >= 0) ? ang2 : ang2 + 2 * .pi
        
        let arcPath = UIBezierPath(arcCenter: CGPoint.zero, radius: 20, startAngle: ang1, endAngle: ang2, clockwise: true)
        
        
        arc = SKShapeNode(path: arcPath.cgPath)
        arc?.lineWidth = 8
        arc?.strokeColor = .darkGray
        
        joint.addChild(arc!)
    }
    
}
