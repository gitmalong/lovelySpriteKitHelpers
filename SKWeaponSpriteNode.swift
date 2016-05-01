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

/* Basic weapon protocol  */
protocol Weapon:class {
    
    var rateOfFirePerSecond:NSTimeInterval { get set } // time that should be waited between two shots
    var ammoOfCurrentMagazine:Int { get set } // Ammo of current magazine
    var magazineSize:Int { get set } // Ammo capacity of one magazine
    var remainingMagazines:Int { get set } // Remaining available magazines
    var reloadTimeSeconds:NSTimeInterval { get set } // Time that should be waited before the reload completes
    var damagePoints:Int { get set } // damage points for every shot
    
    var justFiring:Bool { get set } // tells you if weapon is just firing
    var justReloading:Bool { get set } // tells you if weapon is just reloading
    var autoReload:Bool { get set } // tries to reload if current magazine is empty and it should be fired
    
    func getRemainingShotsOfCurrentMagazine() -> Int
    func reload()
    func reloadAndWait(afterReloadInit:(()->Void)?, afterReloadComplete:(()->Void)?) -> Void // reloads weapon within the reloadTimeSeconds time span, should deal with justFiring var
    func fire() -> Void
    func fireAndWait(afterFired:(()->Void)?) -> Void // fire and disallow next shot till rateOfFirePerSecond time is passed, should deal with justReloading var
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
    
    func getRemainingShotsOfCurrentMagazine()->Int {
        return ammoOfCurrentMagazine
    }
    
    func allowedToReload()->Bool {
        return magazineSize > 0 && justReloading == false && justFiring == false
    }
    
    func allowedToFire()->Bool {
        return justFiring == false && justReloading == false && getRemainingShotsOfCurrentMagazine() > 0
    }
    
    func reload() {
        ammoOfCurrentMagazine = magazineSize
        remainingMagazines = remainingMagazines-1
    }
    
    func fire() {
        ammoOfCurrentMagazine = ammoOfCurrentMagazine-1
    }
    
    /* only fires and automatically reloads when it is allowed */
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
    
    /* Only fires when it is allowed to fire */
    func syncedFire(afterFired:(()->Void)?) {
        if allowedToFire() {
            fireAndWait(afterFired)
        }
    }
    
    /* Only reloads when it is allowed to reload */
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