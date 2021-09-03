//
//  TriggerMenuNode.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 8/13/21.
//

import UIKit
import ARKit
import SpriteKit

class MenuNode: ButtonNode {

}

class InputMenuNode: MenuNode {
    var link: ArticulatedLink?
    var posX: SKSpriteNode?
    var posY: SKSpriteNode?
    var ang1: SKSpriteNode?
    var ang2: SKSpriteNode?
    
    var triggerInputNode = TriggeringInputNode()
    
    func addButtons() {
        removeAllChildren()
        isUserInteractionEnabled = true
        
        let size = CGSize(width: 50, height: 30)
        posX = SKSpriteNode(color: .darkGray, size: size)
        posY = SKSpriteNode(color: .darkGray, size: size)
        ang1 = SKSpriteNode(color: .darkGray, size: size)
        ang2 = SKSpriteNode(color: .darkGray, size: size)
        
        let posXLabel = SKLabelNode(text: "PosX")
        posXLabel.fontSize = 20
        posXLabel.position.y -= 10
        posXLabel.fontName = "AvenirNext-Bold"
        posX?.addChild(posXLabel)
        
        let posYLabel = SKLabelNode(text: "PosY")
        posYLabel.fontSize = 20
        posYLabel.position.y -= 10
        posYLabel.fontName = "AvenirNext-Bold"
        posY?.addChild(posYLabel)
        
        
        
        posX?.position = link!.pos
        posX?.position.x -= 0
        posX?.position.y = -40
        posY?.position = link!.pos
        posY?.position.x += 0
        posY?.position.y = -70
        
        addChild(posX!)
        addChild(posY!)
        
        addMenu(node: posX!)
        addMenu(node: posY!)
        
        
        if !link!.joints.isEmpty {
            let ang1Label = SKLabelNode(text: "Ang")
            ang1Label.fontName = "AvenirNext-Bold"
            ang1Label.fontSize = 20
            ang1Label.position.y -= 10
            ang1?.addChild(ang1Label)
            ang1?.position = link!.joints[0].joint.position
            addChild(ang1!)
            
            addMenu(node: ang1!)
            
            if link!.joints.count > 1 {
                let ang2Label = SKLabelNode(text: "Ang")
                ang2Label.fontName = "AvenirNext-Bold"
                ang2Label.fontSize = 20
                ang2Label.position.y -= 10
                ang2?.addChild(ang2Label)
                ang2?.position = link!.joints[1].joint.position
                addChild(ang2!)
                
                addMenu(node: ang2!)
            }
        }
        
    }
    
    func addMenu(node: SKSpriteNode) {
        let size = CGSize(width: 50, height: 30)
        let linear = SKSpriteNode(color: .lightGray, size: size)
        let step = SKSpriteNode(color: .lightGray, size: size)
        let pulse = SKSpriteNode(color: .lightGray, size: size)
        let data1 = SKSpriteNode(color: .lightGray, size: size)
        let data2 = SKSpriteNode(color: .lightGray, size: size)
        
        linear.name = "linear"
        step.name = "step"
        pulse.name = "pulse"
        
        data1.name = "data1"
        data2.name = "data2"
        
        let labelLinear = SKLabelNode(text: "linear")
        let labelStep = SKLabelNode(text: "step")
        let labelPulse = SKLabelNode(text: "pulse")
        
        let labelData1 = SKLabelNode(text: "data1")
        let labelData2 = SKLabelNode(text: "data2")
        labelLinear.fontName = "AvenirNext-Bold"
        labelStep.fontName = "AvenirNext-Bold"
        labelPulse.fontName = "AvenirNext-Bold"
        labelData1.fontName = "AvenirNext-Bold"
        labelData2.fontName = "AvenirNext-Bold"
        
        
        labelLinear.fontSize = 15
        labelStep.fontSize = 15
        labelPulse.fontSize = 15
        labelData1.fontSize = 15
        labelData2.fontSize = 15
        
        labelLinear.position.y -= 7.5
        labelStep.position.y -= 7.5
        labelPulse.position.y -= 7.5
        labelData1.position.y -= 7.5
        labelData2.position.y -= 7.5
        
        linear.addChild(labelLinear)
        step.addChild(labelStep)
        pulse.addChild(labelPulse)
        
        data1.addChild(labelData1)
        data2.addChild(labelData2)
        
        linear.position.x += 50
        step.position.x += 100
        pulse.position.x += 150
        data1.position.x += 200
        data2.position.x += 250
        
        node.addChild(linear)
        node.addChild(step)
        node.addChild(pulse)
        node.addChild(data1)
        node.addChild(data2)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self) else { return }
        
        triggerInputNode.linkNode = link
        
        if posX!.contains(touchPoint) {
            let touchPointInNode = posX?.convert(touchPoint, from: self)
            triggerInputNode.selectedInput = TriggeringInputNode.POS_X
            touchMenu(node: posX!, touch: touchPointInNode!)
        }
        
        if posY!.contains(touchPoint) {
            let touchPointInNode = posY?.convert(touchPoint, from: self)
            triggerInputNode.selectedInput = TriggeringInputNode.POS_Y
            touchMenu(node: posY!, touch: touchPointInNode!)
        }
        
        if ang1!.contains(touchPoint) {
            let touchPointInNode = ang1?.convert(touchPoint, from: self)
            triggerInputNode.selectedInput = TriggeringInputNode.ANG_1
            touchMenu(node: ang1!, touch: touchPointInNode!)
        }
        
        if ang2!.contains(touchPoint) {
            let touchPointInNode = ang2?.convert(touchPoint, from: self)
            triggerInputNode.selectedInput = TriggeringInputNode.ANG_2
            touchMenu(node: ang2!, touch: touchPointInNode!)
        }
    }
    
    func touchMenu(node: SKSpriteNode, touch: CGPoint) {
        for menu in node.children {
            if menu.contains(touch) {
                switch menu.name {
                case "linear":
                    triggerInputNode.triggerType = TriggeringInputNode.LINEAR
                case "step":
                    triggerInputNode.triggerType = TriggeringInputNode.STEP
                case "pulse":
                    triggerInputNode.triggerType = TriggeringInputNode.PULSE
                case "data1":
                    triggerInputNode.setTriggerData1()
                    App.state.triggeringNode.outputNode!.setOutputData1()
                case "data2":
                    triggerInputNode.setTriggerData2()
                    App.state.triggeringNode.outputNode!.setOutputData2()
                    App.state.triggeringNode.inputNode.append(triggerInputNode)
                    triggerInputNode = TriggeringInputNode()
                default:
                    ()
                }
            }
        }
    }
    
}

class OutputMenuNode: MenuNode {
    
}
