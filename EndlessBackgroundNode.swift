//
//  EndlessBackgroundNode.swift
//
//  Created by gitmalong
//
//

import Foundation
import SpriteKit

/*
 Node for an endless vertically scrolling background
 in an SpriteKit environment that makes use of SKCameraNode
 Supports parallax backgrounds as well
 
 Usage:
 Designed for this kind of pattern
 GameScene  -> world            -> backgroundNodes -> place your EndlessBackground(s) here
                                -> e.g. platforms
                                -> e.g. interactive sprites
                                -> e.g. characters -> hero
                                                   -> enemies
            -> camera -> fixed stuff, e.g. control UI

 
 Add your EndlessBackground object to your backgroundNodes or world and call its draw() method in your didMoveToView for initializing.
 After that just call triggerDraw() in your GameScenes didFinishUpdate()
 or in your camers position -> didSet listener
 and this class takes care of drawing and removing your background nodes
 
 */
public class EndlessBackground:SKNode {
    
    private let textureCache:SKTexture // your background as texture
    private let node:SKSpriteNode
    private var drawMaxNodes:Int // max number of background nodes
    private let camera:SKCameraNode
    private let distanceTrigger:CGFloat // New background is drawn when there is no bg at this value+camera.position.x

    init(yourBackgroundNode node:SKSpriteNode,camera:SKCameraNode, triggerDistance:CGFloat?=nil) {
        
        self.node = node
        textureCache = (node.texture?.copy())! as! SKTexture
        node.texture = textureCache
        self.camera = camera
        
        if let d = triggerDistance {
            self.distanceTrigger = d
        } else {
            self.distanceTrigger = camera.parent!.scene!.size.width/2
        }
        
        // Calc max nodes
        // Allow to prerender half a screen
        drawMaxNodes = Int(round(camera.scene!.size.width/node.size.width*1.5))
        if drawMaxNodes < 2 { // If node size is bigger than screen we want to have 2 at least
            drawMaxNodes = 2
        }
        
        super.init()
        
        self.position = node.position
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getMostRightPositionX()->CGFloat {
        return getMostRightChildnode()!.position.x+node.size.width
    }
    
    
    private func getMostRightChildnode()->SKNode? {
        var mostRightNode:SKNode? = nil
        
        for node in self.children {
            if (mostRightNode == nil || node.position.x > mostRightNode!.position.x) {
                mostRightNode = node
            }
        }
        
        return mostRightNode
    }
    
    private func getMostLeftChildnode()->SKNode? {
        var mostLeftNode:SKNode? = nil
        
        for node in self.children {
            if (mostLeftNode == nil || node.position.x < mostLeftNode!.position.x) {
                mostLeftNode = node
            }
        }
        
        return mostLeftNode
    }
    
    
    func initDraw() {
        self.addChild(node.copy() as! SKSpriteNode)
    }
    
    func draw(position:CGPoint=CGPointZero) {
        // Copy Sprite Node and change its position
        let nodeCopy = node.copy() as! SKSpriteNode
        nodeCopy.position = position
        self.addChild(nodeCopy)
    }
    
    /* should be called from the scene's didFinishUpdate or cameras position->didSet method */
    func triggerDraw() {

        let mostRightChildNode = getMostRightChildnode()
        let mostRightChildNodeXEnd = mostRightChildNode!.position.x+node.size.width
        
        // Convert most left/right child position to camera parents (->szene) coordinate system
        // in order to support moving parallex backgrounds
        let mostRightChildNodePoint = CGPointMake(mostRightChildNodeXEnd,mostRightChildNode!.position.y)
        
        let mostRightChildNodeXInGameScene = self.convertPoint(mostRightChildNodePoint, toNode: camera.parent!).x
        let mostLeftChildNodeXInGameScene = self.convertPoint(getMostLeftChildnode()!.position, toNode: camera.parent!).x
        
        let cameraPlusTriggerDistance = camera.position.x+distanceTrigger
        let cameraMinusTriggerDistance = camera.position.x-distanceTrigger

        if (cameraPlusTriggerDistance > mostRightChildNodeXInGameScene) {
            drawRight()
            
            if self.children.count > drawMaxNodes {
               cleanLeft()
            }
        }
        
        if (cameraMinusTriggerDistance < mostLeftChildNodeXInGameScene) {
            drawLeft()
            
            if self.children.count > drawMaxNodes {
                cleanRight()
            }
        }
    }
    
    private func cleanLeft() {
            var mostRightChild = getMostLeftChildnode()
            mostRightChild?.removeFromParent()
            mostRightChild = nil
    }
    
    private func cleanRight() {
            var mostLeftChild = getMostLeftChildnode()
            mostLeftChild?.removeFromParent()
            mostLeftChild = nil
    }
    
    private func drawLeft() {
        // print("drawLeft")
        draw(CGPointMake(getMostLeftChildnode()!.position.x-node.size.width,node.position.y))
    }
    
    private func drawRight() {
       // print("drawRight")
        draw(CGPointMake(getMostRightPositionX(),node.position.y))
    }
    
}
