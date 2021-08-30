//
//  Scene.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 7/26/21.
//

import SpriteKit
import ARKit
import UIKit
import Charts

class Scene: SKScene, SKPhysicsContactDelegate {
    
    var drawPathArray = [CGPoint]()
    var lineTemp = SKShapeNode()
    var pathTemp = CGMutablePath()
    var startTime: TimeInterval!

    var shootBall = [CGVector]()
    var shootBallPos = [CGPoint]()
    
    
    override func didMove(to view: SKView) {
//        view.addSubview(App.state.graphSubview)
//        App.state.graphSubview.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 150))
//        App.state.graphSubview.backgroundColor = .white
//        App.state.graphSubview.center = convertPoint(toView: CGPoint.zero)
//        App.state.graphSubview.isHidden = true
        physicsWorld.contactDelegate = self

    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactPoint = contact.contactPoint
        let contactNormal = contact.contactNormal
        let bodyACenter = CGPoint(x: contact.bodyA.node!.frame.midX, y: contact.bodyA.node!.frame.midY)
        let bodyBCenter = CGPoint(x: contact.bodyB.node!.frame.midX, y: contact.bodyB.node!.frame.midY)
        
        let vecA = CGVector(dx: bodyACenter.x - contactPoint.x, dy: bodyACenter.y - contactPoint.y)
        let vecB = CGVector(dx: bodyBCenter.x - contactPoint.x, dy: bodyBCenter.y - contactPoint.y)
        
        var appliedImpulseA: CGVector
        var appliedImpulseB: CGVector
        if vecA*contactNormal > 0 {
            appliedImpulseA = sqrt(vecA*vecA) * contactNormal
            appliedImpulseB = -sqrt(vecB*vecB) * contactNormal
        } else {
            appliedImpulseA = -1 * sqrt(vecA*vecA) * contactNormal
            appliedImpulseB = sqrt(vecB*vecB) * contactNormal
        }
        
        if !App.state.shootBall && App.state.bounceMax {
            contact.bodyA.node?.physicsBody?.applyImpulse(appliedImpulseA)
            contact.bodyB.node?.physicsBody?.applyImpulse(appliedImpulseB)
        }
        
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let sceneView = self.view as? ARSKView else { return }
        guard let touchPoint = touches.first?.location(in: self) else { return }
        drawPathArray.append(touchPoint)
        pathTemp.move(to: touchPoint)
        
        if App.state.keyframeState == App.state.KEYFRAME_ADD {
            keyframeAddFinalStateTouchesBegan(touches)
        }

        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self) else { return }
        
        drawPathArray.append(touchPoint)
        
        pathTemp.addLine(to: touchPoint)
        self.removeChildren(in: [lineTemp])
        lineTemp.path = pathTemp
        lineTemp.strokeColor = .white
        lineTemp.lineWidth = App.state.lineWidth
        self.addChild(lineTemp)
        
        if App.state.keyframeState == App.state.KEYFRAME_ADD {
            keyframeAddFinalStateTouchesMoved(touches)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        self.removeChildren(in: [lineTemp])
        
        if App.state.drawPhysicalObject {
            let pathShape = CGMutablePath()
            pathShape.move(to: drawPathArray[0])
            for point in drawPathArray {
                pathShape.addLine(to: point)
            }
            
            let shape = SKShapeNode(path: pathShape)
            shape.physicsBody = SKPhysicsBody(polygonFrom: shape.path!)
//            shape.fillColor = .darkGray
            shape.alpha = 1
            shape.strokeColor = App.state.strokeColor
            shape.lineWidth = App.state.lineWidth
            
            if App.state.drawStaticObject {
                shape.physicsBody = SKPhysicsBody(edgeLoopFrom: shape.path!)
            }
            
            self.addChild(shape)
            App.state.environment.drawings.append(shape)
            App.state.drawingNodes.append(shape)
            
            pathTemp = CGMutablePath()
            drawPathArray.removeAll()
            
            return
        }
        
        if App.state.shootBall {
            let start = drawPathArray.first
            shootBallPos.append(start!)
            
            let end = drawPathArray.last
            var vec = CGVector(dx: end!.x - start!.x, dy: end!.y - start!.y)
            let len = sqrt(pow(vec.dx, 2) + pow(vec.dy, 2))
            vec.dx = vec.dx / len
            vec.dy = vec.dy / len
                           
            shootBall.append(vec)
            
            pathTemp = CGMutablePath()
            drawPathArray.removeAll()
            
            return
        }
        
        if App.state.isRigStart && !App.state.isRigEnd {
            let path = CGMutablePath()
            path.move(to: drawPathArray[0])
            for point in drawPathArray {
                path.addLine(to: point)
            }
            let link = ArticulatedLink()
            for node in App.state.markersArrayShapeNode {
                if path.contains(node.position) {
                    link.nodes.append(node)
                }
            }
            if link.nodes.count > 0 {
                link.addLine()
                link.update()
//                self.addChild(link.label)
                if App.state.articulatedObject.links.count > 0 {
                    for currentLink in App.state.articulatedObject.links {
                        if currentLink.nodes.contains(where: {link.nodes.contains($0)}) {
                            let jointNode = JointNode()
                            jointNode.links.append(currentLink)
                            jointNode.links.append(link)
                            jointNode.joint = currentLink.nodes.first(where: {link.nodes.contains($0)})!
                            currentLink.joints.append(jointNode)
                            link.joints.append(jointNode)
                            App.state.articulatedObject.joints.append(jointNode)
                            jointNode.setupArc()
                        }
                    }
                }
                App.state.articulatedObject.links.append(link)
                
                
            }

        }
        
        switch App.state.currentState {
        case App.state.IS_DRAWING:
            let path = CGMutablePath()
            path.move(to: drawPathArray[0])
            for point in drawPathArray {
                path.addLine(to: point)
            }
            let line = SKShapeNode(path: path)
//            line.path = path
            line.strokeColor = App.state.strokeColor
            line.lineWidth = App.state.lineWidth
//            let lineTexture = SKView().texture(from: line)
//            let lineSpriteNode = SKSpriteNode(texture: lineTexture)
//            lineSpriteNode.colorBlendFactor = 1
//            lineSpriteNode.color = .red
//            lineSpriteNode.position = CGPoint.zero
            App.state.drawingNodes.append(line)
            App.state.environment.drawings.append(line)
            self.addChild(line)
            
        case App.state.IS_BINDING:
            bindNodes(touches, with: event)
            
        case App.state.IS_KEYFRAMING:
            keyframeAnimationTouchesEnded(touches)
            
        case App.state.IS_TRIGGERING:
            triggeringTouchEnded(touches)
            
        default:
            // switch for the current state
            ()
        }
        
        pathTemp = CGMutablePath()
        drawPathArray.removeAll()
        
        
    }
    
    func buttonRig() {
        if !App.state.isRigStart {
            App.state.isRigStart = true
            App.state.environment.initialize()
        }
    }
    
    // Drawing buttons
    func buttonDraw() {
        App.state.isRigEnd = true
        App.state.currentState = App.state.IS_DRAWING
    }
    
    
    // Binding buttons
    func buttonBind() {
        App.state.currentState = App.state.IS_BINDING
        App.state.isBindingState = App.state.BINDING_STATE_FIXED
    }
    
    func buttonSpring() {
        App.state.currentState = App.state.IS_BINDING
        App.state.isBindingState = App.state.BINDING_STATE_SPRING
        
    }
    
    func buttonLimit() {
        App.state.currentState = App.state.IS_BINDING
        App.state.isBindingState = App.state.BINDING_STATE_LIMIT
    }
    
    func buttonAdd() {
        for joint in App.state.physicsJoints {
            App.state.scene.physicsWorld.remove(joint)
            App.state.scene.physicsWorld.add(joint)
        }
        for drawing in App.state.drawingNodes {
            drawing.physicsBody?.isDynamic = true
        }
    }
    
    
    // keyframe buttons
    func buttonKeyframe() {
        App.state.currentState = App.state.IS_KEYFRAMING
        App.state.keyframeState = App.state.KEYFRAME_PARAM
    }
    
    func buttonAddFinalState() {
        App.state.keyframeState = App.state.KEYFRAME_ADD
        App.state.keyframingNode.addKeyframe()
    }
    
    func buttonSwap() {
        
    }
    
    func buttonKeyframeDone() {
        App.state.keyframeState = App.state.KEYFRAME_DONE
        App.state.keyframingNode.updateWarpGeometryFinal()
        for node in App.state.keyframingNode.targetNode!.children {
            node.isHidden = true
        }
        
        App.state.keyframingNodes.append(App.state.keyframingNode)
        App.state.keyframingNode = KeyframeNode()
    }
    
    // Triggering buttons
    func buttonAnimationTrigger() {
        App.state.currentState = App.state.IS_TRIGGERING
        App.state.triggeringState = true
//        App.state.environment.update()
    }
    
    func buttonTriggerDidSet() {
        App.state.triggeringNode.triggeredDidSetup = true
        App.state.triggeringNode.inputMenu?.removeFromParent()
        App.state.triggeringState = true
    }
    
    
    func buttonReset() {
        self.removeAllChildren()
        App.state.reset()
        
        App.state.scene.physicsWorld.removeAllJoints()
        
    }
    
}
