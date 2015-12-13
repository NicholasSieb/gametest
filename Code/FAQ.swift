

import SpriteKit

class FAQ{
    var faq: SKSpriteNode
    var faq2: SKSpriteNode
    /// Creates faq Sprites
    ///
    /// - parameter size, size of scene
    /// - Usage Sprite constructor
    init(size: CGSize) {
        let x = size.width / 2
        let y = size.height / 2
        faq = SKSpriteNode(color: UIColor.blackColor(), size: size)
        faq.position = CGPoint(x: x, y: y)
        faq.zPosition = 12
        faq.name = "howto"
        faq2 = SKSpriteNode(color: UIColor.blackColor(), size: size)
        faq2.position = CGPoint(x: 0, y: -y)
        faq2.zPosition = 12
        faq2.name = "howto"
        faq.addChild(faq2)
        let bg = Background(size: size).addTo(faq);
        bg.name = "howto"
        bg.zPosition = 13
        bg.position = CGPoint(x: -x, y: -y)
        let bt = Button(x: 0, y: -y / 3, width: x * 2 / 3, height: y / 3, label: "Back", id: "back").addTo(faq)
        bt.button.zPosition = 14
        addPause(x, y: y)
    }
    /// Adds text to sprite
    ///
    /// - parameter x, x coord
    /// - parameter y, y coord
    /// - Usage addPause(x,y)
    func addPause(x: CGFloat, y: CGFloat) {
        
        Sprite(named: "laserSize", x: x/6.5 - 8*x/17,  y: y - y / 2.5, scale: 3.0).addTo(faq)
        Sprite(named: "shipSpeed", x: x/6.5 - x/4, y: y - y / 2.5, scale: 3.0).addTo(faq)
        Sprite(named: "reloadSpeed", x: x/6.5, y: y - y / 2.5, scale: 3.0).addTo(faq)
        Sprite(named: "laserVelocity", x: x/6.5 + 4*x/17, y: y - y / 2.5, scale: 3.0).addTo(faq)
        Player(x: -550, y: 300).addTo(faq)
        addText("Avoid enemies", size: 60, x: -650, y: 0)
        addText("Ship follows touches", size: 60, x: -650, y: 100)
        addText("Upgrades:", size: 60, x: x - 350, y: 100)
        addText("Info", size: 130, x: 0, y: y - 600)
        addText("Laser size, laser speed, reload time, ship speed", size:40, x:0, y: y-420)
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
        label.fontName = "Prototype"
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