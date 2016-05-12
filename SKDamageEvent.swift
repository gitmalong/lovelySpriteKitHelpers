//
//  SKDamagingEvent.swift
//
//  Created by gitmalong
//
//

import Foundation

/**
 SKDamageEvent & SKSKDamagableEventManager
 In SpriteKit you often like to trigger events based on collision or contact. Sometimes you want to prevent that a unique event gets triggered multiple times by SpriteKits physic engine. For example if your enemies bullet hits your character you may want to apply it only once and not every time SpriteKit recognizes a contact or collision.
 
 This two classes/protocols help you to synchronize such events.
 
 Example Usage
 
 Let's assume you have a character that should be damaged every second while he is touching a enemy.
 
 1) Extend your character node with SKDamagableEventManager
    It stores all the events that are applied to your object.
 
 2) Before you apply damage to your character you need to check when the last damage event was applied. You can use the SKDamagableEventManager method lastTimeOfDamageEventApplication(weaponID:String)
 
    Note: Every damage event should get a uniqueID (weaponID:String). In this case it can be the same all the time. If you have a gun you way want to use different ids
     for every bullet.
 
 
    If the last time the event was applied is more than one second ago, create a new SKDamageEvent, set it to applied, add it your damage event manager (damageEvents) and continue with your own logic.

*/
class SKDamageEvent {
    
    /// True if damaging event was applied, false if not
    var applied:Bool
    
    /// Time on that the damaging event was applied to the target
    var appliedTime:NSTimeInterval?
    
    /// Weapon identifier for the weapon that created this damaging event
    var weaponID:String
    
    /// Health points that are or should be subtracted by this event
    var damagePoints:Int
    
    /// Created time
    var createdTime:NSTimeInterval
    
    /// Passed time since createTime
    var timePassed:NSTimeInterval {
        return NSDate().timeIntervalSince1970 - createdTime
    }
    
    /// Sets damaging events applied status to true and saves the time
    func apply() {
        applied = true
        appliedTime = NSDate().timeIntervalSince1970
    }
    
    /**
    - Parameter damagePoints: damagePoints that should be subtracted on the target
    - Parameter weaponID: unique weapon ID/identifier that created this event
    */
    init(damagePoints:Int, weaponID:String) {
        applied = false
        appliedTime = nil
        createdTime = NSDate().timeIntervalSince1970
        self.weaponID = weaponID
        self.damagePoints = damagePoints
    }
    
}

/// Manages and stores objects of type SKDamageEvent
protocol SKDamagableEventManager:class {
    
    /// Stores all damage events
    var damageEvents: [SKDamageEvent] { get set }
    
    /// Returns time of last application of a certain weapon
    func lastTimeOfDamageEventApplication(weaponID:String) -> NSTimeInterval?
    
    /// Returns count of not applied damage events of a certain weapon
    func countNotAppliedDamageEvents(weaponID:String) -> Int
    
    /// Returns not applied damage event
    func getNotAppliedDamageEvent(weaponID:String) -> SKDamageEvent?
    
}

/// Manages and stores objects of type SKDamageEvent
extension SKDamagableEventManager {
    
    /// Returns a not applied damage event for a certain weapon
    func getNotAppliedDamageEvent(weaponID:String) -> SKDamageEvent? {
        return damageEvents.filter({$0.applied == false && $0.weaponID == weaponID}).first
    }
    
    /// Returns time of last application of a certain weapon
    func lastTimeOfDamageEventApplication(weaponID:String) -> NSTimeInterval? {
        let filteredEvents = damageEvents.filter({$0.weaponID == weaponID})
        return filteredEvents.maxElement({ $0.appliedTime < $1.appliedTime })?.appliedTime
    }
    
    /// Returns not applied damage events of a certain weapon
    func countNotAppliedDamageEvents(weaponID:String) -> Int {
        return damageEvents.filter({$0.applied == false && $0.weaponID == weaponID}).count
    }
    
}