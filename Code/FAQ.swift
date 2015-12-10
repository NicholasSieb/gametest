

import SpriteKit

class FAQ{
    var faq: SKSpriteNode
    /// Creates faq Sprites
    ///
    /// - parameter size, size of scene
    /// - Usage Sprite constructor
    init(size: CGSize) {
        let x = size.width / 2
        let y = size.height / 2
        faq = SKSpriteNode(color: UIColor.blackColor(), size: size)
        faq.position = CGPoint(x: x, y: y)
        faq.zPosition = 7
        faq.name = "howto"
        let bg = Background(size: size).addTo(faq);
        bg.name = "howto"
        bg.zPosition = 6
        bg.position = CGPoint(x: -x, y: -y)
        
        let bt = Button(x: 0, y: -y / 3, width: x * 2 / 3, height: y / 3, label: "Back", id: "back").addTo(faq)
        bt.button.zPosition = 10
        addPause(x, y: y)
    }
    /// Adds text to sprite
    ///
    /// - parameter x, x coord
    /// - parameter y, y coord
    /// - Usage addPause(x,y)
    func addPause(x: CGFloat, y: CGFloat) {
        Player(x: -550, y: 300).addTo(faq)
        addText("Avoid enemies", size: 60, x: -650, y: 0)
        addText("Ship follows touches", size: 60, x: -650, y: 100)
        addText("Upgrades:", size: 60, x: x - 350, y: 100)
        addText("Info", size: 130, x: 0, y: y - 400)
        addText("Laser size, laser speed, reload time, ship speed", size:40, x:0, y: y-600)
        addText("Laser kills enemies", size: 60, x: -650, y: -100)
        addText("Score is currency", size: 60, x: -650, y: -200)
        addText("Upgrade using score", size: 60, x: x - 350, y: 0)
        addText("to get stronger", size: 60, x: x - 350, y: -100)
    }
    /// Helper function to create text label
    ///
    /// - parameter text, String to use
    /// - size, font size
    /// - parameter x, x coord
    /// - parameter y, y coord
    /// - Usage addText("String", size: , x: , y:, )
    func addText(text: String, size: CGFloat, x: CGFloat, y: CGFloat) {
        let label = SKLabelNode(text: text)
        label.fontSize = size
        label.position = CGPointMake(x, y)
        label.fontName = "Helvetica-Bold"
        label.name = "howto"
        label.zPosition = 3000
        faq.addChild(label)
    }
    /// adds Sprite to GameScene
    func addTo(parentNode: SKScene) -> FAQ {
        parentNode.addChild(faq)
        return self
    }
}