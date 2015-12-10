import SpriteKit

class Enemy: Sprite {
    var startAtTop: Bool!
    var disabled: Bool = false
    let vel: CGFloat = 4
    let kEnemyCategory: UInt32 = 0x1 << 0
    var shot: Bool = false
    /// Creates enemy sprite
    ///
    /// - parameter x, x starting coord
    /// - parameter y, y starting coord
    /// - parameter startAtTop, choose starting position
    /// - Usage Sprite constructor
    init(x: CGFloat, y: CGFloat, startAtTop: Bool) {
        super.init(named: "enemy", x: x, y: y)
        self.startAtTop = startAtTop
        self.setScale(0.8)
        //set physics properties
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 60, height: 60))
        self.physicsBody!.dynamic = true
        self.physicsBody!.collisionBitMask = 0x0
        self.physicsBody!.contactTestBitMask = 0x0
        self.physicsBody!.categoryBitMask = kEnemyCategory
        self.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(1, duration: 1)))
    }
    /// Deprecated method consider removal
    func setDisabled() {
        disabled = true
        self.texture = SKTexture(imageNamed: "enemydisabled")
    }
    

    /// Deprecated method consider removal
    func isDisabled() -> Bool {
        return disabled
    }
    /// Handles updating movement of enemy
    ///
    /// - Usage enemy.moveTo(point)
    /// - parameter point, CGPoint to move towards
    func moveTo(point: CGPoint) {
        let height = parent?.scene?.size.height
        if height == nil {
            return
        }
        if isDisabled() || position.y > height! - 200 || position.y < 200 {
            move()
        } else {
            var dx = point.x - self.position.x
            var dy = point.y - self.position.y
            let mag = sqrt(dx * dx + dy * dy)
            // Normalize and scale
            dx = dx / mag * vel
            dy = dy / mag * vel
            moveBy(dx, dy: dy)
        }
    }
    ///Move helper function
    func move() {
        moveBy(0, dy: startAtTop.boolValue ? -vel : vel)
    }
    ///Move helper function
    func moveBy(dx: CGFloat, dy: CGFloat) {
        self.position = CGPointMake(self.position.x + dx, self.position.y + dy)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}