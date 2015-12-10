import SpriteKit

class Enemy: Sprite {
    //determines starting position
    var startAtTop: Bool!
    var disabled: Bool = false
    //speed of enemy movement
    let vel: CGFloat = 4
    var dir: [CGFloat] = [0,0]
    var currAngle = CGFloat(0)
    let radius: CGFloat = 2
    //set collision category
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
        //action if enemy is desabled
        if isDisabled() || position.y > height! - 200 || position.y < 200 {
            move()
        }
        //else send enemy randomly toward the rocket
        else {
            var playDir = [point.x - self.position.x, point.y - self.position.y]
            let mag = sqrt(playDir[0] * playDir[0] + playDir[1] * playDir[1])
            // Normalize
            playDir[0] = playDir[0] / mag
            playDir[1] = playDir[1] / mag
            
            
            //compute direction
            //initial state
            if (self.dir[0] == 0 && self.dir[1] == 0){
                self.dir = playDir
                self.currAngle = atan2(self.dir[1], self.dir[0]) % (2*3.1415)
            }
            else {
                self.currAngle = (self.currAngle + (0.05)) % (2*3.1415)
                self.dir = [self.radius*cos(self.currAngle), self.radius*sin(self.currAngle)];
            }
            
            //combine the two vectors and add in velocity
            var final = [vel * (playDir[0] + self.dir[0])/2,vel * (playDir[1] + self.dir[1])/2]
            
            moveBy(final[0], dy: final[1])
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
    
    /// Functions to update actions of enemy
    ///
    /// - parameter isGameOver to let us know when game is over
    /// - parameter x, rocket x position
    /// - parameter y, rocket y position
    /// - usage called during enumeration
    func enemyAI(scene: SKScene, isGameOver: Bool, x: CGFloat, y: CGFloat) {
        let y = scene.position.y
        //check if player connected with enemy
        if !isGameOver {
            //update enemy movement
            self.moveTo(CGPointMake(x, y))
        } else {
            //game is over still move enemy tho
            self.move()
        }
        //check enemy bounds
        if y < 0 || y > size.height {
            self.removeFromParent()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}