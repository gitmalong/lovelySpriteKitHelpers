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
 Works for this pattern
 GameScene  -> world            -> backgroundNodes -> place your EndlessBackground(s) here
            -> platformNodes
            -> control UI
            -> camera
 
 Just call triggerDraw() in your GameScenes didFinishUpdate()
 and this class takes care of drawing and removing your background nodes
 
 */
public class EndlessBackground:SKNode {
    
    private let nodeName:String // identifier for the background nodes
    private let texture:SKTexture // your background as texture
    private let drawMaxNodes = 2 // max number of background nodes
    private let firstNodePosition:CGPoint // first position of your background
    private let camera:SKCameraNode
    private let drawNewBackgroundTriggerDistance:CGFloat // New background is drawn when there is no bg at this value+camera.position.x

    init(fileName:String,firstNodePosition:CGPoint,nodeName:String,camera:SKCameraNode, drawNewBackgroundTriggerDistance:CGFloat?=nil) {
        texture = SKTexture(imageNamed: fileName)
        self.firstNodePosition = firstNodePosition
        self.nodeName = nodeName
        self.camera = camera
        
        if let d = drawNewBackgroundTriggerDistance {
            self.drawNewBackgroundTriggerDistance = d
        } else {
            self.drawNewBackgroundTriggerDistance = camera.parent!.scene!.size.width/2
        }
        
        super.init()
        self.zPosition = 1
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getMostRightPositionX()->CGFloat {
        return getMostRightChildnode()!.position.x+texture.size().width
    }
    
    
    func getMostRightChildnode()->SKNode? {
        var mostRightNode:SKNode? = nil
        
        for node in self.children {
            if (mostRightNode == nil || node.position.x > mostRightNode!.position.x) {
                mostRightNode = node
            }
        }
        
        return mostRightNode
    }
    
    func getMostLeftChildnode()->SKNode? {
        var mostLeftNode:SKNode? = nil
        
        for node in self.children {
            if (mostLeftNode == nil || node.position.x < mostLeftNode!.position.x) {
                mostLeftNode = node
            }
        }
        
        return mostLeftNode
    }
    
    func draw(position:CGPoint=CGPointZero) {
        print("Draw background on point: ")
        print(position)
        
        let node = SKSpriteNode(texture: texture)
        node.position = position
        node.anchorPoint = CGPointZero
        node.name = nodeName
        self.addChild(node)
        
        print("texture width")
        print(texture.size().width)
        print("most right child node position x")
        print(getMostRightChildnode()?.position.x)
    }
    
    /* should be called from the scene didFinishUpdate method */
    func triggerDraw() {

        print("camera")
        print(camera.position.x)

        let mostRightChildNode = getMostRightChildnode()
        let mostRightChildNodeXEnd = mostRightChildNode!.position.x+texture.size().width
        
        // Convert most right child position to camera parents (->szene) coordinate system
        // in order to support moving parallex backgrounds
        let mostRightChildNodePoint = CGPointMake(mostRightChildNodeXEnd,mostRightChildNode!.position.y)
        
        let mostRightChildNodeXInGameScene = self.convertPoint(mostRightChildNodePoint, toNode: camera.parent!).x
        let mostLeftChildNodeInGameScene = self.convertPoint(getMostLeftChildnode()!.position, toNode: camera.parent!).x
        
        let cameraPlusSzeneSize = camera.position.x+drawNewBackgroundTriggerDistance
        let cameraMinusSzeneSize = camera.position.x-drawNewBackgroundTriggerDistance
        
        print("most right child node")
        print(mostRightChildNodeXEnd)
        
        print("most right child node parallax fixed")
        print(mostRightChildNodeXInGameScene)
        
        print("camera plus szene size")
        print(cameraPlusSzeneSize)

        if (cameraPlusSzeneSize > mostRightChildNodeXInGameScene) {
            if (self.children.count >= drawMaxNodes) {
                cleanLeft()
            } else if (self.children.count < drawMaxNodes) {
                print("draw right")
                drawRight()
            }
        }
        
        if (cameraMinusSzeneSize < mostLeftChildNodeInGameScene) {
            if (self.children.count >= drawMaxNodes) {
                cleanRight()
            } else if (self.children.count < drawMaxNodes) {
                print("draw left")
                drawLeft()
            }
        }
    }
    
    private func cleanLeft() {
        /* removes not visible nodes */
            print("Remove most left background")
            print(drawMaxNodes)
            print(self.children.count)
            print("clean - mostLeftChildNode")
            print(getMostLeftChildnode())
            var mostLeftNode = getMostLeftChildnode()?.removeFromParent()
            
            mostLeftNode = nil
    }
    
    private func cleanRight() {
        /* removes not visible nodes */
            print("Remove most right background")
            print(drawMaxNodes)
            print(self.children.count)
            var mostRightChildNode = getMostRightChildnode()?.removeFromParent()
            mostRightChildNode = nil
    }
    
    private func drawLeft() {
        print("drawLeft")
        draw(CGPointMake(getMostLeftChildnode()!.position.x-texture.size().width,firstNodePosition.y))
       // cleanRight()
    }
    
    private func drawRight() {
        print("drawRight")
        draw(CGPointMake(getMostRightPositionX(),firstNodePosition.y))
       // cleanLeft()
    }
    
}
