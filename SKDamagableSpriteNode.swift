extension NSDate: Comparable { }

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.isEqualToDate(rhs)
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

//
//  Damageable.swift
//

import Foundation
import SpriteKit
import UIKit
import AudioToolbox

/**
 
 Protocol & extension that adds "damagable" functionality to a SKNode
 
 - Node gets life points that can be substracted
 
 - onDeath() is triggered when the node "dies"
 
 - Support for nodes that have children. Use it when all of them should be able to get damaged but the life points (of the parent node) should only be substracted once for each damaging event (i.e. when the hero's body parts are all children and both feets are contacted by the same fire)
 
 Usage:
 1) Create a class that conforms to DamagableNode for your parent node and a class that conforms to DamageChild for all your parent nodes children
 
 2) If you want to apply damage to a node check if the node conforms to "Damagable" and apply the damage via subtractHealthPoints() or use getAffectedSKNode() to access the parent/master node and do what ever you want
 
 */
protocol SKDamagable {
    
    /// Subtract health points
    func subtractHealthPoints(number:Int)

    /// Returns health points
    func getHealthPoints() -> Int
    
    /// Returns self if it is the father node, otherwise it should return the parent node
    func getAffectedSKNode() -> SKNode
    
}

protocol SKDamagableChild:SKDamagable {
    var parentNode:SKDamageableMaster! { get set }
}

/// Class redirects all damaging events to the parent node
extension SKDamagableChild where Self:SKNode  {

    /// Substract health points from the parents node call this only when you are sure the same damage event is not called by other children of your parent
    func subtractHealthPoints(number: Int) {
        parentNode.subtractHealthPoints(number)
    }
    
    /// Returns health points of master node
    func getHealthPoints() -> Int {
        return parentNode.getHealthPoints()
    }
    
    /// Returns master node
    func getAffectedSKNode() -> SKNode {
        return parentNode.getAffectedSKNode()
    }

}

class SKDamagableSpriteNode:SKSpriteNode, SKDamagableChild {
    var parentNode: SKDamageableMaster!
    
    init(parentNode:SKDamageableMaster, texture:SKTexture) {
        self.parentNode = parentNode
        super.init(texture: texture, color: UIColor.whiteColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/* Master node */
protocol SKDamageableMaster: class, SKDamagable {
    var healthPoints:Int { get set }

    func updateHealthPoints(number:Int) -> Void
    func afterUpdateHealthPoints() -> Void
    func onDeath() -> Void
}

/* Master node */
extension SKDamageableMaster where Self:SKNode  {

    func subtractHealthPoints(number:Int) {
        updateHealthPoints(healthPoints-number)
    }
    
    func updateHealthPoints(number:Int) {
        
        if (number <= 0) {
            healthPoints = 0
            onDeath()
        } else {
            healthPoints = number
        }
        
        afterUpdateHealthPoints()
    }
    
    func getHealthPoints()->Int {
        return self.healthPoints
    }

    
    func getAffectedSKNode() -> SKNode {
        return self as SKNode
    }
    
}


/// Protocol that adds SKDamageEvents to SKDamagable
protocol SKDamagableWithDamageEvents:class, SKDamagable, SKDamagableEventManager {

    /// Adds and applies SKDamageEvent and subtracts health of node
    func addAndApplyDamageEvent(event: SKDamageEvent) -> Void
    
}

/// Default implementation for protocol SKDamagableWithDamageEvents
extension SKDamagableWithDamageEvents {
    
    /// Adds and applies SKDamageEvent and subtracts health of node
    func addAndApplyDamageEvent(event: SKDamageEvent) -> Void {
        event.applied = true
        event.appliedTime = NSDate().timeIntervalSince1970
        damageEvents.append(event)
        self.subtractHealthPoints(event.damagePoints)
        print(self.getHealthPoints())
    }

}

/// Updates an SKLabelNode with new health points & vibrates
protocol DamageableUserCharacter:SKDamageableMaster, SKDamagableWithDamageEvents {
    var healthPointsLabelNode:SKLabelNode { get }
}

extension DamageableUserCharacter {
    func afterUpdateHealthPoints() {
        healthPointsLabelNode.text = "\(healthPoints)"
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}