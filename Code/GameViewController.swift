import UIKit
import SpriteKit
import Social
import GameKit
import StoreKit

class GameViewController: UIViewController {
    var product_id: String?

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
    }

    func viewControllerForPresentingModalView() -> UIViewController {
        return self
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }




}
