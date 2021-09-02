//
//  Store.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 7/30/21.
//

import UIKit
import ARKit
import SpriteKit

struct ArticulatedObject {
    var links = [ArticulatedLink]()
    var joints = [JointNode]()
    
    mutating func update() {
        if self.links.count > 0 {
            for (i, _) in self.links.enumerated() {
                self.links[i].update()
            }
        }
    }
    
    func updateDrawings(spriteNode: SKSpriteNode, selectedDrawing: [SKShapeNode]) {
        for link in links {
            if link.drawings.contains(selectedDrawing[0]) {
                link.drawingsSprite.append(spriteNode)
                link.copyStartPos()
            }
        }
    }
}

//    mutating func checkJoints() {
//        for (i, _) in links.enumerated() {
//            for (j, _) in links.enumerated() {
//                if links[i].nodes.contains(where: {links[j].nodes.contains($0)}) && i != j {
//                    let jointNode = JointNode()
//                    jointNode.joint = links[i].nodes.first(where: {links[j].nodes.contains($0)})!
//                    jointNode.links.append(links[i])
//                    jointNode.links.append(links[j])
//                    links[i].joints.append(jointNode)
//                    links[j].joints.append(jointNode)
//                    return
////                    let jointNode = links[i].nodes.first(where: {links[j].nodes.contains($0)})
////                    links[i].joint.append(jointNode!)
////                    links[i].connectedLink.append(links[j])
//                }
//            }
//
//        }
//    }
//}

class ArticulatedLink: SKNode{
    var nodes = [SKShapeNode]()
    var lines = SKShapeNode()
    var drawings = [SKShapeNode]() // fixed shape
    var drawingsSprite = [SKSpriteNode]()
    var joints = [JointNode]()
    var length = CGFloat()
    var initialLength : CGFloat?
    
    var pos = CGPoint()
//    var connectedLink = [ArticulatedLink]()
    
    var drawingsSpriteInitial = [SKSpriteNode]()
    var drawingsInitial = [SKShapeNode]()
    var nodesInitial = [SKShapeNode]()
    
    var currentTime = TimeInterval()
    var timeArray10 = Array(repeating: TimeInterval(0), count: 40)
    var nodeArray10 = Array(repeating: [SKShapeNode](), count: 40)
    
    var velocity = CGVector(dx: 0, dy: 0)
    var angularVelocity = CGFloat(0)
    
    var label = SKLabelNode()
    
    func update() {
        
        // calculate speed
        currentTime = App.state.sceneView.session.currentFrame!.timestamp.magnitude
        timeArray10.removeFirst()
        timeArray10.append(currentTime)
        
        var nodesCopy = [SKShapeNode]()
        for node in nodes {
            nodesCopy.append(node.copy() as! SKShapeNode)
        }
        nodeArray10.removeFirst()
        nodeArray10.append(nodesCopy)
        
        if timeArray10.first != 0 {
            calculateVelocity()
        }
        
        // calculation end
        
        let path = CGMutablePath()
        path.move(to: nodes.first!.position)
        for node in nodes {
            path.addLine(to: node.position)
        }
        lines.path = path.copy(dashingWithPhase: 1, lengths: [4.0, 4.0])
        
        length = Scene().distanceCGPoints(nodes.first!.position, nodes.last!.position)
        if initialLength == nil {
            initialLength = length
        }
        
        if drawings.count > 0 {
            updateDrawings()
        }
        
        if joints.count > 0 {
            updateJointProperty()
        }
    }
    
    func addLine() {
        App.state.scene.removeChildren(in: [lines])

        let path = CGMutablePath()
        path.move(to: nodes.first!.position)
        for node in nodes {
            path.addLine(to: node.position)
        }
        
//        let dashedPath = path.copy(dashingWithPhase: 1, lengths: [4.0, 4.0])
        lines = SKShapeNode(path: path)
        lines.path = lines.path?.copy(dashingWithPhase: 2, lengths: [10.0, 10.0])
        lines.strokeColor = .white
        lines.lineWidth = 8
        
        
        
        App.state.scene.addChild(lines)
    }
    
    func copyStartPos() {
        nodesInitial.removeAll()
        drawingsInitial.removeAll()
        drawingsSpriteInitial.removeAll()
        for node in self.nodes {
            self.nodesInitial.append(node.copy() as! SKShapeNode)
        }
        for drawing in self.drawings {
            self.drawingsInitial.append(drawing.copy() as! SKShapeNode)
        }
        for drawing in drawingsSprite {
            drawingsSpriteInitial.append(drawing.copy() as! SKSpriteNode)
        }
        
    }
    
    func updateDrawings() {
        
        let rotationAng = -calculateRotationAngle(start: self.nodesInitial, end: self.nodes)
        let scale = length / initialLength!
//        let scale = CGFloat(1)
        
        guard let _ = self.drawings.first else { return }
        for (i, _) in self.drawings.enumerated() {
            self.drawings[i].strokeColor = App.state.strokeColor
//            self.drawings[i].physicsBody = SKPhysicsBody(edgeChainFrom: self.drawings[i].path!)
//            self.drawings[i].physicsBody = SKPhysicsBody(polygonFrom: self.drawings[i].path!)
            
            let midInitialX = (self.nodesInitial.first!.position.x + self.nodesInitial.last!.position.x)/2
            let midInitialY = (self.nodesInitial.first!.position.y + self.nodesInitial.last!.position.y)/2
            
            let dx = self.drawingsInitial[i].position.x - midInitialX
            let dy = self.drawingsInitial[i].position.y - midInitialY
            
            let dxNow = cos(rotationAng)*dx - sin(rotationAng)*dy
            let dyNow = sin(rotationAng)*dx + cos(rotationAng)*dy
            
            let midX = (self.nodes.first!.position.x + self.nodes.last!.position.x)/2
            let midY = (self.nodes.first!.position.y + self.nodes.last!.position.y)/2

            self.drawings[i].position.x = midX + dxNow * scale
            self.drawings[i].position.y = midY + dyNow * scale
            
            self.drawings[i].zRotation = rotationAng
            
            self.drawings[i].xScale = scale
            self.drawings[i].yScale = scale
        }
        
        guard let _ = self.drawingsSprite.first else { return }
        for (i, _) in drawingsSprite.enumerated() {
            let midInitialX = (self.nodesInitial.first!.position.x + self.nodesInitial.last!.position.x)/2
            let midInitialY = (self.nodesInitial.first!.position.y + self.nodesInitial.last!.position.y)/2
            
            let dx = self.drawingsSpriteInitial[i].position.x - midInitialX
            let dy = self.drawingsSpriteInitial[i].position.y - midInitialY
            
            let dxNow = cos(rotationAng)*dx - sin(rotationAng)*dy
            let dyNow = sin(rotationAng)*dx + cos(rotationAng)*dy
            
            let midX = (self.nodes.first!.position.x + self.nodes.last!.position.x)/2
            let midY = (self.nodes.first!.position.y + self.nodes.last!.position.y)/2

            self.drawingsSprite[i].position.x = midX + dxNow * scale
            self.drawingsSprite[i].position.y = midY + dyNow * scale
                    
            self.drawingsSprite[i].zRotation = rotationAng
        }
    }
    
    func calculateVelocity() {
        let num = CGFloat(nodeArray10.count)
        let t1 = timeArray10[0...(Int(num/2)-1)]
        let t2 = timeArray10[Int(num/2)...(Int(num)-1)]
        let t1avg = t1.reduce(0, +)/Double(t1.count)
        let t2avg = t2.reduce(0, +)/Double(t2.count)
        let dt = t2avg - t1avg
        
        let node1 = nodeArray10[0...(Int(num/2)-1)]
        let node2 = nodeArray10[Int(num/2)...(Int(num)-1)]
        
        var x1 = CGFloat(0)
        var x2 = CGFloat(0)
        var y1 = CGFloat(0)
        var y2 = CGFloat(0)
        for node in node1 {
            x1 += node[0].position.x
            y1 += node[0].position.y
            x2 += node[1].position.x
            y2 += node[1].position.y
        }
        let node1x1 = x1/(num/2)
        let node1y1 = y1/(num/2)
        let node1x2 = x2/(num/2)
        let node1y2 = y2/(num/2)
        
        x1 = 0
        x2 = 0
        y1 = 0
        y2 = 0
        for node in node2 {
            x1 += node[0].position.x
            y1 += node[0].position.y
            x2 += node[1].position.x
            y2 += node[1].position.y
        }
        
        let node2x1 = x1/(num/2)
        let node2y1 = y1/(num/2)
        let node2x2 = x2/(num/2)
        let node2y2 = y2/(num/2)
        
        let v1x = (node2x1 - node1x1)/CGFloat(dt)
        let v1y = (node2y1 - node1y1)/CGFloat(dt)
        let v2x = (node2x2 - node1x2)/CGFloat(dt)
        let v2y = (node2y2 - node1y2)/CGFloat(dt)
        
        velocity.dx = (v1x + v2x)/2
        velocity.dy = (v1y + v2y)/2
        
        let velocityDiff = CGVector(dx: v1x-v2x, dy: v1y-v2y)
        let velocityDiffVal = sqrt(pow(velocityDiff.dx, 2) + pow(velocityDiff.dx, 2))
        var linkLength = CGFloat(0)
        linkLength = sqrt(pow(nodes[0].position.x-nodes[1].position.x, 2)+pow(nodes[0].position.y-nodes[1].position.y, 2))
        let flag1 = (node1x1 > node1x2) ? 1 : -1
        let flag2 = (v1y > v2y) ? 1 : -1
        angularVelocity = velocityDiffVal/linkLength * CGFloat(flag1*flag2)
        let angV = angularVelocity*180 / .pi
        
        pos = (nodes[0].position + nodes[1].position) / 2
        
        label.position = pos
        label.text = String(format: "v: (%.0f, %.0f), angV: %.1f", velocity.dx, velocity.dy, angV)
        label.fontSize = 20
        label.fontColor = .red
    }
    
    func updateJointProperty() {
        for joint in joints {
            joint.updateAngle()
        }
    }
}



