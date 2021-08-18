//
//  KeyframeNode.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 8/8/21.
//

import UIKit
import ARKit
import SpriteKit

class KeyframeNode: TriggeringOutputNode {
    var targetNode: SKSpriteNode?
    
    var warpGeometryGrid: SKWarpGeometryGrid?
    
    var initialState = [SIMD2<Float>]()
    var finalState = [SIMD2<Float>]()
    
    var allStates = [[SIMD2<Float>]]()
    var currentState = [SIMD2<Float>]()
    
    var initialControlInput: CGFloat?
    var finalControlInput: CGFloat?
    
    var allControlInput = [CGFloat]()
    var currentControlInput: CGFloat?
    var currentU: Double?
//    var controlInputValue: CGFloat?
    
    var controlPoints = [SKShapeNode]()
    var controlInput = SKNode()
    
    var selectedControlPoint: SKShapeNode?
    var isControlPointSelected = false
    var isControlPointSelectedMiddle = false
    var middleStartPoint = CGPoint.zero
    var translationStartPoints = [CGPoint]()
    
    var drivingParam = 0
    var POS_X = 0
    var POS_Y = 1
    
    func controlInputValue() -> CGFloat {
        var controlInputValue = CGFloat()
        if let input = controlInput as? JointNode {
            controlInputValue = input.angle
        }
        
        if let input = controlInput as? ArticulatedLink {
            if drivingParam == POS_X {
                controlInputValue = input.pos.x
            } else if drivingParam == POS_Y {
                controlInputValue = input.pos.y
            }
            
        }
        
        return controlInputValue
        
    }
    
    func updateWarpGeometryInitial() {
        initialControlInput = controlInputValue()
    }
    
    func updateWarpGeometryCurrent() {
        for (i, _) in initialState.enumerated() {
            let pos = controlPoints[i].position
            let warpControlPointX = pos.x/targetNode!.size.width + 0.5
            let warpControlPointY = pos.y/targetNode!.size.height + 0.5
            let warpControlPoint = SIMD2(Float(warpControlPointX), Float(warpControlPointY))
            currentState[i] = warpControlPoint
        }

        targetNode?.warpGeometry = warpGeometryGrid?.replacingByDestinationPositions(positions: currentState)
    }
    
    func updateWarpGeometryFinal() {
        finalState = currentState
        
        finalControlInput = controlInputValue()
    }
    
    func updateWarpGeometryInterpolation() {
        
        currentControlInput = controlInputValue()
        
        var index: Int?
        if allControlInput[0] < allControlInput[1] {
            index = allControlInput.firstIndex(where: {$0 >= currentControlInput!})
        } else {
            index = allControlInput.firstIndex(where: {$0 <= currentControlInput!})
        }
        if index == 0 || index == nil { return }
        
        
        
        
        initialState = allStates[index!-1]
        finalState = allStates[index!]
        initialControlInput = allControlInput[index!-1]
        finalControlInput = allControlInput[index!]
        
        var u = (currentControlInput! - initialControlInput!) / (finalControlInput! - initialControlInput!)
        u = (u < 0) ? 0 : u
        u = (u > 1) ? 1 : u
        
        for i in 0..<warpGeometryGrid!.vertexCount {
            let x0 = initialState[i].x
            let y0 = initialState[i].y
            let x1 = finalState[i].x
            let y1 = finalState[i].y
            
            currentState[i].x = x0 + Float(u)*(x1-x0)
            currentState[i].y = y0 + Float(u)*(y1-y0)
        }
        
        targetNode?.warpGeometry = warpGeometryGrid?.replacingByDestinationPositions(positions: currentState)
        
    }
    
    func addKeyframe() {
        updateWarpGeometryCurrent()
        allStates.append(currentState)
        allControlInput.append(controlInputValue())
        print(controlInputValue())
    }
    
    func translationStart() {
        for point in controlPoints {
            translationStartPoints.append(point.position)
        }
    }
    
    func translation() {
        let middlePoint = controlPoints[4]
        for (i, point) in controlPoints.enumerated() {
            point.position = translationStartPoints[i] + (middlePoint.position - middleStartPoint)
        }
        
//        updateWarpGeometryCurrent()
    }
    
    func rotateCW() {
        let middlePoint = controlPoints[4]
        for point in controlPoints {
            let vec = point.position - middlePoint.position
            let vecRot = CGPoint(x: sqrt(2)*(vec.x+vec.y)/2, y: sqrt(2)*(vec.y-vec.x)/2)
            let newPos = middlePoint.position + vecRot
            point.position = newPos
        }
        updateWarpGeometryCurrent()
    }
    
    func rotateCCW() {
        let middlePoint = controlPoints[4]
        for point in controlPoints {
            let vec = point.position - middlePoint.position
//            let vecRot = CGPoint(x: -vec.y, y: vec.x)
            let vecRot = CGPoint(x: sqrt(2)*(vec.x-vec.y)/2, y: sqrt(2)*(vec.x+vec.y)/2)
            let newPos = middlePoint.position + vecRot
            point.position = newPos
        }
        updateWarpGeometryCurrent()
    }
    
    func hide() {
        for point in controlPoints {
            point.position = CGPoint.zero
        }
        updateWarpGeometryCurrent()
    }
    
}
