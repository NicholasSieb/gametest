

import Foundation
import SpriteKit

class Joystick : SKNode {
    let SpringBack: Double = 0.3
    let backgroundNode, selectorNode: SKSpriteNode
    var isTracking: Bool = false
    var velocity: CGPoint = CGPointMake(0, 0)
    var travelLimit: CGPoint = CGPointMake(0, 0)
    var angularVelocity: CGFloat = 0.0
    var size: CGFloat = 0.0
    
    
    /// Return origin
    func anchorPoint() -> CGPoint{
        return CGPointMake(0,0)
    }
    
    /// Creates joystick sprite
    ///
    /// - parameter selectorNode, texture to use for selector
    /// - parameter backgroundNode, texture for background
    /// - Usage Sprite constructor
    init(selectorNode: SKSpriteNode = SKSpriteNode(imageNamed: "jbackground.png"), backgroundNode: SKSpriteNode = SKSpriteNode(imageNamed: "selector.png")) {
        
        self.selectorNode = selectorNode
        self.backgroundNode = backgroundNode
        
        super.init()
        
        self.addChild(self.backgroundNode)
        self.addChild(self.selectorNode)
        self.xScale = 1.8
        self.yScale = 1.8
        
        self.userInteractionEnabled = true
    }

    ///Override touchesbegan handler
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchPoint: CGPoint = touch.locationInNode(self)
            if self.isTracking == false && CGRectContainsPoint(self.selectorNode.frame, touchPoint) {
                self.isTracking = true
            }
        }
    }
    
    ///Override touchesmoved handler
    ///Responsible for calculating x,y movement as well as rotation
    ///Also responsible for updating position of selectorNode
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchPoint: CGPoint = touch.locationInNode(self)
            
            if self.isTracking == true && sqrtf(powf((Float(touchPoint.x) - Float(self.selectorNode.position.x)), 2) + powf((Float(touchPoint.y) - Float(self.selectorNode.position.y)), 2)) < Float(self.selectorNode.size.width) {
                if sqrtf(powf((Float(touchPoint.x) - Float(self.anchorPoint().x)), 2) + powf((Float(touchPoint.y) - Float(self.anchorPoint().y)), 2)) <= Float(self.selectorNode.size.width) {
                    let moveDifference: CGPoint = CGPointMake(touchPoint.x - self.anchorPoint().x, touchPoint.y - self.anchorPoint().y)
                    self.selectorNode.position = CGPointMake(self.anchorPoint().x + moveDifference.x, self.anchorPoint().y + moveDifference.y)
                } else {
                    let vX: Double = Double(touchPoint.x) - Double(self.anchorPoint().x)
                    let vY: Double = Double(touchPoint.y) - Double(self.anchorPoint().y)
                    let magV: Double = sqrt(vX*vX + vY*vY)
                    let aX: Double = Double(self.anchorPoint().x) + vX / magV * Double(self.selectorNode.size.width)
                    let aY: Double = Double(self.anchorPoint().y) + vY / magV * Double(self.selectorNode.size.width)
                    self.selectorNode.position = CGPointMake(CGFloat(aX), CGFloat(aY))
                }
            }
            self.velocity = CGPointMake(((self.selectorNode.position.x - self.anchorPoint().x)), ((self.selectorNode.position.y - self.anchorPoint().y)))
            self.angularVelocity = -atan2(self.selectorNode.position.x - self.anchorPoint().x, self.selectorNode.position.y - self.anchorPoint().y)
        }
    }
    
    ///Override touches ended, make sure to reset movement
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.resetVelocity()
    }
    
    ///Override touches ended, make sure to reset movement
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.resetVelocity()
    }
    
    ///Method to reset joystick to zero position and movement
    func resetVelocity() {
        self.isTracking = false
        self.velocity = CGPointZero
        let easeOut: SKAction = SKAction.moveTo(self.anchorPoint(), duration: SpringBack)
        easeOut.timingMode = SKActionTimingMode.EaseOut
        self.selectorNode.runAction(easeOut)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}