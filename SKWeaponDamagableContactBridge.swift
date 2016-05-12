//  WeaponDamagableContactBridge.swift


import Foundation
import SpriteKit

/**
 
 Manages the contact between objects that conform to type SKWeapon and SKDamagable
 In other words: Applies damage and stops damage application between SKWeapon's and SKDamagable's based on the call of SpriteKits SKSzene didBeginContact() & didEndContact() methods
 
 Created by gitmalong on 01.05.16.
 
 */
class SKWeaponDamagableContactBridge {
    
    /** creates an key that is unique for the relationship of one weapon and damagable key */
    static func createUniqueActionKey(weapon:SKWeapon, damagable:SKDamagable)->String {
        let weaponID = ObjectIdentifier(weapon)
        let damagableID = ObjectIdentifier(damagable.getAffectedSKNode())
        return String(weaponID)+String(damagableID)
    }
    
    /**
     If the weapon should attack the damagable object not only
     one time but as long as it is in contact with the object
     
     - Returns: true if no damagable node is contacting the weapon anymore, false if not */
    static func didEndContinousContact(weaponNode:SKNode, damagableNode:SKNode)->(groupContactEnded:Bool, allDamagableContactsEnded:Bool) {
        
        let weapon = weaponNode as! SKWeapon
        let damagable = damagableNode as! SKDamagable
        
        // Helps us to sync the damage application
        let uniqueActionKey = createUniqueActionKey(weapon, damagable: damagable)
        
        // Only stop the substract health action
        // if it is the last contact of that node group
        // Loop through all contacted bodies and count all
        // bodies with same father
        
        var countContacts = 0
        var countDamagableContacts = 0
        if let contactedBodies = weaponNode.physicsBody?.allContactedBodies() {
            for contactedBody in contactedBodies {
                if let contactedSKNode = contactedBody.node as? SKDamagable {
                    if contactedSKNode.getAffectedSKNode() == damagable.getAffectedSKNode()  {
                        countContacts = countContacts+1
                    }
                    countDamagableContacts = countDamagableContacts+1
                }
            }
        }
        
        let groupContactEnded:Bool
        if countContacts == 0 {
            damagable.getAffectedSKNode().removeActionForKey(uniqueActionKey)
            groupContactEnded = true
        } else {
            groupContactEnded = false
        }
        
        return (groupContactEnded: groupContactEnded, allDamagableContactsEnded: countDamagableContacts==0)
        
    }
    
    /**
     If your weapon should attack the damagable object not only
     one time but as long as it is in contact with the object
     
     - Returns: true if contact was applied for the first time to the damagable node tree */
    static func didBeginContinousContact(weaponNode:SKNode, damagableNode:SKNode)->Bool {
    
        let weapon = weaponNode as! SKWeapon
        let damagable = damagableNode as! SKDamagable
        
        // Helps us to sync the damage application
        let uniqueActionKey = createUniqueActionKey(weapon, damagable: damagable)

        if let _ = damagable.getAffectedSKNode().actionForKey(uniqueActionKey) {
            // print("weapon contacted damagableNode more often")
            return false
        } else { // Only create new action if it does not exist already
            
            if damagable.getHealthPoints() > 0 {
                
                // Create hook, after fire substract health points
                let afterFireSubstractHealth = {
                    // Only substract health points from master damagable node
                    damagable.subtractHealthPoints(weapon.damagePoints)
                }
                
                // Prepare and run fire action that should last as long the contact is not ended
                let syncedFireAction = SKAction.runBlock({
                    // Only fire when it is allowed (have ammo etc)
                    weapon.syncedFireAndReload(afterFireSubstractHealth, afterReloadInit: nil, afterReloadComplete: nil)
                })
                
                let waitAction = SKAction.waitForDuration(weapon.rateOfFirePerSecond)
                let fireSequence = SKAction.sequence([syncedFireAction, waitAction])
                
                damagable.getAffectedSKNode().runAction(SKAction.repeatActionForever(fireSequence), withKey: uniqueActionKey)
            }
            
            return true
        }
    }
    
}