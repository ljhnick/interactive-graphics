//
//  PhysicsJointNode.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 8/11/21.
//

import UIKit
import ARKit
import SpriteKit

class PhysicsJointNode: TriggeringOutputNode {
    
    var controlInputU: Double?
    
    var drawing: SKShapeNode?
    var physicsJoint: SKPhysicsJoint?
    
    var location: CGPoint?
    
    var hide: SKSpriteNode?
    var add: SKSpriteNode?
    var done: SKSpriteNode?
    
    var flagAdd = false
    var flagHide = false
    
    func setupPhysicsJointTrigger() {
        
        self.removeAllChildren()
        
        isUserInteractionEnabled = true
        
        let size = CGSize(width: 50, height: 30)
        hide = SKSpriteNode(color: .lightGray, size: size)
        add = SKSpriteNode(color: .lightGray, size: size)
        done = SKSpriteNode(color: .lightGray, size: size)
        
        let labelHide = SKLabelNode(text: "hide")
        let labelAdd = SKLabelNode(text: "add")
        let labelDone = SKLabelNode(text: "done")
        
        labelHide.fontSize = 15
        labelAdd.fontSize = 15
        labelDone.fontSize = 15
        
        labelHide.position.y = -7.5
        labelAdd.position.y = -7.5
        labelDone.position.y = -7.5
        
        hide?.addChild(labelHide)
        add?.addChild(labelAdd)
        done?.addChild(labelDone)
        
        add?.position.x = -30
        done?.position.x = 30
        
        self.addChild(hide!)
        self.addChild(add!)
        self.addChild(done!)
        
        self.position = location!
    }
    
    func updatePhysicsJoint() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first?.location(in: self) else { return }
        if hide!.contains(touch) {
            flagHide = true
            flagAdd = false
            physicsJoint = drawing?.physicsBody?.joints.first
            
        } else if add!.contains(touch) {
            flagHide = false
            flagAdd = true
        } else if done!.contains(touch) {
            self.removeAllChildren()
        }
    }
    
    override func setOutputData1() {
        
    }
    
    override func setOutputData2() {
        
    }
    
    func interpolatePhysicsJoint() {
        if flagAdd {
            if controlInputU != 0 {
                App.state.scene.physicsWorld.remove(physicsJoint!)
                App.state.scene.physicsWorld.add(physicsJoint!)
            } else {
                App.state.scene.physicsWorld.remove(physicsJoint!)
            }
        } else if flagHide {
            if controlInputU != 0 {
                App.state.scene.physicsWorld.remove(physicsJoint!)
                let node = App.state.scene.childNode(withName: "string")
                App.state.scene.removeChildren(in: [node!])
            } else {
//
//                do {
//                    try App.state.scene.physicsWorld.add(physicsJoint!)
//                } catch {
//                    ()
//                }
//                App.state.scene.physicsWorld.remove(physicsJoint!)
//                App.state.scene.physicsWorld.add(physicsJoint!)
            }
        }
        
        print(controlInputU)
        
        
    }
    
    
}
