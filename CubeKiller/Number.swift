//
//  Int.swift
//  CubeKiller
//
//  Created by leo on 2017/7/28.
//  Copyright © 2017年 ltebean. All rights reserved.
//

import Foundation

public extension Int {
    public static func random(min: Int , max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max - min + 1))) + min
    }
}

public extension Float {
    public static func random(min: Float, max: Float) -> Float {
        let r32 = Float(arc4random(UInt32.self)) / Float(UInt32.max)
        return (r32 * (max - min)) + min
    }
}

public func arc4random <T: ExpressibleByIntegerLiteral> (_ type: T.Type) -> T {
    var r: T = 0
    arc4random_buf(&r, Int(MemoryLayout<T>.size))
    return r
}

