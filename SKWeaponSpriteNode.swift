//
//  Weapon.swift
//
//  Created by gitmalong on 21.04.16.
//
/* 
 
 Implements a basic weapon with ammo, magazine, fire and reload methods. 
 
 You can pass hooks that can be triggered for certain events (i.e. to trigger sound effects)
 - after the weapon fires
 - after the weapon starts to reload
 - after the weapon was reloaded
 
 Usage in SpriteKit:
 
 1) Create a subclass that inherits from SK(Sprite)Node and SKWeapon
 
 2) Init ammoOfCurrentMagazine, rateOfFirePerSecond, magazineSize, remainingMagazines, reloadTimeSeconds and damagePoints in your subclass
 
 3) a) If you don't want to care a lot about when it should be allowed to fire (i.e. when the user touches your fire button) just call syncedFireAndReload(). It will try to fire everytime its possible and reloads automatically after a defined time span. Optionally you can pass hooks in form of blocks for the previously mentioned events
 
    b) Create your own fire logic with help of the available methods and variables

 */

import Foundation
import SpriteKit

/*
class Bullet {
    var applied:Bool
    var weapon:SKWeapon // weapon that fired that bullet
    
    init(weapon:SKWeapon) {
        applied = false
        self.weapon = weapon
    }
    
    func getID() {
        // return ObjectIdentifier(self)
    }
}*/

/* Basic weapon protocol */
protocol Weapon:class {

    /// Time that should be waited for before it is allowed to fire again
    var rateOfFirePerSecond:NSTimeInterval { get set }
    
    /// Ammo of the current magazine
    var ammoOfCurrentMagazine:Int { get set }
    
    /// Ammo capacity of one magazine
    var magazineSize:Int { get set }
    
    /// Remaining available magazines
    var remainingMagazines:Int { get set }
    
    /// Time it should take to reload the weapon
    var reloadTimeSeconds:NSTimeInterval { get set }
    
    /// Damage points every shot should subtract
    var damagePoints:Int { get set }
    
    /// Is true if weapon is just firing, false if not
    var justFiring:Bool { get set }
    
    /// Is True if weapon is just being reloaded, false if not
    var justReloading:Bool { get set }
    
    /// Set to true if weapon should be reloaded automatically when the magazine is empty, false if not
    var autoReload:Bool { get set }
    
    func getRemainingShotsOfCurrentMagazine() -> Int
    
    func reload()

    func reloadAndWait(afterReloadInit:(()->Void)?, afterReloadComplete:(()->Void)?) -> Void
    
    func fire() -> Void
    func fireAndWait(afterFired:(()->Void)?) -> Void
    func allowedToReload() -> Bool
    func allowedToFire() -> Bool
    
    func syncedFireAndReload(afterFired:(()->Void)?, afterReloadInit:(()->Void)?, afterReloadComplete:(()->Void)?)
    func syncedFire(afterFired:(()->Void)?)
    func syncedReload(afterReloadInit:(()->Void)?, afterReloadComplete:(()->Void)?)
}

/* Default implementation for weapon protocol
 
 Following methods have not been implemented cause the wait() methods
 should be system / framework specific:
 reloadAndWait(), fireAndWait()
 syncedFireAndReload
 */
extension Weapon {
    
    /// returns remaining shots of current magazine
    func getRemainingShotsOfCurrentMagazine()->Int {
        return ammoOfCurrentMagazine
    }
    
    /// tells you if it is allowed to reload the weapon
    func allowedToReload()->Bool {
        return magazineSize > 0 && justReloading == false && justFiring == false
    }
    
    /// tells you if it is allowed to fire. depending if weapon is just firing or just reloading
    /// - Returns: Bool
    func allowedToFire()->Bool {
        return justFiring == false && justReloading == false && getRemainingShotsOfCurrentMagazine() > 0
    }
    
    /// reloads the weapon. it discards current ammoOfCurrentMagazine and use a new magazine to refill it
    /// - Returns: Bool
    func reload() {
        ammoOfCurrentMagazine = magazineSize
        remainingMagazines = remainingMagazines-1
    }
    
    /// Subtracts 1 from ammoOfCurrentMagazine. Does not do any safety checks if there is enough ammo or not!
    func fire() {
        ammoOfCurrentMagazine = ammoOfCurrentMagazine-1
    }
    
    /// only fires and automatically reloads when it is allowed
    func syncedFireAndReload(afterFired:(()->Void)?, afterReloadInit:(()->Void)?, afterReloadComplete:(()->Void)?) {
        
        print("syncedFireAndReload")
        
        if allowedToFire() {
            print("allowedToFire")
            fireAndWait(afterFired)
        } else if (ammoOfCurrentMagazine == 0) && allowedToReload() {
            print("reloadAndWait")
            // Reload
            reloadAndWait(afterReloadInit, afterReloadComplete: afterReloadComplete)
        }
        
    }
    
    /// Only fires when it is allowed to fire
    func syncedFire(afterFired:(()->Void)?) {
        if allowedToFire() {
            fireAndWait(afterFired)
        }
    }
    
    /// Only reloads when it is allowed to reload
    func syncedReload(afterReloadInit:(()->Void)?, afterReloadComplete:(()->Void)?) {
        if allowedToReload() {
            // Reload
            reloadAndWait(afterReloadInit, afterReloadComplete: afterReloadComplete)
        }
    }
}

protocol SKWeapon:Weapon{
   
}

/* Implements SpriteKit specific wait methods for weapon protocol */
extension SKWeapon where Self:SKSpriteNode {
    
    /// Fires and disallow fire for rateOfFirePerSecond seconds
    /// - Parameter afterFired: Optional block closure that is executed after the weapon fired
    /// - Returns: void
    func fireAndWait(afterFired:(()->Void)?) {
        
        justFiring = true
            
        fire()
        
        if let afhook = afterFired {
            afhook()
        }
            
        // Wait
        let rateOfFireWait = SKAction.waitForDuration(rateOfFirePerSecond)
        let allowFireBlock = SKAction.runBlock {
            self.justFiring = false
        }
            
        let waitSequenceAction = SKAction.sequence([rateOfFireWait, allowFireBlock])
        self.runAction(waitSequenceAction)
    }
    
    
    /// Reloads and waits for reloadTimeSeconds seconds
    /// - Parameter afterReloadInit: Optional block closure that is executed after the weapon starts to reload
    /// - Parameter afterReloadComplete: Optional block closure that is executed after the weapon was reloaded
    /// - Returns: Void
    func reloadAndWait(afterReloadInit:(()->Void)?, afterReloadComplete:(()->Void)?) {
        
        justReloading = true
        
        if let initHook = afterReloadInit {
            initHook()
        }
        
        // Wait
        let waitAction = SKAction.waitForDuration(reloadTimeSeconds)
        let allowReloadBlock = SKAction.runBlock {
            self.reload()
            self.justReloading = false
            
            if let finishHook = afterReloadComplete {
                finishHook()
            }
        }
        
        let waitAndAllowReloadSeq = SKAction.sequence([waitAction, allowReloadBlock])
        self.runAction(waitAndAllowReloadSeq)
    }
}