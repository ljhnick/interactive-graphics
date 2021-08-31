//
//  App.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 7/30/21.
//

import UIKit
import SpriteKit
import ARKit
import Charts

class App {
    private init() {}
    static let state = App()
    
    var sceneView: ARSKView!
    var scene = SKScene()
    
    var physicalBounday = false
    var drawPhysicalObject = false
    var drawStaticObject = false
    var shootBall = false
    var bounceMax = false
    
    var startTime = TimeInterval()
    
    var isRigStart = false
    var isRigEnd = false
    

    var currentState = 0
    var IS_DEFAULT = 0
    var IS_DRAWING = 1
    var IS_BINDING = 2
    var IS_KEYFRAMING = 3
    var IS_TRIGGERING = 4
    
    var isBindingState = 0
    var BINDING_STATE_FIXED = 1
    var BINDING_STATE_SPRING = 2
    var BINDING_STATE_LIMIT = 3
    
    var keyframeState = 0
    var KEYFRAME_PARAM = 0
    var KEYFRAME_CIRCLE = 1
    var KEYFRAME_ADD = 2
    var KEYFRAME_DONE = 3
    var KEYFRAME_SWAP = 4
    
    var keyframeTrackingState = 0
    var KEYFRAME_TRACKING_ANGLE = 0
    var KEYFRAME_TRACKING_POS = 1
    var KEYFRAME_TRACKING_POS_X = 2
    var KEYFRAME_TRACKING_POS_Y = 3
    
    var triggeringState = false
    var triggeringType = 0
    var TRIGGER_LINEAR = 1
    var TRIGGER_STEP = 2
    var TRIGGER_RANGE = 3
    
    
    var physicsJoints = [SKPhysicsJoint]()
    
    var markersArrayShapeNode = [SKShapeNode]()
    var drawingNodes = [SKShapeNode]()
    var drawingNodesSprite = [SKSpriteNode]()
    var keyframingNode = KeyframeNode()
    var keyframingNodes = [KeyframeNode]()
    
    var triggeringNode = TriggeringNode()
    
    var articulatedObject = ArticulatedObject()
    var stringInJoints = [StringNode]()
    
    var environment = EnvironmentNode()
    var graphSubview = LineChartView()
    var keyframesButtons = KeyframeButtonNode()
    var keyframesButtonDeformButton = KeyframeDeformButton()
    var keyframesSwapDrawing = SKShapeNode()
    
    // triggering node
    var forceNode = ForceNode()
    var visibilityNode = VisibilityNode()
    var physicsNode = PhysicsJointNode()
    
    var shootBallDir = [CGVector]()
    var shootBallPos = [CGPoint]()
    
    var strokeColor : UIColor = UIColor(red: 1, green: 1, blue: 0.5, alpha: 1)
    var lineWidth: CGFloat = 6
    
    
    // mis
    var shootBalls = [SKShapeNode]()
    
    func reset() {
        
        isRigStart = false
        isRigEnd = false
        currentState = 0
    
        physicsJoints = [SKPhysicsJoint]()
    
        markersArrayShapeNode = [SKShapeNode]()
        drawingNodes = [SKShapeNode]()
        drawingNodesSprite = [SKSpriteNode]()
        keyframingNode = KeyframeNode()
        keyframingNodes = [KeyframeNode]()
        
        triggeringNode = TriggeringNode()
        
        articulatedObject = ArticulatedObject()
        stringInJoints = [StringNode]()
        
        environment = EnvironmentNode()
        graphSubview = LineChartView()
        keyframesButtons = KeyframeButtonNode()
        keyframesButtonDeformButton = KeyframeDeformButton()
        keyframesSwapDrawing = SKShapeNode()
        
        // triggering node
        forceNode = ForceNode()
        visibilityNode = VisibilityNode()
        physicsNode = PhysicsJointNode()
        
        shootBalls = [SKShapeNode]()
    }
}
