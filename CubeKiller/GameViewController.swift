//
//  GameViewController.swift
//  CubeKiller
//
//  Created by ltebean on 7/27/17.
//  Copyright © 2017 ltebean. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    enum ColliderCategory: Int {
        case gamer  = 0b0001
        case bullet = 0b0010
        case target = 0b0100
    }

    @IBOutlet weak var scnView: SCNView!
    
    var spawnTime: TimeInterval = 0
    var gamerNode: SCNNode!
    var targetNode: SCNNode!

    var cameraNode: SCNNode!
    var boxNode: SCNNode!
    
    var scene: SCNScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene(named: "art.scnassets/Game.scn")!
        scnView.scene = scene
        scnView.antialiasingMode = .multisampling4X
        scnView.delegate = self

        scene.physicsWorld.contactDelegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        scnView.addGestureRecognizer(panGesture)
        
        gamerNode = scene.rootNode.childNode(withName: "gamer", recursively: true)
        targetNode = scene.rootNode.childNode(withName: "targetBox", recursively: true)
        targetNode.isHidden = true
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)
        boxNode = scene.rootNode.childNode(withName: "gamerBox", recursively: true)
        boxNode.physicsBody?.categoryBitMask = ColliderCategory.gamer.rawValue
        boxNode.physicsBody?.contactTestBitMask = ColliderCategory.target.rawValue
        
        (1...15).forEach({ _ in
            self.spawnTarget()
        })

    }
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        guard gestureRecognize.state == .ended else { return }
        moveForward(distance: 5)
    }
    
    func moveForward(distance: Float) {
        let duration = 0.3
        let bounceUpAction = SCNAction.moveBy(x: 0, y: 1.0, z: 0, duration:
            duration * 0.5)
        let bounceDownAction = SCNAction.moveBy(x: 0, y: -1.0, z: 0, duration:
            duration * 0.5)
        
        let targetPosition = gamerNode.convertPosition(targetNode.position, to: scnView.scene!.rootNode)
        let currentPosition = gamerNode.position
        
        let by = targetPosition - currentPosition
        
        let forwardAction = SCNAction.move(by: by * distance, duration: duration)
        gamerNode.runAction(forwardAction)
        boxNode.runAction(SCNAction.sequence([bounceUpAction, bounceDownAction]))
    }
    
    func spawnTarget() {
        let position = gamerNode.position
        let target = SCNNode(geometry: SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0))
        target.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        let randomX = Float(Int.random(min: -10, max: 10))
        let randomZ = Float(Int.random(min: -10, max: 10))
        
        target.position = position + SCNVector3(x: randomX, y: 0, z: randomZ)
        target.physicsBody?.isAffectedByGravity = false
        target.name = "target"
        target.physicsBody?.categoryBitMask = ColliderCategory.target.rawValue
        target.physicsBody?.contactTestBitMask = ColliderCategory.gamer.rawValue | ColliderCategory.bullet.rawValue | ColliderCategory.target.rawValue
        target.physicsBody?.collisionBitMask = ColliderCategory.gamer.rawValue | ColliderCategory.bullet.rawValue | ColliderCategory.target.rawValue
        scene.rootNode.addChildNode(target)
        
        target.geometry?.materials[0].diffuse.contents = UIColor.random()
        target.opacity = 0
        let action = SCNAction.fadeIn(duration: 1)
        target.runAction(action)
        
    }
    
    
    @IBAction func shootButtonPressed(_ sender: Any) {
        let targetPosition = gamerNode.convertPosition(targetNode.position, to: scnView.scene!.rootNode)
        let currentPosition = gamerNode.position
        let by = targetPosition - currentPosition
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
        bullet.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        bullet.position = currentPosition
        bullet.physicsBody?.categoryBitMask = ColliderCategory.bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = ColliderCategory.target.rawValue
        bullet.physicsBody?.isAffectedByGravity = false
        bullet.physicsBody?.velocity = by * 8
        bullet.name = "bullet"
        scene.rootNode.addChildNode(bullet)
        
        let wait = SCNAction.wait(duration: 2)
        let remove = SCNAction.removeFromParentNode()
        let action  = SCNAction.sequence([wait,remove])
        bullet.runAction(action)
    }
    
    func handlePan(_ gesture: UIPanGestureRecognizer) {
        let tx = gesture.translation(in: gesture.view).x
        var angles = gamerNode.eulerAngles
        angles.y -= Float(CGFloat(M_PI) / 300 * tx)
        gamerNode.eulerAngles = angles
        gesture.setTranslation(CGPoint.zero, in: gesture.view)
 
    }
    
    func explode(node: SCNNode) {
        let geometry = node.geometry!
        let position = node.presentation.position
        let rotation = node.presentation.rotation
        let explosion = SCNParticleSystem(named: "art.scnassets/Explode.scnp", inDirectory: nil)!
        explosion.particleColor = geometry.materials[0].diffuse.contents as! UIColor
        explosion.emitterShape = geometry
        explosion.birthLocation = .surface
        let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z)
        let translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y, position.z)
        let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)
        scene.addParticleSystem(explosion, transform: transformMatrix)
        node.removeFromParentNode()

    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time:
        TimeInterval) {
        if time > spawnTime {
            spawnTarget()
            spawnTime = time + 1
        }
    }
    
}


extension GameViewController: SCNPhysicsContactDelegate {

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {

        var target: SCNNode!
        var node: SCNNode!

        print(contact.nodeA, contact.nodeB)
        if contact.nodeA.name == "target" {
            target = contact.nodeA
            node = contact.nodeB
        } else {
            target = contact.nodeB
            node = contact.nodeA
        }
        if node.name == "bullet" {
            let wait = SCNAction.wait(duration: 0.3)
            let explode = SCNAction.run { node in
                self.explode(node: node)
            }
            let action = SCNAction.sequence([wait, explode])
            target.runAction(action)
            
        } else if node.name == "gamerBox" {
            explode(node: target)
        } else {
            explode(node: node)
            explode(node: target)

        }

    }
}
