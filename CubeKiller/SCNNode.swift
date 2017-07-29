//
//  SCNNode.swift
//  CubeKiller
//
//  Created by ltebean on 7/29/17.
//  Copyright © 2017 ltebean. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    
    func wait(forDuation duration: TimeInterval, thenRun block: @escaping (_ node: SCNNode) -> ()) {
        let wait = SCNAction.wait(duration: duration)
        let runBlock = SCNAction.run({ node in
            block(node)
        })
        let action = SCNAction.sequence([wait, runBlock])
        self.runAction(action)
    }
}
