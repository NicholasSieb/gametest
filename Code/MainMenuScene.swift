import SpriteKit
import AVFoundation

class MainMenuScene: SKScene {
    var viewController: GameViewController?
    var bgMusic:AVAudioPlayer = AVAudioPlayer()
    /// standard SKScene function to setup view
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        var emitterNode = emitterStars(SKColor.lightGrayColor(), starSpeedY: 50, starsPerSecond: 1, starScaleFactor: 0.2)
        emitterNode.zPosition = -10
        self.addChild(emitterNode)
        emitterNode = emitterStars(SKColor.grayColor(), starSpeedY: 30, starsPerSecond: 2, starScaleFactor: 0.1)
        emitterNode.zPosition = -11
        self.addChild(emitterNode)
        emitterNode = emitterStars(SKColor.darkGrayColor(), starSpeedY: 15, starsPerSecond: 4, starScaleFactor: 0.05)
        emitterNode.zPosition = -12
        self.addChild(emitterNode)
        PopupMenu(size: size, title: "Game Test for 407", label: "Play", id: "start", connectOption: true).addTo(self)
    }
    /// Helper function to create a star emitterNode
    ///
    /// - parameter color, color to use
    /// - parameter startSpeedY, speed for stars to fall at
    /// - parameter starsPerSecond birthrate of particles
    /// - parameter starScaleFactor size of stars
    /// - return emitterNode that creates stars
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
    ///Standard touchesBegan function of SKScene
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touched = self.nodeAtPoint(touch.locationInNode(self))
            guard let name = touched.name else {
                return;
            }
            ///Switch operating on name of touched object
            switch name {
            ///Start pressed move to GameScene
            case "start":
                let gameScene = GameScene(size: size)
                if Options.option.get("sound"){
                    let soundaction = SKAction.playSoundFileNamed("Start.wav", waitForCompletion: false);
                    self.runAction(soundaction)
                }
                gameScene.scaleMode = scaleMode
                let reveal = SKTransition.doorsOpenVerticalWithDuration(0.5)
                gameScene.viewController = self.viewController
                view?.presentScene(gameScene, transition: reveal)
                
                    //let startSound = SoundPlayer(name: "Start")
                    //startSound.Play()
                    
                
            ///leaderboard touched, open Gamecenter
            case "score":
                viewController?.openGC()
            case "connect" :
                let gameScene = GameScene(size: size)
                gameScene.scaleMode = scaleMode
                gameScene.connectClicked = true
                let reveal = SKTransition.doorsOpenVerticalWithDuration(0.5)
                gameScene.viewController = self.viewController
                view?.presentScene(gameScene, transition: reveal)
                break
            default:
                Utility.pressButton(self, touched: touched, score: "-1")
            }
        }
    }
}