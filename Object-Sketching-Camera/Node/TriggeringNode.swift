//
//  TriggeringNode.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 8/10/21.
//

import UIKit
import ARKit
import SpriteKit
import Charts

class TriggeringNode: SKNode {
    var inputNode = [TriggeringInputNode]()
    var outputNode: TriggeringOutputNode?
    
    var inputMenu: InputMenuNode?
    
    var triggeredDidSetup = false

    func update() {
        
        let inputU = inputNode.min(by: {$0.output() < $1.output()})?.output()
                    
        if outputNode is ForceNode {
            let output = outputNode as? ForceNode
            output?.controlInputU = inputU
            output?.interpolateForce()
        }
        else if outputNode is PhysicsJointNode {
            let output = outputNode as? PhysicsJointNode
            output?.controlInputU = inputU
            output?.interpolatePhysicsJoint()
        }
        else if outputNode is KeyframeNode {
            let output = outputNode as? KeyframeNode
            output!.currentU = inputU
            output?.updateWarpGeometryInterpolation()
        }
        else if outputNode is VisibilityNode {
            let output = outputNode as? VisibilityNode
            output?.controlInputU = inputU!
            output?.interpolateVisibility()
        }
        
    }
    
}

class TriggeringOutputNode: SKNode {
    
    func setOutputData1() {
        
    }
    
    func setOutputData2() {
        
    }
}

class TriggeringInputNode: SKNode {
    var linkNode: ArticulatedLink?
    var selectedInput = 0
    var triggerType = 0
    
    var triggerData1 = CGFloat()
    var triggerData2 = CGFloat()
    
    static let ANG_1 = 0
    static let ANG_2 = 6
    static let POS_X = 1
    static let POS_Y = 2
    static let VEL_X = 3
    static let VEL_Y = 4
    static let ANG_V = 5
    
    static let STEP = 0
    static let LINEAR = 1
    static let PULSE = 2
    
    func currentInput() -> CGFloat {
        var output = CGFloat()
        let input = selectedInput
        switch input {
        case TriggeringInputNode.ANG_1:
            output = linkNode!.joints[0].angle
        case TriggeringInputNode.ANG_2:
            output = linkNode!.joints[1].angle
        case TriggeringInputNode.POS_X:
            output = linkNode!.pos.x
        case TriggeringInputNode.POS_Y:
            output = linkNode!.pos.y
        case TriggeringInputNode.VEL_X:
            output = linkNode!.velocity.dx
        case TriggeringInputNode.VEL_Y:
            output = linkNode!.velocity.dy
        case TriggeringInputNode.ANG_V:
            output = linkNode!.angularVelocity
        default:
            output = 0
        }
        
        return output
    }
    
    func setTriggerData1() {
        triggerData1 = currentInput()
    }
    
    func setTriggerData2() {
        triggerData2 = currentInput()
    }
    
    func output() -> Double {
        var out: Double
        let currentData = currentInput()
        out = Double((currentData - triggerData1) / (triggerData2 - triggerData1))
        switch triggerType {
        case TriggeringInputNode.STEP:
            out = (out >= 0) ? 1 : 0
        case TriggeringInputNode.PULSE:
            out = (out < 1 && out > 0) ? 1 : 0
        case TriggeringInputNode.LINEAR:
            out = (out > 1) ? 1 : out
            out = (out < 0) ? 0 : out
        default:
            out = 0
        }
        
        return out
    }
}
