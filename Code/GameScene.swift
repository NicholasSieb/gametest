import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    var viewController: GameViewController?
    let enemySpawnRate = 5
    var isGameOver = false
    var gamePaused = false
    var removeEnemies = false
    var doFireLaser = false
    var scoreboard: Scoreboard!
    var rocket: Player!
    var pause: Pause!
    var laserSize = 5;
    var laserColor = UIColor.greenColor();
    var contactQueue = Array<SKPhysicsContact>()
    let kBulletCategory: UInt32 = 0x1 << 1
    let kEnemyCategory: UInt32 = 0x1 << 0
    var bgMusic:AVAudioPlayer = AVAudioPlayer()
    //here is the button code
    let button = UIButton()
    let buttonTwo = UIButton()
    let buttonThree = UIButton()
    let buttonFour = UIButton()
    let buttonFive = UIButton()
    //Here are variables for delaying the shooting
    var canShoot = true
    var reloadSpeed = 0.3
    //var viewController2: MainMenuScene?
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        Background(size: size).addTo(self)
        //let coolBackGround = SKEmitterNode(fileNamed: "Background")
        //coolBackGround?.position = CGPointMake(size.width/2, size.height)
       // coolBackGround!.zPosition = 0
        //addChild(coolBackGround!)
        var emitterNode = emitterStars(SKColor.lightGrayColor(), starSpeedY: 50, starsPerSecond: 1, starScaleFactor: 0.2)
        emitterNode.zPosition = -10
        self.addChild(emitterNode)
        emitterNode = emitterStars(SKColor.grayColor(), starSpeedY: 30, starsPerSecond: 2, starScaleFactor: 0.1)
        emitterNode.zPosition = -11
        self.addChild(emitterNode)
        emitterNode = emitterStars(SKColor.darkGrayColor(), starSpeedY: 15, starsPerSecond: 4, starScaleFactor: 0.05)
        emitterNode.zPosition = -12
        self.addChild(emitterNode)
        rocket = Player(x: size.width / 2, y: size.height / 2).addTo(self) as! Player
        scoreboard = Scoreboard(x: 50, y: size.height - size.height / 5).addTo(self)
        scoreboard.viewController = self.viewController
        pause = Pause(size: size, x: size.width - 50, y: size.height - size.height / 6).addTo(self)
        self.physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        view.showsPhysics = true
    }
    
    var currentPosition: CGPoint!
    var currentlyTouching = false
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {return}
        currentPosition = touch.locationInNode(self)
        
        let touched = self.nodeAtPoint(currentPosition)
        if let name = touched.name {
            switch name {
            case "gameover":
                resetGame()
            case "pause":
                pauseGame()
            case "home":
                resetGame()
            default:
                currentlyTouching = true
                
            }
            Utility.pressButton(self, touched: touched, score: String(scoreboard.getScore()))
        } else {
            currentlyTouching = true
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {return}
        currentPosition = touch.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        currentlyTouching = false
        
    }
    
    var pausemenu: PopupMenu!
    func pauseGame() {
        if gamePaused {
            
            gamePaused = false
            //speed = 1
            paused = false
            removeDialog()
            removeUpgradeButtons()
        } else {
            if !isGameOver {
                
                if Options.option.get("sound"){
                    let bgMusicURL:NSURL = NSBundle.mainBundle().URLForResource("Pause", withExtension: "wav")!
                    do { bgMusic = try AVAudioPlayer(contentsOfURL: bgMusicURL, fileTypeHint: nil) } catch _ { return print("file not found") }
                    bgMusic.prepareToPlay()
                    bgMusic.play()
                }
                gamePaused = true
                //speed = 0
                pause.removeThis()
                pausemenu = PopupMenu(size: size, title: "Paused", label: "Continue?", id: "pause")
                pausemenu.addTo(self)
                //Here we add the upgrade buttons to the game.
                createUpgradeButtons()
            }
        }
    }
    
    func removeDialog() {
        if pausemenu != nil {
            pausemenu.removeThis()
            pause = Pause(size: size, x: size.width - 50, y: size.height - size.height / 6).addTo(self)
        }
    }
    
    //physics stuff
    
    //   func didBeginContact(contact: SKPhysicsContact){
    //       if contact as SKPhysicsContact? != nil{
    //           self.contactQueue.append(contact)
    //       }
    //   }
    
    
    func explode(point: CGPoint){
        let emitterNode = SKEmitterNode(fileNamed: "EnemyExplosion.sks")
        emitterNode!.particlePosition = point
        self.addChild(emitterNode!)
        self.runAction(SKAction.waitForDuration(2), completion: { emitterNode!.removeFromParent()})
        
    }
    
    func emitterStars(color: SKColor, starSpeedY: CGFloat, starsPerSecond: CGFloat, starScaleFactor: CGFloat) -> SKEmitterNode{
        let time = size.height * UIScreen.mainScreen().scale / starSpeedY
        let emitterNode = SKEmitterNode()
        emitterNode.particleTexture = SKTexture(imageNamed: "Star")
        emitterNode.particleBirthRate = starsPerSecond
        emitterNode.particleColor = color
        emitterNode.particleSpeed = starSpeedY * -1
        emitterNode.particleScale = starScaleFactor
        emitterNode.particleLifetime = time
        emitterNode.position = CGPoint(x: size.width/2, y: size.height)
        emitterNode.particlePositionRange = CGVector(dx: size.width, dy: 0)
        
        emitterNode.advanceSimulationTime(NSTimeInterval(time))
        
        return emitterNode
    }
    
    func didBeginContact(contact: SKPhysicsContact){
        var firstBody: SKPhysicsBody
        //var secondBody: SKPhysicsBody
        
        firstBody = contact.bodyA
        if (firstBody.node?.name == "enemy"){
            let toChange = firstBody.node as? Enemy
            explode((toChange?.position)!)
            toChange?.shot = true
            toChange?.removeFromParent()
            scoreboard.addScore(1)
            //secondBody = contact.bodyB
            //  print("collision detected")
            if Options.option.get("sound"){
                let bgMusicURL:NSURL = NSBundle.mainBundle().URLForResource("Enemy-Explosion", withExtension: "wav")!
                do { bgMusic = try AVAudioPlayer(contentsOfURL: bgMusicURL, fileTypeHint: nil) } catch _ { return print("file not found") }
                bgMusic.prepareToPlay()
                bgMusic.play()
            }
        }
        
        
    }
    
    
    
    //func to shoot the lasers
    //move lasers here so it's easier to modify (for upgrades possibly)
    func shoot(x: CGFloat, y: CGFloat){
        let laser = SKSpriteNode()
        laser.color = laserColor
        laser.size = CGSize(width: laserSize, height: laserSize)
        laser.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 30, height: 30))
        laser.physicsBody!.dynamic = true
        laser.physicsBody!.usesPreciseCollisionDetection = true
        laser.physicsBody!.collisionBitMask = 0x0;
        laser.physicsBody!.velocity = CGVectorMake(0,0);
        laser.physicsBody!.categoryBitMask = kBulletCategory
        laser.physicsBody!.contactTestBitMask = kEnemyCategory
        
        //get locations
        let location = CGPointMake(currentPosition.x, currentPosition.y)
        let projLoc = CGPointMake(rocket.position.x, rocket.position.y)
        
        laser.position = projLoc
        
        
        //calculate offset of location to projectile
        let offset = Utility.vecSub(location, b: projLoc)
        
        
        //add a laser
        self.addChild(laser)
        
        //get direction to shoot in
        let direction = Utility.vecNormalize(offset)
        
        //move endpoint of triangle far (offscreen hopefully)
        let shootAmount = Utility.vecMult(direction, b: 1000)
        
        //add shoot amount to curr pos
        let realDest = Utility.vecAdd(shootAmount, b: laser.position)
        
        //actions
        if Options.option.get("sound"){
            let bgMusicURL:NSURL = NSBundle.mainBundle().URLForResource("Laser", withExtension: "wav")!
            do { bgMusic = try AVAudioPlayer(contentsOfURL: bgMusicURL, fileTypeHint: nil) } catch _ { return print("file not found") }
            bgMusic.prepareToPlay()
            bgMusic.play()
        }
        let velocity = (1200/1.0)
        let realMoveDuration = Double(self.size.width) / velocity
        let moveAction = SKAction.moveTo(realDest, duration: realMoveDuration)
        let removeAction = SKAction.removeFromParent()
        laser.runAction(SKAction.sequence([moveAction, removeAction]))
        
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        if !gamePaused {
            if !isGameOver {
                if currentlyTouching {
                    rocket.moveTo(currentPosition.x, y: currentPosition.y)
                    //Here we determine whether we can shoot or not. Once we fire, we immediately disallow us to shoot anymore until the appropriate amount of time has been waited out.
                    if(canShoot == true)
                    {
                        canShoot = false
                        //Here is a timer. It triggers the function "canShootAgain", and takes "shootSpeed" amount of seconds to execute.
                        _ = NSTimer.scheduledTimerWithTimeInterval(reloadSpeed, target: self, selector: "canShootAgain", userInfo: nil, repeats: false)
                        rocket.shoot(rocket.position.x, y1: rocket.position.y, x2: currentPosition.x, y2: currentPosition.y)
                    }
                }
                
            }
            spawnEnemies(true)
            spawnEnemies(false)
            enumerateEnemies()
            
        }
    }
    
    
    func spawnEnemies(startAtTop: Bool) {
        if random() % 1000 < enemySpawnRate {
            let randomX = 10 + random() % Int(size.width) - 10
            let startY = startAtTop.boolValue ? size.height : 0
            let enemy = Enemy(x: CGFloat(randomX), y: startY, startAtTop: startAtTop).addTo(self)
            enemy.zPosition = 2
            
        }
    }
    
    
    
    func gameOver() {
        if Options.option.get("sound") {
            //play dead sound
        }
        isGameOver = true
        let exp = Explosion(x: rocket.position.x, y: rocket.position.y).addTo(self) as! Explosion
        exp.boom(self)
        rocket.removeFromParent()
        pause.removeThis()
        PopupMenu(size: size, title: "Too bad ;(", label: "Play", id: "gameover").addTo(self)
        
    }
    
    func resetGame() {
        let gameScene = GameScene(size: size)
        gameScene.viewController = self.viewController
        gameScene.scaleMode = scaleMode
        let reveal = SKTransition.doorsOpenVerticalWithDuration(0.5)
        view?.presentScene(gameScene, transition: reveal)
    }
    
    func enumerateEnemies() {
        self.enumerateChildNodesWithName("enemy") {
            node, stop in
            let enemy = node as! Enemy
            
            self.enemyAI(enemy)
        }
        if (removeEnemies) {
            removeEnemies = false
        }
    }
    
    func enemyAI(enemy: Enemy) {
        let y = enemy.position.y
        //check if player connected with enemy
        if !isGameOver {
            if CGRectIntersectsRect(CGRectInset(enemy.frame, 25, 25), CGRectInset(rocket.frame, 10, 10)) {
                gameOver()
            }
            //add checking if enemy was shot
            if !enemy.isDisabled() {
                if(enemy.shot){
                    removeEnemies = true
                }
                
            }
            //remove
            //}
            if removeEnemies {
                if !enemy.isDisabled() {
                    //add score for killing enemy
                    //scoreboard.addScore(1)
                }
            }
            enemy.moveTo(CGPointMake(rocket.position.x, rocket.position.y))
        } else {
            enemy.move()
        }
        if y < 0 || y > size.height {
            enemy.removeFromParent()
        }
    }
    
    //Here we add the upgrade buttons to the pause menu.
    func createUpgradeButtons () {
        //let button = UIButton();
        //let buttonTwo = UIButton();
        //Here we describe the button's title
        //button.setTitle("Add", forState: .Normal)
        //button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        //Here we give the button an image
        let image = UIImage(named: "spark.png")! as UIImage
        let laserSizeButtonImage = UIImage(named: "laserSize.png")! as UIImage
        let shipSpeedButtonImage = UIImage(named: "shipSpeed.png")! as UIImage
        let reloadSpeedButtonImage = UIImage(named: "reloadSpeed.png")! as UIImage
        let laserVelocityButtonImage = UIImage(named: "laserVelocity.png")! as UIImage
        let homeImage = UIImage(named: "home.png")! as UIImage
        button.setImage(laserSizeButtonImage, forState: .Normal)
        buttonTwo.setImage(shipSpeedButtonImage, forState: .Normal)
        buttonThree.setImage(reloadSpeedButtonImage, forState: .Normal)
        buttonFour.setImage(laserVelocityButtonImage, forState: .Normal)
        buttonFive.setImage(homeImage, forState: .Normal)
        //Here we add the position and size of the button
        button.frame = CGRectMake(0, 75, 50, 50) //x,y,width,height
        buttonTwo.frame = CGRectMake(0, 125, 50, 50)
        buttonThree.frame = CGRectMake(0, 175, 50, 50)
        buttonFour.frame = CGRectMake(0, 225, 50, 50)
        buttonFive.frame = CGRectMake(500, 125, 50, 50)
        //Here we add the button to the game
        self.view!.addSubview(button)
        self.view!.addSubview(buttonTwo)
        self.view!.addSubview(buttonThree)
        self.view!.addSubview(buttonFour)
        self.view!.addSubview(buttonFive)
        //Here we add functionality to the button
        button.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        buttonTwo.addTarget(self, action: "buttonPressedTwo:", forControlEvents: .TouchUpInside)
        buttonThree.addTarget(self, action: "buttonPressedThree:", forControlEvents: .TouchUpInside)
        buttonFour.addTarget(self, action: "buttonPressedFour:", forControlEvents: .TouchUpInside)
        buttonFive.addTarget(self, action: "buttonPressedFive:", forControlEvents: .TouchUpInside)
    }
    //Here we remove the upgrade buttons from the pause menu
    func removeUpgradeButtons()
    {
        button.removeFromSuperview()
        buttonTwo.removeFromSuperview()
        buttonThree.removeFromSuperview()
        buttonFour.removeFromSuperview()
        buttonFive.removeFromSuperview()
    }
    
    //Here this button increases the size of the laser for a cost.
    func buttonPressed(sender: UIButton!) {
        if(scoreboard.getScore() >= 1 && isGameOver == false)
        {
            scoreboard.addScore(-1)
            rocket.laserSize = rocket.laserSize + 1
            rocket.boxSize = rocket.boxSize + 1
        }
        //this is the code that came along in the tutorial
        /*
        var alertView = UIAlertView();
        alertView.addButtonWithTitle("OK");
        alertView.title = "Alert";
        alertView.message = "Button Pressed!!!";
        alertView.show();
        */
    }
    //Here this button increases the speed of the ship for a cost.
    func buttonPressedTwo(sender: UIButton!)
    {
        if(scoreboard.getScore() >= 1 && isGameOver == false)
        {
            scoreboard.addScore(-1)
            let additionVariable: CGFloat = 1
            rocket.speedTwo = rocket.speedTwo + additionVariable
        }
    }
    //Here this button should increase the velocity of the lasers for a cost.
    func buttonPressedThree(sender: UIButton!)
    {
        if(scoreboard.getScore() >= 1 && isGameOver == false)
        {
            scoreboard.addScore(-1)
            rocket.velocity = rocket.velocity + (50/1.0)
        }
    }
    //Here this button decreases the reload speed
    func buttonPressedFour(sender: UIButton!)
    {
        if(scoreboard.getScore() >= 1 && isGameOver == false)
        {
            scoreboard.addScore(-1)
            //We check for this, because we can't have negative time! So don't reduce it below 0!
            if(reloadSpeed > 0.1)
            {
                reloadSpeed = reloadSpeed - 0.1
            }
        }
    }
    //go home screen
    func buttonPressedFive(sender: UIButton!){
        removeUpgradeButtons()
        let homeScene = MainMenuScene(size: size)
        homeScene.scaleMode = scaleMode
        let reveal = SKTransition.doorsOpenVerticalWithDuration(0.5)
        homeScene.viewController = self.viewController
        view?.presentScene(homeScene, transition: reveal)    }
    
    func canShootAgain()
    {
        canShoot = true
    }
    
    
    
}
