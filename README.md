# lovelySpriteKitHelpers

classes that make the life with SpriteKit easier

#EndlessBackgroundNode.swift

Node for an endless vertically scrolling background that duplicates your background depending on the SKCameraNode's position.
Supports parallax backgrounds as well

#ParallaxBackgroundMover.swift

ParallaxBackgroundMover provides parallax background functionality by moving your backgrounds by factor x,y in relation to your SKCameraNodes speed
  
#EndlessParallaxBackgroundCamera.swift
This SKCameraNode subclass triggers EndlessBackgroundNode & ParallaxBackgroundMover everytime when the cameras position is changed
