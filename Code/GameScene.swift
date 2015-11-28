import SpriteKit

class GameScene: SKScene {
    var viewController: GameViewController?
    let enemySpawnRate = 5
    var isGameOver = false
    var gamePaused = false
    var removeEnemies = false
    var doFireLaser = false
    var scoreboard: Scoreboard!
    var rocket: Rocket!
    var pause: Pause!
    var laserSize = 5;
    var laserColor = UIColor.greenColor();

    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        Background(size: size).addTo(self)
        let coolBackGround = SKEmitterNode(fileNamed: "Background")
        coolBackGround?.position = CGPointMake(size.width/2, size.height)
        coolBackGround!.zPosition = 0
        addChild(coolBackGround!)
        rocket = Rocket(x: size.width / 2, y: size.height / 2).addTo(self) as! Rocket
        scoreboard = Scoreboard(x: 50, y: size.height - size.height / 5).addTo(self)
        scoreboard.viewController = self.viewController
        pause = Pause(size: size, x: size.width - 50, y: size.height - size.height / 6).addTo(self)
        
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
        } else {
            if !isGameOver {
                
                gamePaused = true
                //speed = 0
                pause.removeThis()
                pausemenu = PopupMenu(size: size, title: "Paused", label: "Continue?", id: "pause")
                pausemenu.addTo(self)
            }
        }
    }

    func removeDialog() {
        if pausemenu != nil {
            pausemenu.removeThis()
            pause = Pause(size: size, x: size.width - 50, y: size.height - size.height / 6).addTo(self)
        }
    }
    
    //func to shoot the lasers
    //move lasers here so it's easier to modify (for upgrades possibly)
    func shoot(x: CGFloat, y: CGFloat){
        let laser = SKSpriteNode()
        laser.color = laserColor
        laser.size = CGSize(width: laserSize*10, height: laserSize*10)
        laser.position = CGPointMake(self.position.x, self.position.y)
        laser.physicsBody? = SKPhysicsBody(rectangleOfSize: laser.frame.size)
        laser.physicsBody?.dynamic = true
        laser.physicsBody?.affectedByGravity = false
        laser.physicsBody?.collisionBitMask = 0x0;
        laser.physicsBody?.velocity = CGVectorMake(0,0);
        laser.anchorPoint = CGPoint(x: -2, y: -2)
        self.addChild(laser)
        
        
    }

    override func update(currentTime: CFTimeInterval) {
        if !gamePaused {
            if !isGameOver {
                if currentlyTouching {
                    rocket.moveTo(currentPosition.x, y: currentPosition.y)
                    //test bullets
                    shoot(rocket.position.x, y: rocket.position.y)
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
                //alien.setDisabled()
               // removeAliens = true
            }
            if removeEnemies {
                if !enemy.isDisabled() {
                    //add score for killing enemy
                    scoreboard.addScore(1)
                }
                enemy.removeFromParent()
            }
            enemy.moveTo(CGPointMake(rocket.position.x, rocket.position.y))
        } else {
            enemy.move()
        }
        if y < 0 || y > size.height {
            enemy.removeFromParent()
        }
    }


 
}
