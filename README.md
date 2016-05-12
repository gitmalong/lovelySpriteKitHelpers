# lovelySpriteKitHelpers

I’m creating a SpriteKit 2D platform game in Swift and want to share 
my protocols/extensions/classes that make the life with SpriteKit easier. My focus is on keeping the code modular for easy reuse in other projects

###EndlessBackgroundNode.swift

Node for an endless vertically scrolling background that duplicates your background depending on the SKCameraNode's position and removes it after a certain distance again.
Supports parallax backgrounds as well

###ParallaxBackgroundMover.swift

Provides parallax background functionality by moving your backgrounds by factor x,y in relation to your SKCameraNodes speed
  
###EndlessParallaxBackgroundCamera.swift
Subclass of SKCameraNode that triggers EndlessBackgroundNode & ParallaxBackgroundMover every time when the cameras position is changed

###SKWeaponSpriteNode.swift
Implements a basic weapon with ammo, magazine, reload & rateOfFire time span and more
 
You can pass hooks for certain events (i.e. to play sound effects)

 - after the weapon fires

 - after the weapon starts to reload

 - after the weapon was reloaded
 
###SKDamagableSpriteNode.swift
Adds "damagable" functionality to a SKNode
 
 - Node gets life points that can be substracted

 - onDeath() is triggered when the node "dies"

 - Support for nodes that have children. Use it when all of them should be able to get damaged but the life points (of the parent node) should only be subtracted once for each damaging event (i.e. when the hero's body parts are all children and both feets are contacted by the same fire)

###SKWeaponDamagableContactBridge.swift
Manages the contact between objects that conform to type SKWeapon and SKDamagable
 In other words: Applies damage and stops damage application between SKWeapon's and SKDamagable's based on the call of SpriteKits SKSzene didBeginContact() & didEndContact() methods
 
###SKDamageEvent.swift
 In SpriteKit you often like to trigger events based on collision or contact. Sometimes you want to prevent that a unique event gets triggered multiple times by SpriteKits physic engine. For example if your enemie's bullet hits your character you may want to apply the damage only once and not every time SpriteKit recognizes a contact or collision. This two classes/protocols help you to synchronize such events.
