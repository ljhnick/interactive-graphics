//
//  Triggering.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 8/10/21.
//

import SpriteKit
import ARKit
import UIKit

extension Scene {
    
    func triggeringTouchBegan(_ touches: Set<UITouch>) {
        
    }
    
    func triggeringTouchMoved(_ touches: Set<UITouch>) {
        
    }
    
    func triggeringTouchEnded(_ touches: Set<UITouch>) {
        let startNode = SKShapeNode(circleOfRadius: 10)
        let endNode = SKShapeNode(circleOfRadius: 10)
        startNode.position = drawPathArray.first!
        endNode.position = drawPathArray.last!
        for link in App.state.articulatedObject.links {
            if link.lines.intersects(startNode) {
                
                
//                let triggerInputNode = TriggeringInputNode()
//                triggerInputNode.linkNode = App.state.articulatedObject.links[i]
//                triggerInputNode.selectedInput = TriggeringInputNode.POS_X // interaction
//                triggerInputNode.triggerType = TriggeringInputNode.PULSE
                
//                App.state.triggeringNode.inputNode.append(triggerInputNode)
                
//                if endNode.intersects(App.state.environment) {
                let touchPoint = touches.first?.location(in: App.state.environment)
//                let touchPointInNode = App.state.environment.convert(touchPoint!, from: self)
                
               if App.state.environment.gravityNode!.contains(touchPoint!) {
                    App.state.triggeringNode.outputNode = App.state.forceNode
                } else if App.state.environment.visibilityNode!.contains(touchPoint!) {
                    App.state.triggeringNode.outputNode = App.state.visibilityNode
                }
//                }
                
                for drawing in App.state.drawingNodes {
                    if drawing.parent == self && endNode.intersects(drawing){
                        App.state.triggeringNode.outputNode = App.state.physicsNode
                        self.addChild(App.state.physicsNode)
                        App.state.physicsNode.location = endNode.position
                        App.state.physicsNode.setupPhysicsJointTrigger()
                        App.state.physicsNode.drawing = drawing
                        break
                    }
                }
                
                for keyframeNode in App.state.keyframingNodes {
                    let targetNode = keyframeNode.targetNode
                    if targetNode != nil {
                        if endNode.intersects(targetNode!) {
                            App.state.triggeringNode.outputNode = keyframeNode
                            break
                        }
                    }
                }
                
                
                if App.state.triggeringNode.outputNode != nil {
                    let inputMenuNode = InputMenuNode()
                    inputMenuNode.link = link
                    inputMenuNode.addButtons()
                    App.state.triggeringNode.inputMenu = inputMenuNode
                    self.addChild(inputMenuNode)
                }
            }
            
            if App.state.physicsNode.flagAdd {
                var anchor: CGPoint
                var objA: SKNode
                var objB: SKNode
                
                for drawingNode in App.state.drawingNodes {
                    if startNode.intersects(drawingNode) {
                        for drawingNode1 in App.state.drawingNodes {
                            if endNode.intersects(drawingNode1) && drawingNode1 != drawingNode {
                                drawingNode.physicsBody = (drawingNode.physicsBody == nil) ? SKPhysicsBody(polygonFrom: drawingNode.path!) : drawingNode.physicsBody
                                objA = drawingNode
                                drawingNode1.physicsBody = (drawingNode1.physicsBody == nil) ? SKPhysicsBody(polygonFrom: drawingNode1.path!) : drawingNode1.physicsBody
                                objB = drawingNode1
                                anchor = endNode.position
                                
                                let physicsJoint = SKPhysicsJointFixed.joint(withBodyA: objA.physicsBody!, bodyB: objB.physicsBody!, anchor: anchor)
                                
                                App.state.physicsNode.physicsJoint = physicsJoint
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
}
