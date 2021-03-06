//
//  ViewController.swift
//  Object-Sketching-Camera
//
//  Created by jiahaol on 7/26/21.
//

import UIKit
import SpriteKit
import SceneKit
import ARKit
import Charts

class ViewController: UIViewController, ARSKViewDelegate, ChartViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    @IBOutlet weak var buttonRig: UIButton!
    @IBOutlet weak var buttonDraw: UIButton!
    @IBOutlet weak var buttonReset: UIButton!
    
    @IBOutlet weak var btnBind: UIButton!
    @IBOutlet weak var btnSpring: UIButton!
    @IBOutlet weak var btnLimit: UIButton!
    @IBOutlet weak var btnFixed: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    
    @IBOutlet weak var btnFrame: UIButton!
    @IBOutlet weak var btnSwap: UIButton!
    @IBOutlet weak var btnFrameDone: UIButton!
    
    @IBOutlet weak var btnTriggerDone: UIButton!
    
    @IBOutlet weak var btnShowphysics: UIButton!
    @IBOutlet weak var btnBoundary: UIButton!
    @IBOutlet weak var btnDrawPhysicalObject: UIButton!
    @IBOutlet weak var btnDrawStatic: UIButton!
    @IBOutlet weak var btnShoot: UIButton!
    @IBOutlet weak var btnBounce: UIButton!

    
    // Load the SKScene from 'Scene.sks'
    var skScene = Scene(fileNamed: "Scene")!
    
    @IBAction func buttonRig(_ sender: Any) {
        skScene.buttonRig()
    }
    
    @IBAction func buttonDraw(_ sender: Any) {
        skScene.buttonDraw()
    }
    
    // binding buttons
    @IBAction func btnStartBind(_ sender: Any) {
        App.state.currentState = App.state.IS_BINDING
        btnFixed.isHidden = false
        btnSpring.isHidden = false
        btnLimit.isHidden = false
        btnDone.isHidden = false
    }
    @IBAction func buttonBind(_ sender: Any) {
        skScene.buttonBind()
    }
    @IBAction func buttonSpring(_ sender: Any) {
        skScene.buttonSpring()
    }
    @IBAction func buttonLimit(_ sender: Any) {
        skScene.buttonLimit()
    }
    @IBAction func buttonAdd(_ sender: Any) {
        skScene.buttonAdd()
        btnFixed.isHidden = true
        btnSpring.isHidden = true
        btnLimit.isHidden = true
        btnDone.isHidden = true
    }
    
    // keyframing buttons
    @IBAction func buttonKeyframe(_ sender: Any) {
        skScene.buttonKeyframe()
        btnFixed.isHidden = true
        btnSpring.isHidden = true
        btnLimit.isHidden = true
        btnDone.isHidden = true
        
        btnFrame.isHidden = false
        btnFrameDone.isHidden = false
        btnSwap.isHidden = false
    }
    
    @IBAction func buttonAdd1(_ sender: Any) {
        skScene.buttonAddFinalState()
    }
    
    @IBAction func btnSwap(_ sender: Any) {
        skScene.buttonSwap()
    }
    
    
    @IBAction func buttonKeyframeDone(_ sender: Any) {
        skScene.buttonKeyframeDone()
        btnFrame.isHidden = true
        btnFrameDone.isHidden = true
        btnSwap.isHidden = true
    }
    
    @IBAction func buttonTrigger(_ sender: Any) {
        skScene.buttonAnimationTrigger()
        btnTriggerDone.isHidden = false
    }
    
    @IBAction func buttonTriggerDone(_ sender: Any) {
        skScene.buttonTriggerDidSet()
    }
    
    @IBAction func btnShowPhysics(_ sender: Any) {
        sceneView.showsPhysics.toggle()
        btnShowphysics.backgroundColor = (sceneView.showsPhysics) ? .red : .darkGray
    }
    
    @IBAction func btnBoundary(_ sender: Any) {
        App.state.physicalBounday.toggle()
        skScene.physicsBody = (App.state.physicalBounday) ? SKPhysicsBody(edgeLoopFrom: skScene.frame) : nil
        btnBoundary.backgroundColor = (App.state.physicalBounday) ? .red : .darkGray
    }
    
    @IBAction func btnDrawObject(_ sender: Any) {
        App.state.drawPhysicalObject.toggle()
        btnDrawPhysicalObject.backgroundColor = (App.state.drawPhysicalObject) ? .red : .darkGray
        if !App.state.drawPhysicalObject {
            App.state.drawStaticObject = false
            btnDrawStatic.backgroundColor = (App.state.drawStaticObject) ? .red : .darkGray
        }
    }
    
    @IBAction func btnDrawStatic(_ sender: Any) {
        App.state.drawStaticObject.toggle()
        if App.state.drawStaticObject {
            App.state.drawPhysicalObject = true
        }
        btnDrawStatic.backgroundColor = (App.state.drawStaticObject) ? .red : .darkGray
        btnDrawPhysicalObject.backgroundColor = (App.state.drawPhysicalObject) ? .red : .darkGray
    }
    
    @IBAction func btnShoot(_ sender: Any) {
        App.state.shootBall.toggle()
        btnShoot.backgroundColor = (App.state.shootBall) ? .red : .darkGray
        if !App.state.shootBall {
            App.state.scene.removeChildren(in: App.state.shootBalls)
            App.state.shootBalls.removeAll()
            App.state.shootBallDir.removeAll()
            App.state.shootBallPos.removeAll()
        }
    }
    
    @IBAction func btnBounce(_ sender: Any) {
        App.state.bounceMax.toggle()
        btnBounce.backgroundColor = (App.state.bounceMax) ? .red : .darkGray
    }
    
    @IBAction func btnWhite(_ sender: Any) {
        App.state.strokeColor = .white
    }
    
    @IBAction func btnBlue(_ sender: Any) {
        App.state.strokeColor = .blue
    }
    
    @IBAction func btnGreen(_ sender: Any) {
        App.state.strokeColor = .green
    }
    
    @IBAction func btnYellow(_ sender: Any) {
        App.state.strokeColor = UIColor(red: 1, green: 1, blue: 0.5, alpha: 1)
    }
    
    @IBAction func btnOrange(_ sender: Any) {
        App.state.strokeColor = .orange
    }
    
    @IBAction func btnRed(_ sender: Any) {
        App.state.strokeColor = .red
    }
    
    @IBAction func buttonReset(_ sender: Any) {
        skScene.buttonReset()
    }
    
    @IBAction func btnUndo(_ sender: Any) {
        App.state.scene.removeChildren(in: [App.state.drawingNodes.last!])
        let lastNode = App.state.drawingNodes.last!
        if App.state.environment.drawings.last! == lastNode {
            App.state.environment.drawings.removeLast()
        }
        App.state.drawingNodes.removeLast()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
//        sceneView.showsPhysics = true
        App.state.sceneView = sceneView
                
        // Load the SKScene from 'Scene.sks'
        App.state.scene = skScene
        skScene.scaleMode = .resizeFill
//        if let scene = SKScene(fileNamed: "Scene") {
//            sceneView.presentScene(scene)
//        }
        sceneView.presentScene(App.state.scene)
        
//        skScene.physicsBody = SKPhysicsBody(edgeLoopFrom: skScene.frame)
        
        btnFixed.isHidden = true
        btnSpring.isHidden = true
        btnLimit.isHidden = true
        btnDone.isHidden = true
        
        btnFrame.isHidden = true
        btnFrameDone.isHidden = true
        btnSwap.isHidden = true
        
        btnTriggerDone.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    
}
