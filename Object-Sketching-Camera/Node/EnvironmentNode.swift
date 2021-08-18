//
//  EnvironmentNode.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 8/10/21.
//

import UIKit
import ARKit
import SpriteKit

class EnvironmentNode: SKNode {
    var gravity: CGVector?
    
    var gravityNode: SKSpriteNode?
    var visibilityNode: SKSpriteNode?
    var forceNode: ForceNode?
    var visibilityPickerNode: VisibilityNode?
    
    var gravityLabel: SKLabelNode?
    var visibilityLabel: SKLabelNode?
    
    var gravityVal: CGFloat?
    var gravityDir: CGFloat?
    var visibility: CGFloat?
    
    var drawings = [SKShapeNode]()
    
//    var gravityNode: SKShapeNode?
    
    func initialize() {
        
//        App.state.environment = EnvironmentNode()
        isUserInteractionEnabled = true
        
        forceNode = App.state.forceNode
        forceNode?.setupForce()
        visibilityPickerNode = App.state.visibilityNode
        visibilityPickerNode?.setupVisiblitySlider()
        
        
        let size = CGSize(width: 100, height: 40)
        gravityNode = SKSpriteNode(color: .darkGray, size: size)
        visibilityNode = SKSpriteNode(color: .darkGray, size: size)
        
        gravityLabel = SKLabelNode(text: "Gravity")
        visibilityLabel = SKLabelNode(text: "Visibility")
        
        gravityLabel?.position = CGPoint(x: 0, y: -10)
        visibilityLabel?.position = CGPoint(x: 0, y: -10)
        
        visibilityNode?.position.y = -50
        
        gravityNode?.addChild(gravityLabel!)
        visibilityNode?.addChild(visibilityLabel!)
        
        gravityNode?.addChild(forceNode!)
        forceNode?.position.x = 80
        forceNode?.position.y = 30
        
        visibilityNode?.addChild(visibilityPickerNode!)
        
        App.state.environment.addChild(gravityNode!)
        App.state.environment.addChild(visibilityNode!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self) else { return }
        let touchPointInNode = self.convert(touchPoint, from: self)
        
        if gravityNode!.contains(touchPointInNode) {
            changeGravity()
        }
    }
    
    func update() {
//        gravityVal = sqrt(pow(gravity!.dx, 2) + pow(gravity!.dy, 2))
//        gravityDir = atan2(gravity!.dy, gravity!.dx)
    }
    
    func changeGravity() {
        print("change gravity")
    }
    
}
