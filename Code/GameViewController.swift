import UIKit
import SpriteKit
import Social
import GameKit
import StoreKit

class GameViewController: UIViewController {
    var product_id: String?
    ///Default viewdDidLoad method
    ///Debugging options such as fps, node, physics toggled
    ///set Scene properties and then present it
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = NSUserDefaults.standardUserDefaults()
        if let options: [String:Bool] = defaults.dictionaryForKey("options") as? [String:Bool] {
            Options.option.setOptions(options)
        }
        let scene = MainMenuScene(size: CGSize(width: 2048, height: 1536))
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        scene.viewController = self
        skView.presentScene(scene)
        skView.multipleTouchEnabled = true
    }
    
    func viewControllerForPresentingModalView() -> UIViewController {
        return self
    }
    ///sets rotation property
    override func shouldAutorotate() -> Bool {
        return true
    }
    ///Sets status bar to hidden (fullscreen)
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    ///Opens gamecenter to view scores
    func openGC() {
        GCHelper.sharedInstance.showGameCenter(self, viewState: .Default)
    }



}
