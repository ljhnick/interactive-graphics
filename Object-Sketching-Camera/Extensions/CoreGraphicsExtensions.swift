//
//  CoreGraphicsExtensions.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 7/30/21.
//

import UIKit
import SpriteKit
import ARKit

extension Scene {
    func distanceCGPoints(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func calculateCombinedCenterPosition(combinedNode: SKNode) -> CGPoint {
        var minX: CGFloat?
        var minY: CGFloat?
        var maxX: CGFloat?
        var maxY: CGFloat?
        
        for node in combinedNode.children {
            minX = (node.frame.minX <= minX ?? node.frame.minX) ? node.frame.minX : minX
            minY = (node.frame.minY <= minY ?? node.frame.minY) ? node.frame.minY : minY
            maxX = (node.frame.maxX >= maxX ?? node.frame.maxX) ? node.frame.maxX : maxX
            maxY = (node.frame.maxY >= maxY ?? node.frame.maxY) ? node.frame.maxY : maxY
        }
        
        let center = CGPoint(x: (minX!+maxX!)/2, y: (minY!+maxY!)/2)
        return center
    }
    
    func convertShapeToSprite(node: SKShapeNode) -> SKSpriteNode {
        let texture = SKView().texture(from: node)
        let spriteNode = SKSpriteNode(texture: texture)
        let center = CGPoint(x: node.frame.midX, y: node.frame.midY)
        spriteNode.position = center
        spriteNode.colorBlendFactor = 0.5
        
        return spriteNode
    }
    
}

//extension CGPath {
//    func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
//        typealias Body = @convention(block) (CGPathElement) -> Void
//        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
//            let body = unsafeBitCast(info, to: Body.self)
//            body(element.pointee)
//        }
//        //print(MemoryLayout.size(ofValue: body))
//        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
//        self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
//    }
//    func getPathElementsPoints() -> [CGPoint] {
//        var arrayPoints : [CGPoint]! = [CGPoint]()
//        self.forEach { element in
//            switch (element.type) {
//            case CGPathElementType.moveToPoint:
//                arrayPoints.append(element.points[0])
//            case .addLineToPoint:
//                arrayPoints.append(element.points[0])
//            case .addQuadCurveToPoint:
//                arrayPoints.append(element.points[0])
//                arrayPoints.append(element.points[1])
//            case .addCurveToPoint:
//                arrayPoints.append(element.points[0])
//                arrayPoints.append(element.points[1])
//                arrayPoints.append(element.points[2])
//            default: break
//            }
//        }
//        return arrayPoints
//    }
//    func getPathElementsPointsAndTypes() -> ([CGPoint],[CGPathElementType]) {
//        var arrayPoints : [CGPoint]! = [CGPoint]()
//        var arrayTypes : [CGPathElementType]! = [CGPathElementType]()
//        self.forEach { element in
//            switch (element.type) {
//            case CGPathElementType.moveToPoint:
//                arrayPoints.append(element.points[0])
//                arrayTypes.append(element.type)
//            case .addLineToPoint:
//                arrayPoints.append(element.points[0])
//                arrayTypes.append(element.type)
//            case .addQuadCurveToPoint:
//                arrayPoints.append(element.points[0])
//                arrayPoints.append(element.points[1])
//                arrayTypes.append(element.type)
//                arrayTypes.append(element.type)
//            case .addCurveToPoint:
//                arrayPoints.append(element.points[0])
//                arrayPoints.append(element.points[1])
//                arrayPoints.append(element.points[2])
//                arrayTypes.append(element.type)
//                arrayTypes.append(element.type)
//                arrayTypes.append(element.type)
//            default: break
//            }
//        }
//        return (arrayPoints,arrayTypes)
//    }
//}

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}

extension CGVector {
    static func * (lhs: CGVector, rhs: CGVector) -> CGFloat {
        CGFloat(lhs.dx*rhs.dx + lhs.dy*rhs.dy)
    }
    
    static func * (lhs: CGFloat, rhs: CGVector) -> CGVector {
        CGVector(dx: lhs*rhs.dx, dy: lhs*rhs.dy)
    }
}

func calculateRotationAngle(start: [SKShapeNode], end:[SKShapeNode]) -> CGFloat {
    let x00 = start[0].position.x
    let x01 = start[1].position.x
    let y00 = start[0].position.y
    let y01 = start[1].position.y
    
    let x10 = end[0].position.x
    let x11 = end[1].position.x
    let y10 = end[0].position.y
    let y11 = end[1].position.y
    
    let x1 = x01 - x00
    let y1 = y01 - y00
    let x2 = x11 - x10
    let y2 = y11 - y10
    
    let v1 = CGVector(dx: x1, dy: y1)
    let v2 = CGVector(dx: x2, dy: y2)
    
    let angle = atan2(v1.dy, v1.dx) - atan2(v2.dy, v2.dx)
    
    return angle
}
