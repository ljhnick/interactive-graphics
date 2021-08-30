//
//  Keyframing.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 8/8/21.
//

import SpriteKit
import ARKit
import UIKit

extension Scene {
    
    func keyframeAddFinalStateTouchesBegan(_ touches: Set<UITouch>) {
        guard let touchPoint = touches.first?.location(in: self) else { return }
        for (i, controlPoint) in App.state.keyframingNode.controlPoints.enumerated() {
            let touchPointInNode = App.state.keyframingNode.targetNode?.convert(touchPoint, from: self)
            
            if controlPoint.contains(touchPointInNode!) {
                App.state.keyframingNode.selectedControlPoint = controlPoint
                App.state.keyframingNode.isControlPointSelected = true
                if i == 4 {
                    App.state.keyframingNode.isControlPointSelectedMiddle = true
                    App.state.keyframingNode.translationStart()
                }
                
                break
            }
        }
        
    }
    
    func keyframeAddFinalStateTouchesMoved(_ touches: Set<UITouch>) {
        guard let touchPoint = touches.first?.location(in: self) else { return }
//        guard let touchPointPrevious = touches.first?.location(in: self) else { return }
        guard let controlPoint = App.state.keyframingNode.selectedControlPoint else { return }
        if App.state.keyframingNode.isControlPointSelected {
            controlPoint.position = App.state.keyframingNode.targetNode!.convert(touchPoint, from: self)

            if App.state.keyframingNode.isControlPointSelectedMiddle {
                App.state.keyframingNode.translation()
            }
            
            App.state.keyframingNode.updateWarpGeometryCurrent()
            
            
        }
        
        
    }
    
    func keyframeAnimationTouchesEnded(_ touches: Set<UITouch>) {
        guard let touchPoint = touches.first?.location(in: self) else { return }
        
        switch App.state.keyframeState {
        case App.state.KEYFRAME_PARAM:
            let touchNode = SKShapeNode(circleOfRadius: 10)
            touchNode.position = touchPoint
            for link in App.state.articulatedObject.links {
                if touchNode.intersects(link.lines) {
                    App.state.keyframingNode.controlInput = link
                    showButton(link: link)
                    break
                }
            }
            
        case App.state.KEYFRAME_CIRCLE:
            var selectedNode = [SKShapeNode]()
            let strokeNode = SKShapeNode(path: pathTemp)
            strokeNode.fillColor = .black
//            let strokeSprite = convertShapeToSprite(node: strokeNode)
//            self.addChild(strokeSprite)
            
//            print(strokeNode.path?.getPathElementsPoints())
            for drawing in App.state.drawingNodes {
                if strokeNode.intersects(drawing) {
                    selectedNode.append(drawing)
                    App.state.environment.drawings.removeAll(where: {$0 == drawing})
                    App.state.drawingNodes.removeAll(where: {$0 == drawing})
                }
            }
            
            if selectedNode.count > 0 {
                let combinedNode = SKNode()
                for node in selectedNode {
                    node.removeFromParent()
                    node.strokeColor = App.state.strokeColor
                    combinedNode.addChild(node)
                }
                
                let combinedNodeTexture = SKView().texture(from: combinedNode)
                let combinedNodeSprite = SKSpriteNode(texture: combinedNodeTexture)
                let combinedCenter = calculateCombinedCenterPosition(combinedNode: combinedNode)
                combinedNodeSprite.position = combinedCenter
                App.state.drawingNodesSprite.append(combinedNodeSprite)
                App.state.articulatedObject.updateDrawings(spriteNode: combinedNodeSprite, selectedDrawing: selectedNode)
                self.addChild(combinedNodeSprite)
                
                App.state.keyframeState = App.state.KEYFRAME_ADD
                
                setInitialState(node: combinedNodeSprite)
                showButtonNode(node: combinedNodeSprite)
                
            }
            
        case App.state.KEYFRAME_ADD:
            App.state.keyframingNode.isControlPointSelected = false
            App.state.keyframingNode.isControlPointSelectedMiddle = false
            
        default:
            ()
        }
        
//        if App.state.keyframeState != App.state.KEYFRAME_ADD {
//            var selectedNode = [SKShapeNode]()
//            let strokeNode = SKShapeNode(path: pathTemp)
//            for drawing in App.state.drawingNodes {
//                if strokeNode.intersects(drawing) {
//                    selectedNode.append(drawing)
//                }
//            }
//
//            if selectedNode.count > 0 {
//                let combinedNode = SKNode()
//                for node in selectedNode {
//                    node.removeFromParent()
//                    node.strokeColor = .orange
//                    combinedNode.addChild(node)
//                }
//
//                let combinedNodeTexture = SKView().texture(from: combinedNode)
//                let combinedNodeSprite = SKSpriteNode(texture: combinedNodeTexture)
//                let combinedCenter = calculateCombinedCenterPosition(combinedNode: combinedNode)
//                combinedNodeSprite.position = combinedCenter
//                App.state.drawingNodesSprite.append(combinedNodeSprite)
//                App.state.articulatedObject.updateDrawings(spriteNode: combinedNodeSprite, selectedDrawing: selectedNode)
//                self.addChild(combinedNodeSprite)
//
//                setInitialState(node: combinedNodeSprite)
//
//            }
//        } else if App.state.keyframeState == App.state.KEYFRAME_ADD {
//            App.state.keyframingNode.isControlPointSelected = false
//        }
    }
    
    func setInitialState(node: SKSpriteNode) {
        App.state.keyframingNode.targetNode = node
        let warpGeometryGrid = SKWarpGeometryGrid(columns: 2, rows: 2)
        App.state.keyframingNode.warpGeometryGrid = warpGeometryGrid
        let width = node.size.width
        let height = node.size.height
        
        for i in 0..<warpGeometryGrid.vertexCount {
            let scaledX = warpGeometryGrid.sourcePosition(at: i).x
            let scaledY = warpGeometryGrid.sourcePosition(at: i).y
            App.state.keyframingNode.initialState.append(warpGeometryGrid.sourcePosition(at: i))
            App.state.keyframingNode.currentState = App.state.keyframingNode.initialState
            let controlPointNode = SKShapeNode(rectOf: CGSize(width: 20, height: 20))
            let cornerStart = CGPoint(x: -width/2, y: -height/2)
            controlPointNode.position.x = cornerStart.x + CGFloat(scaledX) * width
            controlPointNode.position.y = cornerStart.y + CGFloat(scaledY) * height
            controlPointNode.fillColor = .orange
            App.state.keyframingNode.controlPoints.append(controlPointNode)
            node.addChild(controlPointNode)
        }
        
        // add ui selection here
        // to be updated
//        App.state.keyframingNode.controlInput = App.state.articulatedObject.joints.first!
//        App.state.keyframingNode.updateWarpGeometryInitial()
    }
    
    func showButton(link: ArticulatedLink) {
        
        App.state.keyframesButtons.link = link
        App.state.keyframesButtons.addButtons()
        
        App.state.keyframesButtons.removeFromParent()
        self.addChild(App.state.keyframesButtons)
    }
    
    func showButtonNode(node: SKSpriteNode) {
        App.state.keyframesButtonDeformButton = KeyframeDeformButton()
        App.state.keyframesButtonDeformButton.spriteNode = node
        App.state.keyframesButtonDeformButton.intialize()
        
        App.state.keyframesButtonDeformButton.removeFromParent()
        node.addChild(App.state.keyframesButtonDeformButton)
    }
    
}
