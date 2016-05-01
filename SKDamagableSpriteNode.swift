//
//  Damageable.swift
//
/* 
 
 Protocol & extension that adds "damagable" functionality to a SKNode
 
 - Node gets life points that can be substracted
 - onDeath() is triggered when the node "dies"
 - Support for nodes that have children. Use it when all of them should be able to get damaged but the life points (of the parent node) should only be substracted once for each damaging event (i.e. when the hero's body parts are all children and both feets are contacted by the same fire)

 Usage:
 1) Create a class that conforms to DamagableNode for your parent node and a class that conforms to DamageChild for all your parent nodes children
 
 2) If you want to apply damage to a node check if the node conforms to "Damagable" and apply the damage via syncedSubstractHealthPoints(number:Int, uniqueDamageEventID:String) or use getAffectedSKNode() to access the parent/master node do what ever you want to do

  Created by gitmalong on 20.04.16.
*/

import Foundation
import SpriteKit
import UIKit
import AudioToolbox

protocol SKDamagable {
    func substractHealthPoints(number:Int)
    func syncedSubstractHealthPoints(number:Int, uniqueDamageEventID:String) -> Void
    func getHealthPoints() -> Int
    func addAction(action:SKAction,withKey:String) -> Void
    func stopAction(actionKey:String) -> Void
    func getAffectedSKNode() -> SKNode
}

/* If your Damagable node has children that could also be damaged 
    add them as a node class that conforms to this protocol. if multiple body parts 
 run into a damaging event, the health point substraction will only be applied once to your Damagable parent node
 
 */
protocol SKDamagableChild:SKDamagable {
    var parentNode:SKDamageableNode! { get set }
}

/* this class redirects all damaging events to the parent node in order to
 make sure that each damage event is only applied once to your node group

 */
extension SKDamagableChild where Self:SKNode  {
    
    /* redirects health point substraction to parent */
    func syncedSubstractHealthPoints(number:Int, uniqueDamageEventID:String) {
        parentNode.syncedSubstractHealthPoints(number, uniqueDamageEventID: uniqueDamageEventID)
    }
    
    /* substract health points from the parents node
       call this only when you are sure the same damage event
       is not called by other children of your parent
     */
    func substractHealthPoints(number: Int) {
        parentNode.substractHealthPoints(number)
    }
    
    /* redirect to parent */
    func addAction(action:SKAction,withKey:String) {
        parentNode.addAction(action,withKey: withKey)
    }
    
    /* redirect to parent */
    func stopAction(actionKey:String) {
        parentNode.stopAction(actionKey)
    }
    
    /* redirect to parent */
    func getHealthPoints() -> Int {
        return parentNode.getHealthPoints()
    }
    
    /* return master node */
    func getAffectedSKNode() -> SKNode {
        return parentNode.getAffectedSKNode()
    }
}

class SKDamagableSpriteNode:SKSpriteNode, SKDamagableChild {
    var parentNode:SKDamageableNode!
    
    init(parentNode:SKDamageableNode, texture:SKTexture) {
        self.parentNode = parentNode
        
        super.init(texture: texture, color: UIColor.whiteColor(), size: texture.size())
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/* Master node */
protocol SKDamageableNode:class, SKDamagable {
    var healthPoints:Int { get set }

    func updateHealthPoints(number:Int) -> Void
    func afterUpdateHealthPoints() -> Void
    func onDeath() -> Void
}

/* Master node */
extension SKDamageableNode where Self:SKNode  {
    
    /* If your physics body that gets damaged has multiple body party
     we want the damagable nodes children apply the damaging only to the
     parent (this class). to prevent applying the same damage event multiple
     times we execute them as action with an unique id. multiple events get 
     overwritten
     */
    func syncedSubstractHealthPoints(number:Int, uniqueDamageEventID:String) {
        let substractBlock = SKAction.runBlock( {
          self.substractHealthPoints(number)
        })
        
        self.runAction(substractBlock, withKey: uniqueDamageEventID)
    }
    
    func substractHealthPoints(number:Int) {
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
    
    func stopAction(actionKey:String) {
        self.removeActionForKey(actionKey)
    }
    
    func addAction(action: SKAction, withKey:String) {
        self.runAction(action, withKey: withKey)
    }
    
    func getAffectedSKNode() -> SKNode {
        return self as SKNode
    }
    
}

/* Updates an SKLabelNode with new health points & vibrates */
protocol DamageableUserCharacter:SKDamageableNode {
    var healthPointsLabelNode:SKLabelNode { get }
    
    func afterUpdateHealthPoints()
}

extension DamageableUserCharacter {
    func afterUpdateHealthPoints() {
        healthPointsLabelNode.text = "\(healthPoints)"
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}