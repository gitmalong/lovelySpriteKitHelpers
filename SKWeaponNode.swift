//
//  Weapon.swift
//
//  Created by gitmalong on 21.04.16.
//
/* 
 
 Implements a basic weapon with ammo, magazine, fire and reload methods. 
 
 You can pass hooks that are triggered for certain events (i.e. to play sound effects)
 - after the weapon fires
 - after the weapon starts to reload
 - after the weapon was reloaded
 
 Usage in SpriteKit:
 
 1) Create a an instance of a SKWeapon conform class (you may use SKWeaponGenerator)
 
 2) a) If you don't want to care a lot about when it should be allowed to fire (i.e. when the user touches your fire button) just call syncedFireAndReload(). It will try to fire everytime its possible and reloads automatically after a defined time span. Optionally you can pass hooks in form of blocks for the previously mentioned events
 
    b) Create your own fire logic with help of the available methods and variables

 */

import Foundation
import SpriteKit

/* Basic weapon protocol */
protocol Weapon:class {

    /// Time that should be waited for before it is allowed to fire again
    var rateOfFirePerSecond:NSTimeInterval { get set }
    
    /** If set to true syncedFireAndReload() does not subtract any ammo and allowedToFire() returns true even if ammo is 0. As a result reload() is never called on syncedFireAndReload().
     */
    var infiniteAmmo:Bool { get set }
    
    /// Ammo of the current magazine, set to 0 when infiniteAmmo is true
    var ammoOfCurrentMagazine:Int { get set }
    
    /// Ammo capacity of one magazine, set to 0 when infiniteAmmo is true
    var magazineSize:Int { get set }
    
    /// Remaining available magazines, set to 0 when infiniteAmmo is true
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
    
    /// Reloads weapon - Replaces ammoOfCurrentMagazine with magazineSize
    func reload()
    
    /// Reloads weapon, sets justReloading state, waits reloadTimeSeconds and calls hooks
    func reloadAndWait(afterReloadInit:(()->Void)?, afterReloadComplete:(()->Void)?) -> Void
    
    /// Subtracts 1 from ammoOfCurrentMagazine
    func subtractAmmo() -> Void
    
    /// Will only subtract ammo if infiniteAmmo == false
    func syncedSubtractAmmo() -> Void
    
    /// Fires, sets justFiring to true and after rateOfFirePerSecond seconds to false, calls hook
    func fireAndWait(afterFired:(()->Void)?) -> Void
    
    /// return magazineSize > 0 && justReloading == false && justFiring == false
    func allowedToReload() -> Bool
    
    /// return justFiring == false && justReloading == false && ammoOfCurrentMagazine > 0
    func allowedToFire() -> Bool
    
    /// Returns unique identifier for object instance
    func getWeaponID() -> String
    
    /// Fires and reloads automatically when it is allowed
    func syncedFireAndReload(afterFired:(()->Void)?, afterReloadInit:(()->Void)?, afterReloadComplete:(()->Void)?)
    
    /// Fires when it is allowed
    func syncedFire(afterFired:(()->Void)?)
    
    /// Reloads when it is allowed
    func syncedReload(afterReloadInit:(()->Void)?, afterReloadComplete:(()->Void)?)
}

/**
 Default implementation for weapon protocol
 
 Following methods have not been implemented cause the wait() methods
 should be system / framework specific:
 reloadAndWait(), fireAndWait()
 syncedFireAndReload
 */
extension Weapon {

    /// Returns unique identifier for that weapon object
    func getWeaponID()->String {
        return String(ObjectIdentifier(self))
    }
    
    /// tells you if it is allowed to reload the weapon
    func allowedToReload()->Bool {
        return magazineSize > 0 && justReloading == false && justFiring == false
    }
    
    /// tells you if it is allowed to fire. depending if weapon is just firing or just reloading. If infiniteAmmo is true it will return true even if ammoOfCurrentMagazine is 0
    /// - Returns: Bool
    func allowedToFire()->Bool {
        return justFiring == false && justReloading == false && (infiniteAmmo == true || ammoOfCurrentMagazine > 0)
    }
    
    /// reloads the weapon. it discards current ammoOfCurrentMagazine and use a new magazine to refill it
    /// - Returns: Bool
    func reload() {
        ammoOfCurrentMagazine = magazineSize
        remainingMagazines = remainingMagazines-1
    }
    
    /// Subtracts 1 from ammoOfCurrentMagazine. Does not include safety checks if there is enough ammo or not!
    func subtractAmmo() {
        ammoOfCurrentMagazine = ammoOfCurrentMagazine-1
    }
    
    /// Subtracts ammo if infiniteAmmo is false
    func syncedSubtractAmmo() {
        if infiniteAmmo == false {
            subtractAmmo()
        }
    }
    
    /// only fires and automatically reloads when it is allowed
    func syncedFireAndReload(afterFired:(()->Void)?, afterReloadInit:(()->Void)?, afterReloadComplete:(()->Void)?) {
        
        if allowedToFire() {
            fireAndWait(afterFired)
        } else if (infiniteAmmo == false && ammoOfCurrentMagazine == 0) && allowedToReload() {
            // Reload
            reloadAndWait(afterReloadInit, afterReloadComplete: afterReloadComplete)
        }
    }
    
    /// Fires when it is allowed to fire
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
   unowned var sknode:SKNode { get set }
}

/* Implements SpriteKit specific wait methods for weapon protocol */
extension SKWeapon {
    
    /// Fires and disallow fire for rateOfFirePerSecond seconds
    /// - Parameter afterFired: Optional block closure that is executed after the weapon fired
    /// - Returns: void
    func fireAndWait(afterFired:(()->Void)?) {
        
        justFiring = true
            
        syncedSubtractAmmo()
        
        if let afhook = afterFired {
            afhook()
        }
            
        // Wait
        let rateOfFireWait = SKAction.waitForDuration(rateOfFirePerSecond)
        let allowFireBlock = SKAction.runBlock {
            self.justFiring = false
        }
            
        let waitSequenceAction = SKAction.sequence([rateOfFireWait, allowFireBlock])
        sknode.runAction(waitSequenceAction)
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
        sknode.runAction(waitAndAllowReloadSeq)
    }
}

protocol hasSKWeapon {
    var weapon:SKWeapon? { get set }
}

/// Inits class that conforms to SKWeapon
class SKWeaponGenerator: SKWeapon {
    
    // SKWeapon
    unowned var sknode:SKNode
    
    // Weapon
    var infiniteAmmo: Bool
    var ammoOfCurrentMagazine:Int
    var magazineSize:Int
    var remainingMagazines:Int
    var rateOfFirePerSecond:NSTimeInterval
    var reloadTimeSeconds:NSTimeInterval
    var damagePoints:Int
    var justFiring:Bool
    var justReloading:Bool
    var autoReload:Bool
    
    // Inits default weeapon
    init(ammoOfCurrentMagazine:Int, magazineSize:Int, remainingMagazines:Int, rateOfFirePerSecond:NSTimeInterval, reloadTimeSeconds:NSTimeInterval, damagePoints:Int, autoReload:Bool, sknode:SKNode) {
        self.infiniteAmmo = false
        self.ammoOfCurrentMagazine = ammoOfCurrentMagazine
        self.magazineSize = magazineSize
        self.remainingMagazines = remainingMagazines
        self.rateOfFirePerSecond = rateOfFirePerSecond
        self.reloadTimeSeconds = reloadTimeSeconds
        self.damagePoints = damagePoints
        justFiring = false
        justReloading = false
        self.autoReload = autoReload
        self.sknode = sknode
    }
    
    /// Inits weapon with infinite ammo and that is never be reloaded
    init(rateOfFirePerSecond:NSTimeInterval, damagePoints:Int, sknode:SKNode) {
        self.infiniteAmmo = true
        self.ammoOfCurrentMagazine = 0
        self.magazineSize = 0
        self.remainingMagazines = 0
        self.rateOfFirePerSecond = rateOfFirePerSecond
        self.reloadTimeSeconds = 0
        self.damagePoints = damagePoints
        justFiring = false
        justReloading = false
        self.autoReload = true
        self.sknode = sknode
    }
    
}