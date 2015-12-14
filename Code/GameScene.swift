import SpriteKit
import AVFoundation
import GameKit

protocol GameSceneDelegate {
    func gameOver()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var viewController: GameViewController?
    
    let service = ServiceManager()
    var connectClicked = false
    var partnerState = 0

    //The player
    var rocket: Player!
    var currentPosition: CGPoint!
    var currentlyTouching = false
    
    //laser variables
    var laserSize = 5;
    var laserColor = UIColor.greenColor();
    var canShoot = true
    var reloadSpeed = 0.8
    var doFireLaser = false
    
    //enemy variables
    var removeEnemies = false
    var enemySpawnRate = 3
    var enemyVelocity: CGFloat = 4
    
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
    
    //the joysticks
    var joystickOne: Joystick!
    var joystickTwo: Joystick!
    
    //the sound player
    var bgMusic:AVAudioPlayer = AVAudioPlayer()
    
    //buttons
    
    var homeButton: Sprite!
    var laserSizeButton: Sprite!
    var shipSpeedButton: Sprite!
    var reloadSpeedButton: Sprite!
    var laserVelocityButton: Sprite!
    
    //initial scene setup
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        Background(size: size).addTo(self)
        var emitterNode = emitterStars(SKColor.lightGrayColor(), starSpeedY: 50, starsPerSecond: 1, starScaleFactor: 0.2)
        emitterNode.zPosition = -10
        self.addChild(emitterNode)
        emitterNode = emitterStars(SKColor.grayColor(), starSpeedY: 30, starsPerSecond: 2, starScaleFactor: 0.1)
        emitterNode.zPosition = -11
        self.addChild(emitterNode)
        emitterNode = emitterStars(SKColor.darkGrayColor(), starSpeedY: 15, starsPerSecond: 4, starScaleFactor: 0.05)
        emitterNode.zPosition = -12
        self.addChild(emitterNode)
        if (Options.option.get("music")){
            backgroundMusic("background")
            bgMusic.play()
        
        }
        if(connectClicked){
            service.delegate = self
            service.connectState = 1
        }
        else {
            buildGame(view)
        }
    }
    
    func buildGame(view: SKView) {
        rocket = Player(x: size.width / 2, y: size.height / 2).addTo(self) as! Player
        scoreboard = Scoreboard(x: 50, y: size.height - size.height / 5).addTo(self)
        scoreboard.viewController = self.viewController
        pause = Pause(size: size, x: size.width - 50, y: size.height - size.height / 6).addTo(self)
        self.physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        view.showsPhysics = false
        _ = NSTimer.scheduledTimerWithTimeInterval(35, target: self, selector: "increaseSpawn", userInfo: nil, repeats: true)
        
        //create the upgrade buttons
        createUpgradeButtons(size)
        
        //Test Joystick
        joystickOne = Joystick()
        joystickTwo = Joystick()
        joystickOne.position = CGPointMake(size.width / 6.5, size.height / 3.8)
        joystickTwo.position = CGPointMake(size.width - size.width / 6.5, size.height / 3.8)
        self.addChild(joystickOne)
        self.addChild(joystickTwo)
        
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches{
        currentPosition = touch.locationInNode(self)
            
        
        let touched = self.nodeAtPoint(currentPosition)
        if let name = touched.name {
            switch name {
            case "gameover":
                resetGame()
            case "pause":
                pauseGame()
            case "home":
                //create homeScene and remove unneeded things
                removeUpgradeButtons()
                let homeScene = MainMenuScene(size: size)
                homeScene.scaleMode = scaleMode
                let reveal = SKTransition.doorsOpenVerticalWithDuration(0.5)
                homeScene.viewController = self.viewController
                view?.presentScene(homeScene, transition: reveal)
            case "score":
                viewController?.openGC()
                
            case "option_music":
                if Options.option.get("music"){
                    bgMusic.stop()
                } else {
                    backgroundMusic("background")
                    bgMusic.play()
                }
            case "connect":
                connectClicked = true
                service.connectState = 1
                
                ///increases the size of the laser
            case "laserSize":
                //check if there is score to spend. Maximum 15 upgrades to laser size
                if(scoreboard.getScore() >= 1 && isGameOver == false && rocket.laserSize < 15)
                {
                    scoreboard.addScore(-1)
                    rocket.laserSize = rocket.laserSize + 1
                    rocket.boxSize = rocket.boxSize + 1
                }
                
                //increases the speed of the ship
            case "shipSpeed":
                //check if there is score to spend and speed is not at it's limit
                if(scoreboard.getScore() >= 1 && isGameOver == false && rocket.joystickSpeed < 0.20)
                {
                    scoreboard.addScore(-1)
                    let additionVariable: CGFloat = 0.01
                    rocket.speedTwo = rocket.speedTwo + additionVariable
                }
                
                //decreases the reload speed
            case "reloadSpeed":
                //checks if there are points to spend, if the game is still going, and if we are above the limit
                if(scoreboard.getScore() >= 10 && isGameOver == false && reloadSpeed > 0.4){
                    scoreboard.addScore(-10)
                    reloadSpeed = reloadSpeed - 0.1
                }
                
                //increases the velocity of the lasers
            case "laserVelocity":
                //check if score to spend. Maximum laser velocity is 400
                if(scoreboard.getScore() >= 1 && isGameOver == false && rocket.velocity < 200)
                {
                    scoreboard.addScore(-1)
                    rocket.velocity = rocket.velocity + (10/1.0)
                }
                
            default:
                currentlyTouching = true
                
            }
            Utility.pressButton(self, touched: touched, score: String(scoreboard.getScore()))
        } else {
            currentlyTouching = true
        }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
        currentPosition = touch.locationInNode(self)
        }
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
            self.joystickOne.hidden = false
            self.joystickTwo.hidden = false
            
        } else {
            if !isGameOver {
                
                if Options.option.get("sound"){
                    let soundaction = SKAction.playSoundFileNamed("Pause.wav", waitForCompletion: false);
                   self.runAction(soundaction)
                    //let pauseSound = SoundPlayer(name: "Pause")
                    //pauseSound.Play()
                }
                gamePaused = true
                //speed = 0
                pause.removeThis()
                pausemenu = PopupMenu(size: size, title: "Paused", label: "Continue?", id: "pause", connectOption:  false)
                pausemenu.addTo(self)
                //Here we add the upgrade buttons to the game.
                addUpgradeButtons(pausemenu.menu)
                self.joystickOne.hidden = true
                self.joystickTwo.hidden = true
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
    
    func explodeLaser(point: CGPoint){
        var emitterNode: SKEmitterNode
        emitterNode = SKEmitterNode(fileNamed: "LaserExplosion.sks")!
        emitterNode.particlePosition = point
        emitterNode.particleScale = 0.25
        self.addChild(emitterNode)
        self.runAction(SKAction.waitForDuration(0.35), completion: { emitterNode.removeFromParent()})
        
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
        var secondBody: SKPhysicsBody
        //print("collision detected")
        
        firstBody = contact.bodyA
        secondBody = contact.bodyB
        
        //check laser enemy collision
        if (firstBody.node?.name == "enemy" && secondBody.node?.name == "laser"){
            let toChange = firstBody.node as? Enemy
            let laser = secondBody.node
            explodeLaser(laser!.position)
            laser?.removeFromParent()
            explode((toChange?.position)!, player: false)
            toChange?.removeFromParent()
            scoreboard.addScore(1)
            //secondBody = contact.bodyB
            
            if Options.option.get("sound"){
                let soundaction = SKAction.playSoundFileNamed("Enemy-Explosion.wav", waitForCompletion: false);
                self.runAction(soundaction)
            }
        }
        
        //check laser enemy collision
        if (secondBody.node?.name == "enemy" && firstBody.node?.name == "laser"){
            let toChange = secondBody.node as? Enemy
            let laser = firstBody.node
            explodeLaser(laser!.position)
            laser?.removeFromParent()
            explode((toChange?.position)!, player: false)
            toChange?.removeFromParent()
            scoreboard.addScore(1)
            //secondBody = contact.bodyB
            //  print("collision detected")
            if Options.option.get("sound"){
                let soundaction = SKAction.playSoundFileNamed("Enemy-Explosion.wav", waitForCompletion: false);
                self.runAction(soundaction)
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
        
        //check ship enemy collision
        if (secondBody.node?.name == "ship" && firstBody.node?.name == "boss"){
            gameOver()
            
            
        }
        
        //check ship enemy collision
        if (firstBody.node?.name == "ship" && secondBody.node?.name == "boss"){
            gameOver()
            
            
        }
        
        //check laser boss collision
        if (secondBody.node?.name == "boss" && firstBody.node?.name == "laser"){
            let toChange = secondBody.node as? Boss
            let laser = firstBody.node
            explodeLaser(laser!.position)
            laser?.removeFromParent()
            if (toChange?.health >= 0){
                toChange?.health = (toChange?.health)! - 1
                if Options.option.get("sound") {
                    let soundaction = SKAction.playSoundFileNamed("hitmarker.mp3", waitForCompletion: false);
                    self.runAction(soundaction)
                }
            }
            else {
            explode((toChange?.position)!, player: false)
            toChange?.removeFromParent()
            scoreboard.addScore(3)
            //secondBody = contact.bodyB
            //  print("collision detected")
                if Options.option.get("sound"){
                    let soundaction = SKAction.playSoundFileNamed("Enemy-Explosion.wav", waitForCompletion: false);
                    self.runAction(soundaction)
                }
            }
        }
        
        //check laser boss collision
        if (firstBody.node?.name == "boss" && secondBody.node?.name == "laser"){
            let toChange = firstBody.node as? Boss
            let laser = secondBody.node
            explodeLaser(laser!.position)
            laser?.removeFromParent()
            if (toChange?.health >= 0){
                toChange?.health = (toChange?.health)! - 1
                if Options.option.get("sound") {
                    let soundaction = SKAction.playSoundFileNamed("hitmarker.mp3", waitForCompletion: false);
                    self.runAction(soundaction)
                }
            }
            else {
            explode((toChange?.position)!, player: false)
            toChange?.removeFromParent()
            scoreboard.addScore(5)
            //secondBody = contact.bodyB
            //  print("collision detected")
                if Options.option.get("sound"){
                    let soundaction = SKAction.playSoundFileNamed("Enemy-Explosion.wav", waitForCompletion: false);
                    self.runAction(soundaction)
                }
            }
        }


        
        
    }
    
    func backgroundMusic(name: String){
        let sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(name, ofType: "mp3")!)
        do{
            bgMusic = try AVAudioPlayer(contentsOfURL: sound)
        } catch _ as NSError {
            print("Sound fail")
        }
        bgMusic.numberOfLoops = 1
        bgMusic.volume = 0.5
        bgMusic.prepareToPlay()
    }
    
    /// Increases spawn rate of enemies
    ///
    /// - Usage called using timer
    func increaseSpawn(){
        //Don't increase spawn if game is paused
        if(!gamePaused){
        enemySpawnRate = enemySpawnRate + 1
        enemyVelocity = enemyVelocity + 0.1
        //print(enemySpawnRate)
        }
    }
    
    ///Main loop of GameScene, advance time in the game
    override func update(currentTime: CFTimeInterval) {
        if (self.connectClicked){
            //attempting to connect loop
            
            //successful connection
            if(self.partnerState == 1){
                buildGame(self.view!)
                self.partnerState = 2
            }
            //post connection, mid game
            else if(self.partnerState == 2){
                doUpdate()
            }
            //post game, in reset screen
            else if(self.partnerState == 3){
                resetGame()
                self.partnerState = 2
            }
        }
        else {
            doUpdate()
        }
    
    }
    
    func doUpdate(){
        if !gamePaused {
            if !isGameOver {
                if (self.joystickOne.velocity.x != 0 || self.joystickOne.velocity.y != 0) {
                    //if (rocket.position.x <= 0 || rocket.position.y < 0 || rocket.position.x >= self.size.width || rocket.position.y >= self.size.height){
                    //} else {
                    if (rocket.position.x + rocket.joystickSpeed * self.joystickOne.velocity.x < 0 || rocket.position.x + rocket.joystickSpeed * self.joystickOne.velocity.x > self.size.width){
                        
                    }
                    else if (rocket.position.y + rocket.joystickSpeed * self.joystickOne.velocity.y < 180 || rocket.position.y + rocket.joystickSpeed * self.joystickOne.velocity.y > self.size.height - 180){
                        
                    } else {
                    rocket.position = CGPointMake(rocket.position.x + rocket.joystickSpeed * self.joystickOne.velocity.x, rocket.position.y + rocket.joystickSpeed * self.joystickOne.velocity.y)
                    }
                
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
                        if Options.option.get("sound"){
                            let soundaction = SKAction.playSoundFileNamed("Laser.wav", waitForCompletion: false);
                            self.runAction(soundaction)
                        }
                    }
                    
                }
                
                //print("x position is\(self.joystickTwo.selectorNode.position.x)")
                //print("y position is\(self.joystickTwo.selectorNode.position.y)")
                //If user is touching, move the player and attempt to fire
                if currentlyTouching {
                    /* rocket.moveTo(currentPosition.x, y: currentPosition.y)
                    //Here we determine whether we can shoot or not. Once we fire, we immediately disallow us to shoot anymore until the appropriate amount of time has been waited out.
                    if(canShoot == true)
                    {
                        canShoot = false
                        //Here is a timer. It triggers the function "canShootAgain", and takes "shootSpeed" amount of seconds to execute.
                        _ = NSTimer.scheduledTimerWithTimeInterval(reloadSpeed, target: self, selector: "canShootAgain", userInfo: nil, repeats: false)
                        rocket.shoot(rocket.position.x, y1: rocket.position.y, x2: currentPosition.x, y2: currentPosition.y)
                    }
*/
                }
                
            }
            //Perform check to spawn enemies
            spawnEnemies(true)
            spawnEnemies(false)
            //enumerate enemies for handling
            enumerateEnemies()
            enumerateBosses()
            
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
            let enemy = Enemy(x: CGFloat(randomX), y: startY, startAtTop: startAtTop, vel: enemyVelocity).addTo(self)
            enemy.zPosition = 2
        }
        if random() % 1000 < enemySpawnRate/5 {
            //set a random spawn location
            let randomX = 10 + random() % Int(size.width) - 10
            let startY = startAtTop.boolValue ? size.height : 0
            //construct enemy
            let boss = Boss(x: CGFloat(randomX), y: startY, startAtTop: startAtTop).addTo(self)
            boss.zPosition = 2
        }
    }
    
    
    /// Function to end game when player is killed
    func gameOver() {
        //check if sound enabled
        if Options.option.get("sound") {
            //play dead sound
            let soundaction = SKAction.playSoundFileNamed("Player-Death.wav", waitForCompletion: false);
            self.runAction(soundaction)
        }
        bgMusic.stop()
        isGameOver = true
        //create explosion
        explode(rocket.position, player: true)
        rocket.removeFromParent()
        pause.removeThis()
        enemySpawnRate = 5
        PopupMenu(size: size, title: "Game Over!", label: "Play", id: "gameover", connectOption: true).addTo(self)
        if scoreboard.isHighscore() {
            addChild(scoreboard.getHighscoreLabel(size))
        }
        self.connectClicked = false
        self.partnerState = 3
        self.service.session.disconnect()
        self.service.connectState = 0
        
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
    
    ///Put enemies into list to be able to apply actions to them
    func enumerateBosses() {
        self.enumerateChildNodesWithName("boss") {
            node, stop in
            let boss = node as! Boss
            //run AI function
            //self.enemyAI(enemy)
            boss.enemyAI(self, isGameOver: self.isGameOver, x: self.rocket.position.x, y: self.rocket.position.y)
        }
        if (removeEnemies) {
            removeEnemies = false
        }
    }
    
    
    ///Here we create the upgrade buttons, called once.
    func createUpgradeButtons(size: CGSize) {
        //scoreboard = Scoreboard(x: 50, y: size.height - size.height / 5).addTo(self)
        homeButton = Sprite(named: "home", x: size.width - size.width / 4.0, y: size.height / 3)
        homeButton.xScale = 0.4
        homeButton.yScale = 0.4
        homeButton.name = "home"
        laserSizeButton = Sprite(named: "laserSize", x: size.width/2 - 2*size.width/17,  y: size.height - size.height / 5)
        laserSizeButton.xScale = 3.0
        laserSizeButton.yScale = 3.0
        shipSpeedButton = Sprite(named: "shipSpeed", x: size.width/2 - size.width/25, y: size.height - size.height / 5)
        shipSpeedButton.xScale = 3.0
        shipSpeedButton.yScale = 3.0
        reloadSpeedButton = Sprite(named: "reloadSpeed", x: size.width/2 + size.width/25, y: size.height - size.height / 5)
        reloadSpeedButton.xScale = 3.0
        reloadSpeedButton.yScale = 3.0
        laserVelocityButton = Sprite(named: "laserVelocity", x: size.width/2 + 2*size.width/17, y: size.height - size.height / 5)
        laserVelocityButton.xScale = 3.0
        laserVelocityButton.yScale = 3.0
        
    }
    
    //add the buttons to the game
    func addUpgradeButtons(node: SKNode) {
        homeButton.addTo(node)
        laserSizeButton.addTo(node)
        shipSpeedButton.addTo(node)
        reloadSpeedButton.addTo(node)
        laserVelocityButton.addTo(node)

    }
    ///Here we remove the upgrade buttons from the pause menu
    func removeUpgradeButtons(){
        homeButton.removeFromParent()
        laserSizeButton.removeFromParent()
        shipSpeedButton.removeFromParent()
        reloadSpeedButton.removeFromParent()
        laserVelocityButton.removeFromParent()
    }
    
    
    ///helper function for shooting delays
    func canShootAgain(){
        canShoot = true
    }
    
    func sendUpdate() {
        
    }
    
    func connect(y: Int){
        if(self.partnerState == 0){
            self.partnerState = y
        }
    }
    
}

extension GameScene : ServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: ServiceManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
        }
    }
    
    func Changed(manager: ServiceManager, string: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.sendUpdate()
        }
    }
    
    func connected(manager: ServiceManager, con: Int){
        NSLog(String(con))
        self.connect(con)
    }
    
}







