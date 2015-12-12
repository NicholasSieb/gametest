import SpriteKit

class UpgradeButton: SKSpriteNode {
    /// Creates uprade sprite
    ///
    /// - parameter x, x starting coord
    /// - parameter y, y starting coord
    /// - parameter startAtTop, choose starting position
    /// - Usage Sprite constructor
    init(named: String, x: CGFloat, y: CGFloat) {
        let texture = SKTexture(imageNamed: named)
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        self.position = CGPoint(x: x, y: y)
        self.name = named
    }
    
    /// Adds Sprite to parent
    func addTo(parentNode: SKNode) -> UpgradeButton{
        parentNode.addChild(self)
        return self
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}