import SpriteKit

class Sprite: SKSpriteNode {
    /// Creates generic Sprite
    ///
    /// - parameter named, texture to use
    /// - parameter x, x starting coord
    /// - parameter y, y starting coord
    /// - Usage Sprite constructor
    init(named: String, x: CGFloat, y: CGFloat) {
        let texture = SKTexture(imageNamed: named)
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        self.position = CGPoint(x: x, y: y)
        self.setScale(2)
        self.name = named
    }
    
    ///additional constructor
    convenience init(named: String, x: CGFloat, y: CGFloat, scale: CGFloat) {
        self.init(named: named, x: x, y: y)
        self.setScale(scale)
    }
    
    ///addtional constructor
    convenience init(named: String, x: CGFloat, y: CGFloat, size: CGSize) {
        self.init(named: named, x: x, y: y)
        self.size = size
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /// Adds Sprite to parent
    func addTo(parentNode: SKNode) -> Sprite {
        parentNode.addChild(self)
        return self
    }
}