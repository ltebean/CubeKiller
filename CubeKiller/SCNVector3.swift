import Foundation
import SceneKit

extension SCNVector3 {

    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    
    
    /**
     * Subtracts two SCNVector3 vectors and returns the result as a new SCNVector3.
     */
    static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    
    /**
     * Multiplies two SCNVector3 vectors and returns the result as a new SCNVector3.
     */
    static func * (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x * right.x, left.y * right.y, left.z * right.z)
    }
    
    
    /**
     * Multiplies the x, y and z fields of a SCNVector3 with the same scalar value and
     * returns the result as a new SCNVector3.
     */
    static func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }

}

