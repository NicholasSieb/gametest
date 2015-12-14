import SpriteKit


class Player: Sprite {
    var fireArray = Array<SKTexture>();
    //variables for laser modification
    //var laserColor = UIColor.greenColor()
    var laserColor = UIColor(red: 0.09, green: 0.52, blue: 0.18, alpha:1.0)
    var laserSize = 10
    var boxSize = 30
    //Here is the variable we use to increase the user's ship speed
    var speedTwo: CGFloat = 6
    var joystickSpeed: CGFloat = 0.15
    //Here is the variable we use to determine the laser's speed
    var velocity = (70/1.0)
    //set collision info
    let kBulletCategory: UInt32 = 0x1 << 1
    let kEnemyCategory: UInt32 = 0x1 << 0
    let kPlayerCategory: UInt32 = 0x1 << 2
    let kBossCategory: UInt32 = 0x1 << 3

    
    

    /// Creates player sprite
    ///
    /// - parameter x, x starting coord
    /// - parameter y, y starting coord
    /// - Usage Sprite constructor
    init(x: CGFloat, y: CGFloat) {
        super.init(named: "ship", x: x, y: y)
        self.setScale(1.4)
        //set physics properties
        self.physicsBody = SKPhysicsBody.init(texture: self.texture!, size: self.size)
        //self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 50, height: 50))
        self.physicsBody!.dynamic = true
        self.physicsBody!.collisionBitMask = 0x0
        self.physicsBody!.contactTestBitMask = 0x0
        self.physicsBody!.categoryBitMask = kPlayerCategory
        self.physicsBody!.contactTestBitMask = kEnemyCategory | kBossCategory
        exhaust()
    }
 
    /// Creates exhaust trails under player
    ///
    /// - Usage player.exhaust()
    func exhaust(){
        let emitterNode = SKEmitterNode(fileNamed: "EngineExhaust.sks")
        emitterNode?.position = CGPoint(x: 0.5, y: -19.6)
        emitterNode?.setScale(0.70)
        self.addChild(emitterNode!)
        
    }
    

     /// This function handles creation of laser sprites
     ///
     /// - Usage player.shoot(x1,y1,x2,y2)
     /// - parameter x1 x coord of player
     /// - parameter y1 y coord of player
     /// - parameter x2 x coord of touch
     /// - parameter y2 y coord of touch
    func shoot(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat){
        
        var dx: CGFloat, dy: CGFloat
        // Compute vector components in direction of the touch
        dx = x2 - self.position.x
        dy = y2 - self.position.y + 50
        //Avoid shooting when ship isn't moving much/at all
        if (dx >= 10 || dx <= -10) && (dy >= 10 || dy <= 10) {
        let laser = SKSpriteNode()
        laser.color = laserColor
        laser.size = CGSize(width: laserSize, height: laserSize)
        laser.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: boxSize, height: boxSize))
        laser.physicsBody!.dynamic = true
        laser.physicsBody!.usesPreciseCollisionDetection = true
        laser.physicsBody!.collisionBitMask = 0x0;
        laser.physicsBody!.velocity = CGVectorMake(0,0);
        laser.physicsBody!.categoryBitMask = kBulletCategory
        laser.physicsBody!.contactTestBitMask = kEnemyCategory | kBossCategory
        
        //get locations touch first then player
        let location = CGPointMake(x2, y2)
        let projLoc = CGPointMake(x1, y1)
        
        laser.position = projLoc
            
        laser.name = "laser"
        
        
        //calculate offset of location to projectile
        let offset = Utility.vecSub(location, b: projLoc)
        
        
        //add a laser
        self.parent?.addChild(laser)
        
        //get direction to shoot in
        let direction = Utility.vecNormalize(offset)
        
        //move endpoint of triangle far (offscreen hopefully)
        let shootAmount = Utility.vecMult(direction, b: 1000)
            
        
        //add shoot amount to curr pos
        let realDest = Utility.vecAdd(shootAmount, b: laser.position)
        
        
        //let velocity = (300/1.0)
            
        //actions
        
        let realMoveDuration = Double(self.size.width) / velocity
        let moveAction = SKAction.moveTo(realDest, duration: realMoveDuration)
        let removeAction = SKAction.removeFromParent()
        laser.runAction(SKAction.sequence([moveAction, removeAction]))
            
        }
    }
    /// Handles updating movement of player
    ///
    /// - Usage player.moveTo(x,y)
    /// - parameter x, x coord of touch
    /// - parameter y, y coord of touch
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
    
    /// This function handles creation of laser sprites JOYSTICK EDITION
    ///
    /// - Usage player.shoot(x1,y1,x2,y2)
    /// - parameter x1 x coord of player
    /// - parameter y1 y coord of player
    /// - parameter x2 x coord of touch
    /// - parameter y2 y coord of touch
    func shootJoy(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat){
        //this version passes in player loc and joystick coords
        
        
            let laser = SKSpriteNode()
            laser.color = laserColor
            laser.size = CGSize(width: laserSize, height: laserSize)
            laser.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: boxSize, height: boxSize))
            laser.physicsBody!.dynamic = true
            laser.physicsBody!.usesPreciseCollisionDetection = true
            laser.physicsBody!.collisionBitMask = 0x0;
            laser.physicsBody!.velocity = CGVectorMake(0,0);
            laser.physicsBody!.categoryBitMask = kBulletCategory
            laser.physicsBody!.contactTestBitMask = kEnemyCategory | kBossCategory
            
            //get locations touch first then player
            let location = CGPointMake(x2, y2)
            let projLoc = CGPointMake(x1, y1)
            
            laser.position = projLoc
            
            laser.name = "laser"
            
            //add a laser
            self.parent?.addChild(laser)
            
            //get direction to shoot in
            let direction = Utility.vecNormalize(location)
            
            //move endpoint of triangle far (offscreen hopefully)
            let shootAmount = Utility.vecMult(direction, b: 1000)
            
            //add shoot amount to curr pos
            let realDest = Utility.vecAdd(shootAmount, b: laser.position)
            //print(realDest)
            //let velocity = (300/1.0)
            
            //actions
            
            let realMoveDuration = Double(self.size.width) / velocity
            let moveAction = SKAction.moveTo(realDest, duration: realMoveDuration)
            let removeAction = SKAction.removeFromParent()
            laser.runAction(SKAction.sequence([moveAction, removeAction]))
        
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
