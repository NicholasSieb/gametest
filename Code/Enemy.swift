import SpriteKit

class Enemy: Sprite {
    var startAtTop: Bool!
    var disabled: Bool = false
    let vel: CGFloat = 4
    let kEnemyCategory: UInt32 = 0x1 << 0

    init(x: CGFloat, y: CGFloat, startAtTop: Bool) {
        super.init(named: "enemy", x: x, y: y)
        self.startAtTop = startAtTop
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 30, height: 30))
        self.physicsBody!.dynamic = true
        self.physicsBody!.collisionBitMask = 0x0
        self.physicsBody!.contactTestBitMask = 0x0
        self.physicsBody!.categoryBitMask = kEnemyCategory
        self.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(1, duration: 1)))
    }

    func setDisabled() {
        disabled = true
        self.texture = SKTexture(imageNamed: "enemydisabled")
    }

    func isDisabled() -> Bool {
        return disabled
    }

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

    func move() {
        moveBy(0, dy: startAtTop.boolValue ? -vel : vel)
    }

    func moveBy(dx: CGFloat, dy: CGFloat) {
        self.position = CGPointMake(self.position.x + dx, self.position.y + dy)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}