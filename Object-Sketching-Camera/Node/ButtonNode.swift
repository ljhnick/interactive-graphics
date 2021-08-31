//
//  ButtonNode.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 8/10/21.
//

import UIKit
import ARKit
import SpriteKit

class ButtonNode: SKNode {
    
    func initialize() {
        isUserInteractionEnabled = true
    }
}

class KeyframeButtonNode: ButtonNode {
    var link: ArticulatedLink?
    var posX: SKSpriteNode?
    var posY: SKSpriteNode?
    var ang1: SKSpriteNode?
    var ang2: SKSpriteNode?
    
    func addButtons() {
        removeAllChildren()
        isUserInteractionEnabled = true
        
        let size = CGSize(width: 50, height: 50)
        posX = SKSpriteNode(color: .lightGray, size: size)
        posY = SKSpriteNode(color: .lightGray, size: size)
        ang1 = SKSpriteNode(color: .lightGray, size: size)
        ang2 = SKSpriteNode(color: .lightGray, size: size)
        
        let posXLabel = SKLabelNode(text: "PosX")
        posXLabel.fontSize = 20
        posXLabel.fontName = "AvenirNext-Bold"
        posXLabel.position.y = -10
        posX?.addChild(posXLabel)
        
        let posYLabel = SKLabelNode(text: "PosY")
        posYLabel.fontSize = 20
        posYLabel.fontName = "AvenirNext-Bold"
        posYLabel.position.y = -10
        posY?.addChild(posYLabel)
        
        
        
        posX?.position = link!.pos
        posX?.position.x -= 25
        posX?.position.y += 0
        posY?.position = link!.pos
        posY?.position.x += 25
        posY?.position.y -= 0
        
        addChild(posX!)
        addChild(posY!)
        
        if !link!.joints.isEmpty {
            let ang1Label = SKLabelNode(text: "Ang")
            ang1Label.fontSize = 20
            ang1Label.fontName = "AvenirNext-Bold"
            ang1Label.position.y = -10
            ang1?.addChild(ang1Label)
            ang1?.position = link!.joints[0].joint.position
            addChild(ang1!)
            
            if link!.joints.count > 1 {
                let ang2Label = SKLabelNode(text: "Ang")
                ang2Label.fontSize = 20
                ang2Label.fontName = "AvenirNext-Bold"
                ang2Label.position.y = -10
                ang2?.addChild(ang2Label)
                ang2?.position = link!.joints[1].joint.position
                addChild(ang2!)
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self) else { return }
        if posX!.contains(touchPoint) {
            App.state.keyframingNode.drivingParam = App.state.keyframingNode.POS_X
        } else if posY!.contains(touchPoint) {
            App.state.keyframingNode.drivingParam = App.state.keyframingNode.POS_Y
        } else if ang1!.contains(touchPoint) {
            let link = App.state.keyframingNode.controlInput as? ArticulatedLink
            App.state.keyframingNode.controlInput = link!.joints[0]
        } else if ang2!.contains(touchPoint) {
            let link = App.state.keyframingNode.controlInput as? ArticulatedLink
            App.state.keyframingNode.controlInput = link!.joints[1]
        }
        
        App.state.scene.removeChildren(in: [App.state.keyframesButtons])

        App.state.keyframeState = App.state.KEYFRAME_CIRCLE
    }

}

class KeyframeDeformButton: ButtonNode {
    var spriteNode: SKSpriteNode?
    var rotCW: SKSpriteNode?
    var rotCCW: SKSpriteNode?
    var wipe: SKSpriteNode?
    
    func intialize() {
        isUserInteractionEnabled = true
        let size = CGSize(width: 50, height: 30)
        rotCW = SKSpriteNode(color: .lightGray, size: size)
        rotCCW = SKSpriteNode(color: .lightGray, size: size)
        wipe = SKSpriteNode(color: .lightGray, size: size)
        
        let labelCW = SKLabelNode(text: "CW")
        labelCW.fontSize = 10
        labelCW.position.y = -5
        labelCW.fontName = "AvenirNext-Bold"
        labelCW.fontColor = .white
        rotCW?.addChild(labelCW)
        
        let labelCCW = SKLabelNode(text: "CCW")
        labelCCW.fontSize = 10
        labelCCW.position.y = -5
        labelCCW.fontName = "AvenirNext-Bold"
        labelCCW.fontColor = .white
        rotCCW?.addChild(labelCCW)
        
        let labelWipe = SKLabelNode(text: "Hide")
        labelWipe.fontSize = 10
        labelWipe.position.y = -5
        labelWipe.fontName = "AvenirNext-Bold"
        labelWipe.fontColor = .white
        wipe?.addChild(labelWipe)
        
        let nodeSize = spriteNode?.size
        rotCW?.position = CGPoint(x: nodeSize!.width/2 + 20, y: 0)
        rotCCW?.position = CGPoint(x: nodeSize!.width/2 + 70, y: 0)
        wipe?.position = CGPoint(x: nodeSize!.width/2 + 20, y: 30)
        
        self.addChild(rotCCW!)
        self.addChild(rotCW!)
        self.addChild(wipe!)
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self) else { return }
        let touchPointInNode = self.convert(touchPoint, from: self)
        
        if rotCCW!.contains(touchPointInNode) {
            App.state.keyframingNode.rotateCCW()
        } else if rotCW!.contains(touchPointInNode) {
            App.state.keyframingNode.rotateCW()
        } else if wipe!.contains(touchPointInNode) {
            App.state.keyframingNode.hide()
        }
        
//        self.removeChildren(in: [rotCCW!, rotCW!])
        
        
    }
    
}
