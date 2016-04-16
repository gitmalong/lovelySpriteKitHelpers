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
 1) Set your szene's self.camera to your CameraNodeParallax object and set its position
 2) Add your background(s) with addParallaxBackgroundNode()
    the second vector parameter defines the moving speed of your background in relation to the cameras speed (it gets multiplied with the cameras position difference once your camera changes its position)
   
    e.g. if your background should
        - stick to your camera: CGVectorMake(1,1)
        - move half as fast as the camera on the x-axes: CGVectorMake(0.5,0)
        - not move at all: CGVectorMake(0,0)
        - move twice as fast as the camera on x-axes: CGVectorMake(2,0)
 
 3) set your CameraNodeParallax objects positionInitialized = true
 */

class CameraNodeParallax:SKCameraNode{
    
    var positionInitialized = false
    var backgroundNodes:[SKNode] = []
    var backgroundNodesSpeedFactor:[CGVector] = [] // in relation to camera nodes speed
    
    override var position : CGPoint {
        didSet {
            
            // Move your parallax backgrounds
            if positionInitialized == true {
                var i = 0
                for node in backgroundNodes {
                    
                    let positionChangeX = position.x-oldValue.x
                    let positionChangeY = position.y-oldValue.y
                    let changeX = positionChangeX*backgroundNodesSpeedFactor[i].dx
                    let changeY = positionChangeY*backgroundNodesSpeedFactor[i].dy
                    node.position = CGPointMake(node.position.x+changeX,node.position.y+changeY)
                    
                    i += 1
                }
            }
  
        }
    }
    
    func addParallaxBackgroundNode(background:SKNode, vector:CGVector) {
        backgroundNodes.append(background)
        backgroundNodesSpeedFactor.append(vector)
    }
}