//
//  EndlessBackgroundNode.swift
//
//  Created by gitmalong
//
//

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
    
    /// Caches your background node
    private let node:SKSpriteNode
    /// Max number of background nodes
    private var drawMaxNodes:Int
    private let camera:SKCameraNode
    /// New background is drawn when there is no bg at this value+camera.position.x
    private let distanceTrigger:CGFloat
    
    init(yourBackgroundNode node:SKSpriteNode,camera:SKCameraNode, triggerDistance:CGFloat?=nil) {
        
        self.node = node
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
        self.zPosition = node.zPosition
        self.name = node.name
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        self.addChild(node)
    }
    
    private func draw(position:CGPoint=CGPointZero) {
        // Copy Sprite Node and change its position
        // Texture of the copy will point to the same ressource -> Good
        
        if let _ = node.parent { // If cache node has parent we need a copy
            let nodeCopy = node.copy() as! SKSpriteNode
            nodeCopy.position = position
            self.addChild(nodeCopy)
        } else { // If cache node has no parent we use it
            node.position = position
            self.addChild(node)
        }

    }
    
    /* should be called from the scene's didFinishUpdate or cameras position->didSet method */
    func triggerDraw() {
        
        let mostRightNode = getMostRightChildnode()
        let mostRightNodeXEnd = mostRightNode!.position.x+node.size.width
        
        // Convert most left/right child position to camera parents (->szene) coordinate system
        // in order to support moving parallex backgrounds
        let mostRightNodeEndPoint = CGPointMake(mostRightNodeXEnd,mostRightNode!.position.y)
        
        let mostRightNodeEndXInGameScene = self.convertPoint(mostRightNodeEndPoint, toNode: camera.parent!).x
        let mostLeftChildNodeXInGameScene = self.convertPoint(getMostLeftChildnode()!.position, toNode: camera.parent!).x
        
        let cameraPlusTriggerDistance = camera.position.x+distanceTrigger
        let cameraMinusTriggerDistance = camera.position.x-distanceTrigger
        
        if (cameraPlusTriggerDistance > mostRightNodeEndXInGameScene) {
            
            if children.count > drawMaxNodes {
                // Instead of delete the old node we just move it
                // removeMostLeftNode()
                getMostLeftChildnode()!.position = getDrawRightPosition()
            } else {
                drawRight()
            }
            
        }
        
        if (cameraMinusTriggerDistance < mostLeftChildNodeXInGameScene) {
            
            if children.count > drawMaxNodes {
                // removeMostRightNode()
                getMostRightChildnode()!.position = getDrawLeftPosition()

            } else {
                drawLeft()
            }

        }
    }
    
    /*
    private func removeMostLeftNode() {
        getMostLeftChildnode()?.removeFromParent()
    }
    
    private func removeMostRightNode() {
        getMostRightChildnode()?.removeFromParent()
        
    }*/
    
    private func getDrawLeftPosition()->CGPoint {
        return CGPointMake(getMostLeftChildnode()!.position.x-node.size.width,node.position.y)
    }

    
    private func getDrawRightPosition()->CGPoint {
        return CGPointMake(getMostRightChildnode()!.position.x+node.size.width,node.position.y)
    }
    
    private func drawLeft() {
        draw(getDrawLeftPosition())
    }
    
    private func drawRight() {
        draw(getDrawRightPosition())
    }
    
}
