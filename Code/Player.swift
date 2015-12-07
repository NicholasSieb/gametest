import SpriteKit


class Rocket: Sprite {
    var fireArray = Array<SKTexture>();
    var laserColor = UIColor.redColor()
    var laserSize = 5
    var boxSize = 30
    //Here is the variable we use to increase the user's ship speed
    var speedTwo: CGFloat = 12
    //Here is the variable we use to determine the laser's speed
    var velocity = (300/1.0)
    let kBulletCategory: UInt32 = 0x1 << 1
    let kEnemyCategory: UInt32 = 0x1 << 0

    
    


    init(x: CGFloat, y: CGFloat) {
        super.init(named: "rocket", x: x, y: y)
        self.setScale(2.0)
        fire()
    }

    func fire() {
        for index in 0 ... 2 {
            fireArray.append(SKTexture(imageNamed: "fire\(index)"))
        }
        let fire = SKSpriteNode(texture: fireArray[0]);
        fire.anchorPoint = CGPoint(x: 0.5, y: 1.3)
        self.addChild(fire)
        let animateAction = SKAction.animateWithTextures(self.fireArray, timePerFrame: 0.10);
        fire.runAction(SKAction.repeatActionForever(animateAction))
    }
    
    
    //func to shoot the lasers
    //move lasers here so it's easier to modify (for upgrades possibly)
    func shoot(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat){
        //this version passes in player loc and touch loc
        let laser = SKSpriteNode()
        laser.color = laserColor
        laser.size = CGSize(width: laserSize, height: laserSize)
        
        laser.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: boxSize, height: boxSize))
        laser.physicsBody!.dynamic = true
        laser.physicsBody!.usesPreciseCollisionDetection = true
        laser.physicsBody!.collisionBitMask = 0x0;
        laser.physicsBody!.velocity = CGVectorMake(0,0);
        laser.physicsBody!.categoryBitMask = kBulletCategory
        laser.physicsBody!.contactTestBitMask = kEnemyCategory
        
        //get locations touch first then player
        let location = CGPointMake(x2, y2)
        let projLoc = CGPointMake(x1, y1)
        
        laser.position = projLoc
        
        
        //calculate offset of location to projectile
        let offset = Utility.vecSub(location, b: projLoc)
        
        
        //add a laser
        self.parent?.addChild(laser)
        //self.addChild(laser)
        
        //get direction to shoot in
        let direction = Utility.vecNormalize(offset)
        
        //move endpoint of triangle far (offscreen hopefully)
        let shootAmount = Utility.vecMult(direction, b: 1000)
        
        //add shoot amount to curr pos
        let realDest = Utility.vecAdd(shootAmount, b: laser.position)
        
        //actions
    
        
        //let velocity = (300/1.0)
        let realMoveDuration = Double(self.size.width) / velocity
        let moveAction = SKAction.moveTo(realDest, duration: realMoveDuration)
        let removeAction = SKAction.removeFromParent()
        laser.runAction(SKAction.sequence([moveAction, removeAction]))
        
        
    }

    func moveTo(x: CGFloat, y: CGFloat) {
        let speed: CGFloat = speedTwo
        var dx: CGFloat, dy: CGFloat
        // Compute vector components in direction of the touch
        dx = x - self.position.x
        dy = y - self.position.y + 50
        self.zRotation = atan2(dy + 100, dx) - CGFloat(M_PI_2)
        //Do not move if tap is on sprite
        if (dx >= 1 || dx <= -1) && (dy >= 1 || dy <= 1) {
            let mag = sqrt(dx * dx + dy * dy)
            // Normalize and scale
            dx = dx / mag * speed
            dy = (dy + 50) / mag * speed
            self.position = CGPointMake(self.position.x + dx, self.position.y + dy)
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
