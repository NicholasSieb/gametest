import SpriteKit
import AVFoundation

class MainMenuScene: SKScene {
    var viewController: GameViewController?
    var bgMusic:AVAudioPlayer = AVAudioPlayer()

    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        PopupMenu(size: size, title: "Game Test for 407", label: "Play", id: "start").addTo(self)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touched = self.nodeAtPoint(touch.locationInNode(self))
            guard let name = touched.name else {
                return;
            }
            switch name {
            case "start":
                let gameScene = GameScene(size: size)
                gameScene.scaleMode = scaleMode
                let reveal = SKTransition.doorsOpenVerticalWithDuration(0.5)
                gameScene.viewController = self.viewController
                view?.presentScene(gameScene, transition: reveal)
                let bgMusicURL:NSURL = NSBundle.mainBundle().URLForResource("Start", withExtension: "wav")!
                do { bgMusic = try AVAudioPlayer(contentsOfURL: bgMusicURL, fileTypeHint: nil) } catch _ { return print("file not found") }
                bgMusic.prepareToPlay()
                bgMusic.play()
            default:
                Utility.pressButton(self, touched: touched, score: "-1")
            }
        }
    }
}