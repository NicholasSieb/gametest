import SpriteKit

class GameScene: SKScene {
    var viewController: GameViewController?
    let alienSpawnRate = 5
    var isGameOver = false
    var gamePaused = false
    var removeAliens = false
    var doFireLaser = false
    var scoreboard: Scoreboard!
    var rocket: Rocket!
    var pause: Pause!

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

    override func update(currentTime: CFTimeInterval) {
        if !gamePaused {
            if !isGameOver {
                if currentlyTouching {
                    rocket.moveTo(currentPosition.x, y: currentPosition.y)
                }
              
            }
            spawnAliens(true)
            spawnAliens(false)
            enumerateAliens()
            //only here to test
            //fireLaser()
        }
    }
    
    func fireLaser() {
        //method to fire
        let xPos = rocket.position.x
        let yPos = rocket.position.y
        let laser = Laser(x: xPos+5, y: yPos+5).addTo(self)
        laser.zPosition = 2
        
        
        
    }

    func spawnAliens(startAtTop: Bool) {
        if random() % 1000 < alienSpawnRate {
            let randomX = 10 + random() % Int(size.width) - 10
            let startY = startAtTop.boolValue ? size.height : 0
            let alien = Alien(x: CGFloat(randomX), y: startY, startAtTop: startAtTop).addTo(self)
            alien.zPosition = 2
            
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

    func enumerateAliens() {
        self.enumerateChildNodesWithName("alien") {
            node, stop in
            let alien = node as! Alien
            self.alienBrains(alien)
        }
        if (removeAliens) {
            removeAliens = false
        }
    }

    func alienBrains(alien: Alien) {
        let y = alien.position.y
        //check if player connected with enemy
        if !isGameOver {
            if CGRectIntersectsRect(CGRectInset(alien.frame, 25, 25), CGRectInset(rocket.frame, 10, 10)) {
                gameOver()
            }
            //add checking if alien was shot
            if !alien.isDisabled() {
                //alien.setDisabled()
               // removeAliens = true
            }
            if removeAliens {
                if !alien.isDisabled() {
                    //add score for killing enemy
                    scoreboard.addScore(1)
                }
                alien.removeFromParent()
            }
            alien.moveTo(CGPointMake(rocket.position.x, rocket.position.y))
        } else {
            alien.move()
        }
        if y < 0 || y > size.height {
            alien.removeFromParent()
        }
    }


 
}
