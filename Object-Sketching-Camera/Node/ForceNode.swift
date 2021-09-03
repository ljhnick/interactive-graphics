//
//  ForceNode.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 8/11/21.
//

import UIKit
import ARKit
import SpriteKit

class ForceNode: TriggeringOutputNode {
    
    var initialState: CGVector?
    var finalState: CGVector?
    
    var currentU = Double(0)
    
    var forceBody = SKShapeNode()
    var forceArrow = SKShapeNode()
    
    var currentForce = CGVector()
    
    var selectedFlag = false
    
    var controlInputU: Double?
    
    func setupForce() {
        
        self.removeAllChildren()
        
        isUserInteractionEnabled = true
        currentForce = App.state.scene.physicsWorld.gravity
        
        forceArrow = SKShapeNode(circleOfRadius: 6)
        forceArrow.fillColor = .darkGray
        forceBody.strokeColor = .white
        forceBody.lineWidth = 3
        
        self.addChild(forceBody)
        self.addChild(forceArrow)
        
        updateForce()
    }
    
    func updateForce() {
        currentForce = App.state.scene.physicsWorld.gravity
        
        forceArrow.position = CGPoint(x: currentForce.dx*5, y: currentForce.dy*5)
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: forceArrow.position)
        
        forceBody.path = path
    }
    
    func updateForceWorld() {
        App.state.scene.physicsWorld.gravity.dx = forceArrow.position.x / 5
        App.state.scene.physicsWorld.gravity.dy = forceArrow.position.y / 5
    }
    
    override func setOutputData1() {
        updateForce()
        initialState = currentForce
    }
    
    override func setOutputData2() {
        updateForce()
        finalState = currentForce
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self) else { return }
        if forceArrow.contains(touchPoint) {
            selectedFlag = true
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self) else { return }
        if selectedFlag {
            forceArrow.position = touchPoint
            updateForceWorld()
            updateForce()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedFlag = false
    }
    
    func interpolateForce() {
        let initialLength = vecLength(vector: initialState!)
        let initialAng = vecAng(vector: initialState!)
        
        let finalLength = vecLength(vector: finalState!)
        let finalAng = vecAng(vector: finalState!)
        
        let currentLength = CGFloat(controlInputU!) * (finalLength - initialLength) + initialLength
        let currentAng = CGFloat(controlInputU!) * (finalAng - initialAng) + initialAng
        
        let dx = currentLength * cos(currentAng)
        let dy = currentLength * sin(currentAng)
        
        currentForce = CGVector(dx: dx, dy: dy)
        App.state.scene.physicsWorld.gravity = currentForce
        updateForce()
        updateForceWorld()
    }
    
    func vecLength(vector: CGVector) -> CGFloat {
        let dx = vector.dx
        let dy = vector.dy
        
        return sqrt(pow(dx, 2) + pow(dy, 2))
    }
    
    func vecAng(vector: CGVector) -> CGFloat {
        var ang: CGFloat
        ang = atan2(vector.dy, vector.dx)
        
        return ang
    }
    
    func zeroGravity() {
        App.state.scene.physicsWorld.gravity = CGVector.zero
        updateForce()
    }
}
