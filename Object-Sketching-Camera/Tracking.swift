//
//  Tracking.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 7/27/21.
//

import ARKit
import SpriteKit
import SceneKit

extension Scene {
    
    override func update(_ currentTime: TimeInterval) {
        App.state.startTime = (App.state.isRigStart) ? App.state.startTime : currentTime
        startTime = (App.state.isRigStart) ? startTime : currentTime
        if (currentTime - startTime)/2 > 1 {
            
//            let ball = SKShapeNode(circleOfRadius: 10)
//            ball.physicsBody = SKPhysicsBody(polygonFrom: ball.path!)
//            ball.position = CGPoint(x: 0, y: 683)
//            ball.fillColor = .red
////            self.addChild(ball)
//            startTime = currentTime
        }
        
        if App.state.shootBall {
            if currentTime-startTime > 0.2 {
                for (i, vec) in shootBall.enumerated() {
                    let impulse = 300 * vec
                    let startPoint = shootBallPos[i]
                    let ball = SKShapeNode(circleOfRadius: 3)
                    let BCategory  : UInt32 = 0x1 << 0
                    let BotCategory : UInt32 = 0x1 << 4
                    let PadCategory : UInt32 = 0x1 << 5
                    
                    ball.fillColor = .yellow
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: 1)
                    ball.physicsBody?.affectedByGravity = false
                    ball.physicsBody?.linearDamping = 0
                    ball.physicsBody?.restitution = 1
                    ball.physicsBody?.friction = 0
                    ball.position = startPoint
                    ball.physicsBody?.velocity = impulse
                    ball.physicsBody?.categoryBitMask = BCategory
                    ball.physicsBody?.contactTestBitMask = BotCategory | PadCategory
                    ball.physicsBody?.collisionBitMask = BotCategory | PadCategory
                    ball.name = "ball"
                    App.state.shootBalls.append(ball)
                    self.addChild(ball)
                }
                
                startTime = currentTime
            }
        }
        
        
        // Called before each frame is rendered
        guard let sceneView = self.view as? ARSKView else { return }
        guard let frame = sceneView.session.currentFrame else { return }
        
        let image: CIImage
        let pixelBuffer = frame.capturedImage
        image = CIImage(cvImageBuffer: pixelBuffer)
        
        let context = CIContext(options: nil)
        guard let cameraImage = context.createCGImage(image, from: image.extent) else { return }
        var src: UIImage? = UIImage(cgImage: cameraImage)
        
        // track the color marker
        var num: Int32 = 0
        var x = [Int32](repeating: 0, count: 30)
        var y = [Int32](repeating: 0, count: 30)
        OpenCV.getMarkersPositions(&src, num: &num, x: &x, y: &y)

        
        if !App.state.isRigStart {
            self.removeAllChildren()
            App.state.markersArrayShapeNode.removeAll()
            self.addChild(App.state.environment)
            App.state.environment.position = CGPoint(x: 0, y: -400)
            var i = 0
            while i < num {
                let circle = SKShapeNode(circleOfRadius: 10)
                circle.position = convertPoint(fromView: CGPoint(x: Double(x[i]), y: Double(y[i])-8))
                circle.strokeColor = .white
                circle.lineWidth = 3
                circle.fillColor = .green
                circle.name = String(i)
                self.addChild(circle)
                App.state.markersArrayShapeNode.append(circle)
                i += 1
            }
        } else {
            // start rigging
            var i = 0
            while i < num {
                let detectedMarker = convertPoint(fromView: CGPoint(x: Double(x[i]), y: Double(y[i])-8))
                for (j, node) in App.state.markersArrayShapeNode.enumerated() {
                    let dist = distanceCGPoints(node.position, detectedMarker)
                    if dist < 50 {
                        App.state.markersArrayShapeNode[j].position = detectedMarker
                        break
                    }
                }
                i += 1
            }
            
        }
        
        App.state.articulatedObject.update()
        
        for node in App.state.stringInJoints {
            node.update()
        }
        
        
        if App.state.keyframeState == App.state.KEYFRAME_DONE && !App.state.triggeringState {
            for node in App.state.keyframingNodes {
                node.updateWarpGeometryInterpolation()
            }
//            App.state.keyframingNode.updateWarpGeometryInterpolation()
        }
        
        if App.state.triggeringNode.triggeredDidSetup {
            App.state.triggeringNode.update()
        }
        
    }

}
