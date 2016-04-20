//
//  CameraNodeParallax.swift
//
//  Created by gitmalong
//
//

import Foundation
import SpriteKit

/*
 Gives you parallax backgrounds by moving your bgs by factor x,y in relation to your SKCameraNodes speed
 
 Usage:
 1) Create an instance of this class in your scene and call this objects
    triggerChange() once your camera position changes
 
    the second vector parameter defines the moving speed of your background in relation to the cameras speed (it gets multiplied with the cameras position difference once your camera changes its position)
   
    e.g. if your background should
        - stick to your camera: CGVectorMake(1,1)
        - move half as fast as the camera on the x-axes: CGVectorMake(0.5,0)
        - not move at all: CGVectorMake(0,0)
        - move twice as fast as the camera on x-axes: CGVectorMake(2,0)
 
 */

public class ParallaxBackgroundMover {
    
    private var backgroundNode:SKNode
    private var relativeSpeedToCamera:CGVector // in relation to camera nodes speed

    public init(background:SKNode, relativeSpeedToCamera:CGVector) {
        self.backgroundNode = background
        self.relativeSpeedToCamera = relativeSpeedToCamera
    }
    
    /* call this method whenever your cameras position changes */
    public func triggerChange(newCameraPosition:CGPoint,oldCameraPosition:CGPoint) {
            // Move your parallax backgrounds
            let positionChangeX = newCameraPosition.x-oldCameraPosition.x
            let positionChangeY = newCameraPosition.y-oldCameraPosition.y
            let changeX = positionChangeX*relativeSpeedToCamera.dx
            let changeY = positionChangeY*relativeSpeedToCamera.dy
            backgroundNode.position = CGPointMake(backgroundNode.position.x+changeX,backgroundNode.position.y+changeY)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}