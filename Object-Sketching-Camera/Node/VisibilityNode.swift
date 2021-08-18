//
//  VisibilityNode.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 8/11/21.
//

import UIKit
import ARKit
import SpriteKit

class VisibilityNode: TriggeringOutputNode {
    
    var initialState: CGFloat?
    var finalState: CGFloat?
    
    var controlInputU = Double(0)
    
    var currentState: CGFloat?
    
    var sliderBar = SKShapeNode()
    var sliderNode = SKShapeNode()
    
    var selectedFlag = false
    
    func setupVisiblitySlider() {
        self.removeAllChildren()
        isUserInteractionEnabled = true
        
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: -80, y: 0))
        
        sliderBar.path = path
        
        sliderBar.strokeColor = .darkGray
        sliderBar.lineWidth = 3
        
        sliderNode = SKShapeNode(circleOfRadius: 6)
        sliderNode.fillColor = .darkGray
        sliderBar.addChild(sliderNode)
        
        sliderBar.position.x = -80
        
        self.addChild(sliderBar)
        
    }
    
    func updateVisibility() {
        currentState = (sliderNode.position.x + 80) / 80
        for node in App.state.environment.drawings {
            node.alpha = currentState!
        }
        
    }
    
    override func setOutputData1() {
        updateVisibility()
        initialState = currentState
    }
    
    override func setOutputData2() {
        updateVisibility()
        finalState = currentState
    }
    
    func interpolateVisibility() {
        sliderNode.position.x = CGFloat(controlInputU * 80 - 80)
        updateVisibility()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first?.location(in: self) else { return }
        let touchInNode = self.convert(touch, to: sliderBar)
        if sliderNode.contains(touchInNode) {
            selectedFlag = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first?.location(in: self) else { return }
        let touchInNode = self.convert(touch, to: sliderBar)
        if selectedFlag {
            var x = (touchInNode.x >= 0) ? 0 : touchInNode.x
            x = (touchInNode.x <= -80) ? -80 : x
            sliderNode.position.x = x
            updateVisibility()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedFlag = false
    }
    
}
