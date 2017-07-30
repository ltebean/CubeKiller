//
//  SCNNode.swift
//  CubeKiller
//
//  Created by ltebean on 7/29/17.
//  Copyright © 2017 ltebean. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class GameHelper {
    
    
    static let shared = GameHelper()
    
    var sounds: [String: SCNAudioSource] = [:]
    
    func loadSound(name:String, fileNamed:String) {
        if let sound = SCNAudioSource(fileNamed: fileNamed) {
            sound.isPositional = false
            sound.volume = 0.3
            sound.load()
            sounds[name] = sound
        }
    }
    
    func playSound(node:SCNNode, name:String, rate: Float = 1) {
        let sound = sounds[name]
        sound?.rate = rate
        node.runAction(SCNAction.playAudio(sound!, waitForCompletion: false))
    }
    
}
