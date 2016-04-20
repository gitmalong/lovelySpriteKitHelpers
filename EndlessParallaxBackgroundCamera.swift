//
//  EndlessParallaxBackground.swift
//
//  Created by gitmalong
//  SKCameraNode Subclass that controls CameraNodeParallax and EndlessBackgroundNode
//

import Foundation
import SpriteKit

class EndlessParallaxBackgroundCamera:SKCameraNode {
    
    var endlessBackgrounds:[EndlessBackground] = [EndlessBackground]()
    var parallaxBackgrounds:[ParallaxBackgroundMover] = [ParallaxBackgroundMover]()
    
    init(position:CGPoint) {
        super.init()
        self.position = position
        self.name = "camera"
    }
    
    func addEndlessBackground(ebg:EndlessBackground) {
        endlessBackgrounds.append(ebg)
    }
    
    func addParallaxBackground(pbg:ParallaxBackgroundMover) {
        parallaxBackgrounds.append(pbg)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var position : CGPoint {
        didSet {
            if endlessBackgrounds.isEmpty == false {
                for ebg in endlessBackgrounds {
                    ebg.triggerDraw()
                }
            }

            if parallaxBackgrounds.isEmpty == false {
                for pbg in parallaxBackgrounds {
                    pbg.triggerChange(position,oldCameraPosition: oldValue)
                }
            }

        }
    }
}