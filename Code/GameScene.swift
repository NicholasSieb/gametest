import SpriteKit
import AVFoundation
import GameKit

protocol GameSceneDelegate {
    func gameOver()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var viewController: GameViewController?

    //The player
    var rocket: Player!
    var currentPosition: CGPoint!
    var currentlyTouching = false
    
    //laser variables
    var laserSize = 5;
    var laserColor = UIColor.greenColor();
    var canShoot = true
    var reloadSpeed = 0.3
    var doFireLaser = false
    
    //enemy variables
    var removeEnemies = false
    var enemySpawnRate = 5
    
    //game state variables
    var gameCenterDelegate : GameSceneDelegate?
    var scoreboard: Scoreboard!
    var isGameOver = false

    //pause variables
    var pausemenu: PopupMenu!
    var gamePaused = false
    var pause: Pause!
    
    //contact variables
    var contactQueue = Array<SKPhysicsContact>()
    let kBulletCategory: UInt32 = 0x1 << 1
    let kEnemyCategory: UInt32 = 0x1 << 0
  
    
    //the update buttons
    let button = UIButton()
    let buttonTwo = UIButton()
    let buttonThree = UIButton()
    let buttonFour = UIButton()
    let buttonFive = UIButton()
    
    //the upgrade images
    let laserSizeButtonImage = UIImage(named: "laserSize.png")! as UIImage
    let shipSpeedButtonImage = UIImage(named: "shipSpeed.png")! as UIImage
    let reloadSpeedButtonImage = UIImage(named: "reloadSpeed.png")! as UIImage
    let laserVelocityButtonImage = UIImage(named: "laserVelocity.png")! as UIImage
    let homeImage = UIImage(named: "home.png")! as UIImage
    
    //the joysticks
    var joystickOne: Joystick!
    var joystickTwo: Joystick!
    
    //the sound player
    var bgMusic:AVAudioPlayer = AVAudioPlayer()

    //initial scene setup
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
        _ = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: "increaseSpawn", userInfo: nil, repeats: true)
        
        //create the upgrade buttons
        createUpgradeButtons(size)
        
        //Test Joystick
        joystickOne = Joystick()
        joystickTwo = Joystick()
        joystickOne.position = CGPointMake(size.width / 6.5, size.height / 4.2)
        joystickTwo.position = CGPointMake(size.width - size.width / 6.5, size.height / 4.2)
        self.addChild(joystickOne)
        self.addChild(joystickTwo)
    }

    
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
            case "score":
                viewController?.openGC()
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
                addUpgradeButtons()
            }
        }
    }
    
    func removeDialog() {
        if pausemenu != nil {
            pausemenu.removeThis()
            pause = Pause(size: size, x: size.width - 50, y: size.height - size.height / 6).addTo(self)
        }
    }
    
    //places an explosion sprite at point and cycles through the action
    func explode(point: CGPoint, player: Bool){
        var emitterNode: SKEmitterNode
        if(player){
            emitterNode = SKEmitterNode(fileNamed: "PlayerExplosion.sks")!
        }
        else {
            emitterNode = SKEmitterNode(fileNamed: "EnemyExplosion.sks")!
        }
        emitterNode.particlePosition = point
        self.addChild(emitterNode)
        self.runAction(SKAction.waitForDuration(2), completion: { emitterNode.removeFromParent()})
        
    }
    
//DEPRICATED CAN WE REMOVE?
//    func explodePlayer(point: CGPoint, player: Bool){
//        let emitterNode = SKEmitterNode(fileNamed: "PlayerExplosion.sks")
//        emitterNode!.particlePosition = point
//        self.addChild(emitterNode!)
//        self.runAction(SKAction.waitForDuration(2), completion: { emitterNode!.removeFromParent()})
//        
//    }
    
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
        var secondBody: SKPhysicsBody
        //print("collision detected")
        
        firstBody = contact.bodyA
        secondBody = contact.bodyB
        
        //check laser enemy collision
        if (firstBody.node?.name == "enemy" && secondBody.node?.name == "laser"){
            let toChange = firstBody.node as? Enemy
            explode((toChange?.position)!, player: false)
            toChange?.shot = true
            toChange?.removeFromParent()
            scoreboard.addScore(1)
            //secondBody = contact.bodyB
            
            if Options.option.get("sound"){
                let bgMusicURL:NSURL = NSBundle.mainBundle().URLForResource("Enemy-Explosion", withExtension: "wav")!
                do { bgMusic = try AVAudioPlayer(contentsOfURL: bgMusicURL, fileTypeHint: nil) } catch _ { return print("file not found") }
                bgMusic.prepareToPlay()
                bgMusic.play()
            }
        }
        
        //check laser enemy collision
        if (secondBody.node?.name == "enemy" && firstBody.node?.name == "laser"){
            let toChange = secondBody.node as? Enemy
            explode((toChange?.position)!, player: false)
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
        
        //check ship enemy collision
        if (secondBody.node?.name == "ship" && firstBody.node?.name == "enemy"){
            gameOver()
        
        
        }
        
        //check ship enemy collision
        if (firstBody.node?.name == "ship" && secondBody.node?.name == "enemy"){
            gameOver()
            
            
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
    
    /// Increases spawn rate of enemies
    ///
    /// - Usage called using timer
    func increaseSpawn(){
        //Don't increase spawn if game is paused
        if(!gamePaused){
        enemySpawnRate = enemySpawnRate + 1
        //print(enemySpawnRate)
        }
    }
    
    ///Main loop of GameScene, advance time in the game
    override func update(currentTime: CFTimeInterval) {
        if !gamePaused {
            if !isGameOver {
                
                if (self.joystickOne.velocity.x != 0 || self.joystickOne.velocity.y != 0) {
                    rocket.position = CGPointMake(rocket.position.x + 0.15 * self.joystickOne.velocity.x, rocket.position.y + 0.15 * self.joystickOne.velocity.y)
                }
                
                if (self.joystickOne.velocity.x != 0 || joystickOne.velocity.y != 0){
                    rocket.zRotation = self.joystickOne.angularVelocity
                }
                
                if (self.joystickTwo.velocity.x != 0 || self.joystickTwo.velocity.y != 0) {
                    
                    if(canShoot == true)
                    {
                        canShoot = false
                        //Here is a timer. It triggers the function "canShootAgain", and takes "shootSpeed" amount of seconds to execute.
                        _ = NSTimer.scheduledTimerWithTimeInterval(reloadSpeed, target: self, selector: "canShootAgain", userInfo: nil, repeats: false)
                        rocket.shootJoy(rocket.position.x, y1: rocket.position.y, x2: self.joystickTwo.selectorNode.position.x, y2: self.joystickTwo.selectorNode.position.y)
                    }
                    
                }
                
                //print("x position is\(self.joystickTwo.selectorNode.position.x)")
                //print("y position is\(self.joystickTwo.selectorNode.position.y)")
                //If user is touching, move the player and attempt to fire
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
            //Perform check to spawn enemies
            spawnEnemies(true)
            spawnEnemies(false)
            //enumerate enemies for handling
            enumerateEnemies()
            
        }
    }
    
    /// Decides if enemy should be spawned, then does so
    ///
    /// - parameter startAtTop, choose starting position
    func spawnEnemies(startAtTop: Bool) {
        //get number 0-1000 and check if spawnRate is higher
        if random() % 1000 < enemySpawnRate {
            //set a random spawn location
            let randomX = 10 + random() % Int(size.width) - 10
            let startY = startAtTop.boolValue ? size.height : 0
            //construct enemy
            let enemy = Enemy(x: CGFloat(randomX), y: startY, startAtTop: startAtTop).addTo(self)
            enemy.zPosition = 2
            
        }
    }
    
    
    /// Function to end game when player is killed
    func gameOver() {
        //check if sound enabled
        if Options.option.get("sound") {
            //play dead sound
        }
        isGameOver = true
        //create explosion
        explode(rocket.position, player: true)
        rocket.removeFromParent()
        pause.removeThis()
        enemySpawnRate = 5
        PopupMenu(size: size, title: "Too bad ;(", label: "Play", id: "gameover").addTo(self)
        if scoreboard.isHighscore() {
            addChild(scoreboard.getHighscoreLabel(size))
        }
        
    }
    
    /// Reset game to play again
    func resetGame() {
        let gameScene = GameScene(size: size)
        gameScene.viewController = self.viewController
        gameScene.scaleMode = scaleMode
        let reveal = SKTransition.doorsOpenVerticalWithDuration(0.5)
        view?.presentScene(gameScene, transition: reveal)
    }
    
    ///Put enemies into list to be able to apply actions to them
    func enumerateEnemies() {
        self.enumerateChildNodesWithName("enemy") {
            node, stop in
            let enemy = node as! Enemy
            //run AI function
            //self.enemyAI(enemy)
            enemy.enemyAI(self, isGameOver: self.isGameOver, x: self.rocket.position.x, y: self.rocket.position.y)
        }
        if (removeEnemies) {
            removeEnemies = false
        }
    }
    
    /// Functions to update actions of enemy
    ///
    /// - parameter enemy, enemy to update
    /// - usage called during enumeration
    /// - important Now called from Enemy class
    func enemyAI(enemy: Enemy) {
        let y = enemy.position.y
        //check if player connected with enemy
        if !isGameOver {
            //update enemy movement
            enemy.moveTo(CGPointMake(rocket.position.x, rocket.position.y))
            
        } else {
            //game is over still move enemy tho
            enemy.move()
        }
        //check enemy bounds
        if y < 0 || y > size.height {
            enemy.removeFromParent()
        }
    }
    
    ///Here we create the upgrade buttons, called once.
    func createUpgradeButtons(size: CGSize) {
        button.setImage(laserSizeButtonImage, forState: .Normal)
        buttonTwo.setImage(shipSpeedButtonImage, forState: .Normal)
        buttonThree.setImage(reloadSpeedButtonImage, forState: .Normal)
        buttonFour.setImage(laserVelocityButtonImage, forState: .Normal)
        buttonFive.setImage(homeImage, forState: .Normal)
        //Here we add the position and size of the button
        let wid = UIScreen.mainScreen().bounds.width
        let heig = UIScreen.mainScreen().bounds.height
        let sz = CGFloat(30)
        //let heigh = self.frame.height
        button.frame = CGRectMake(wid/2 - 3.5*sz, 40 - sz, sz, sz) //x,y,width,height
        buttonTwo.frame = CGRectMake(wid/2 - 1.5*sz, 40 - sz, sz, sz)
        buttonThree.frame = CGRectMake(wid/2 + 0.5*sz, 40 - sz, sz, sz)
        buttonFour.frame = CGRectMake(wid/2 + 2.5*sz, 40 - sz, sz, sz)
        buttonFive.frame = CGRectMake(7*wid/10, 7*heig/11, 64, 64)
        //Here we add functionality to the buttons
        button.addTarget(self, action: "laserSizePressed:", forControlEvents: .TouchUpInside)
        buttonTwo.addTarget(self, action: "shipSpeedPressed:", forControlEvents: .TouchUpInside)
        buttonThree.addTarget(self, action: "laserVelPressed:", forControlEvents: .TouchUpInside)
        buttonFour.addTarget(self, action: "reloadSpeedPressed:", forControlEvents: .TouchUpInside)
        buttonFive.addTarget(self, action: "homePressed:", forControlEvents: .TouchUpInside)
    }
    
    //add the buttons to the game
    func addUpgradeButtons() {
        self.view!.addSubview(button)
        self.view!.addSubview(buttonTwo)
        self.view!.addSubview(buttonThree)
        self.view!.addSubview(buttonFour)
        self.view!.addSubview(buttonFive)
    }
    ///Here we remove the upgrade buttons from the pause menu
    func removeUpgradeButtons(){
        button.removeFromSuperview()
        buttonTwo.removeFromSuperview()
        buttonThree.removeFromSuperview()
        buttonFour.removeFromSuperview()
        buttonFive.removeFromSuperview()
    }
    
    ///Here this button increases the size of the laser for a cost.
    func laserSizePressed(sender: UIButton!) {
        //check if there is score to spend
        if(scoreboard.getScore() >= 1 && isGameOver == false && rocket.laserSize < 15)
        {
            scoreboard.addScore(-1)
            rocket.laserSize = rocket.laserSize + 1
            rocket.boxSize = rocket.boxSize + 1
        }
    }
    ///Here this button increases the speed of the ship for a cost.
    func shipSpeedPressed(sender: UIButton!){
        //check if there is score to spend and speed is not at it's limit
        if(scoreboard.getScore() >= 1 && isGameOver == false && rocket.speedTwo < 20)
        {
            scoreboard.addScore(-1)
            let additionVariable: CGFloat = 1
            rocket.speedTwo = rocket.speedTwo + additionVariable
        }
    }
    ///Here this button should increase the velocity of the lasers for a cost.
    func laserVelPressed(sender: UIButton!){
        //check if score to spend
        if(scoreboard.getScore() >= 1 && isGameOver == false && rocket.velocity < 200)
        {
            scoreboard.addScore(-1)
            rocket.velocity = rocket.velocity + (20/1.0)
        }
    }
    ///Here this button decreases the reload speed
    func reloadSpeedPressed(sender: UIButton!){
        //checks if there are points to spend, if the game is still going, and if we are above the limit
        if(scoreboard.getScore() >= 1 && isGameOver == false && reloadSpeed > 0.2){
            scoreboard.addScore(-1)
            reloadSpeed = reloadSpeed - 0.1
        }
    }
    
    ///go to home screen
    func homePressed(sender: UIButton!){
        //create homeScene and remove unneeded things
        removeUpgradeButtons()
        let homeScene = MainMenuScene(size: size)
        homeScene.scaleMode = scaleMode
        let reveal = SKTransition.doorsOpenVerticalWithDuration(0.5)
        homeScene.viewController = self.viewController
        view?.presentScene(homeScene, transition: reveal)    }
    
    ///helper function for shooting delays
    func canShootAgain(){
        canShoot = true
    }
    
    
    
}
