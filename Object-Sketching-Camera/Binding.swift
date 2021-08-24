//
//  Binding.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 8/7/21.
//

import SpriteKit
import ARKit
import UIKit

extension Scene {
    
    func bindNodes(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch App.state.isBindingState {
        case App.state.BINDING_STATE_FIXED:
            let pathNodeTemp = SKShapeNode(circleOfRadius: 1)
            pathNodeTemp.position = drawPathArray.last!
            let pathNodeTempStart = SKShapeNode(circleOfRadius: 20)
            pathNodeTempStart.position = drawPathArray.first!
            for (i, link) in App.state.articulatedObject.links.enumerated() {
                let line = link.lines
                if pathNodeTemp.intersects(line) {
                    for drawing in App.state.drawingNodes {
                        if pathNodeTempStart.intersects(drawing) {
                            App.state.articulatedObject.links[i].drawings.append(drawing)
                            drawing.physicsBody = SKPhysicsBody(edgeLoopFrom: drawing.path!)
                            drawing.physicsBody?.contactTestBitMask = drawing.physicsBody!.collisionBitMask
                            drawing.physicsBody?.isDynamic = false
                            
                            App.state.environment.drawings.removeAll(where: {$0 == drawing})
//                                App.state.drawingNodes.removeAll(where: {$0 == drawing})
                        }
                    }
                    App.state.articulatedObject.links[i].copyStartPos()
                    break
                }
            }
        case App.state.BINDING_STATE_SPRING:
            let endPoint = SKShapeNode(circleOfRadius: 1)
            let startPoint = SKShapeNode(circleOfRadius: 1)
            endPoint.position = drawPathArray.last!
            startPoint.position = drawPathArray.first!
            var anchorA: CGPoint
            var anchorB: CGPoint
            var objA: SKNode
            var objB: SKNode
            for drawingNode in App.state.drawingNodes {
                if startPoint.intersects(drawingNode) {
                    anchorA = startPoint.position
                    drawingNode.physicsBody = (drawingNode.physicsBody == nil) ? SKPhysicsBody(polygonFrom: drawingNode.path!) : drawingNode.physicsBody
                    drawingNode.physicsBody?.isDynamic = false
                    drawingNode.physicsBody?.contactTestBitMask = drawingNode.physicsBody!.collisionBitMask
                    objA = drawingNode
                    
                    for link in App.state.articulatedObject.links {
                        let drawings = link.drawings
                        for drawing in drawings {
                            if endPoint.intersects(drawing) {
                                anchorB = endPoint.position
                                drawing.physicsBody = (drawing.physicsBody == nil) ? SKPhysicsBody(edgeChainFrom: drawing.path!) : drawing.physicsBody
                                drawing.physicsBody?.contactTestBitMask = drawing.physicsBody!.collisionBitMask
                                objB = drawing
                                let physicsJoint = SKPhysicsJointSpring.joint(withBodyA: objA.physicsBody!, bodyB: objB.physicsBody!, anchorA: anchorA, anchorB: anchorB)
                                physicsJoint.damping = 0.2
                                physicsJoint.frequency = 1
                                print(anchorA)
                                print(drawing.frame.minX)
                                
                                App.state.physicsJoints.append(physicsJoint)
                                
                                let string = StringNode()
                                string.bodyA = objA
                                string.bodyB = objB
                                string.anchorA = anchorA
                                string.anchorB = anchorB
                                
                                string.setup()
                                self.addChild(string.stringNode!)
                                
                                App.state.stringInJoints.append(string)
                                return
                            }
                        }
                    }
                    
                    for drawing in App.state.drawingNodes {
                        if endPoint.intersects(drawing) {
                            anchorB = endPoint.position
                            drawing.physicsBody = (drawing.physicsBody == nil) ? SKPhysicsBody(edgeChainFrom: drawing.path!) : drawing.physicsBody
                            drawing.physicsBody?.contactTestBitMask = drawing.physicsBody!.collisionBitMask
                            objB = drawing
                            let physicsJoint = SKPhysicsJointSpring.joint(withBodyA: objA.physicsBody!, bodyB: objB.physicsBody!, anchorA: anchorA, anchorB: anchorB)
                            physicsJoint.damping = 0.2
                            physicsJoint.frequency = 1
                            print(anchorA)
                            print(drawing.frame.minX)
                            
                            App.state.physicsJoints.append(physicsJoint)
                            
                            let string = StringNode()
                            string.bodyA = objA
                            string.bodyB = objB
                            string.anchorA = anchorA
                            string.anchorB = anchorB
                            
                            string.setup()
                            self.addChild(string.stringNode!)
                            
                            App.state.stringInJoints.append(string)
                            break
                        }
                    }
                    
                    
                }
            }
            
        case App.state.BINDING_STATE_LIMIT:
            let endPoint = SKShapeNode(circleOfRadius: 1)
            let startPoint = SKShapeNode(circleOfRadius: 1)
            endPoint.position = drawPathArray.last!
            startPoint.position = drawPathArray.first!
            var anchorA: CGPoint
            var anchorB: CGPoint
            var objA: SKNode
            var objB: SKNode
            for drawingNode in App.state.drawingNodes {
                if startPoint.intersects(drawingNode) {
                    anchorA = startPoint.position
                    drawingNode.physicsBody = (drawingNode.physicsBody == nil) ? SKPhysicsBody(polygonFrom: drawingNode.path!) : drawingNode.physicsBody
                    drawingNode.physicsBody?.isDynamic = false
                    drawingNode.physicsBody?.contactTestBitMask = drawingNode.physicsBody!.collisionBitMask
                    objA = drawingNode
                    
                    for link in App.state.articulatedObject.links {
                        let drawings = link.drawings
                        for drawing in drawings {
                            if endPoint.intersects(drawing) {
                                anchorB = endPoint.position
                                drawing.physicsBody = (drawing.physicsBody == nil) ? SKPhysicsBody(edgeChainFrom: drawing.path!) : drawing.physicsBody
                                drawing.physicsBody?.contactTestBitMask = drawing.physicsBody!.collisionBitMask
                                objB = drawing
                                let physicsJoint = SKPhysicsJointLimit.joint(withBodyA: objA.physicsBody!, bodyB: objB.physicsBody!, anchorA: anchorA, anchorB: anchorB)
                                physicsJoint.maxLength = distanceCGPoints(startPoint.position, endPoint.position) + 20
                                print(anchorA)
                                print(drawing.frame.minX)
                                
                                App.state.physicsJoints.append(physicsJoint)
                                
                                let string = StringNode()
                                string.bodyA = objA
                                string.bodyB = objB
                                string.anchorA = anchorA
                                string.anchorB = anchorB
                                
                                string.setup()
                                self.addChild(string.stringNode!)
                                
                                App.state.stringInJoints.append(string)
                                
                                break
                            }
                        }
                    }
                }
            }
            
        default:
            // switch for the state of binding
            ()
        }
    }
}
