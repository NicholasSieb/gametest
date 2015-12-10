import SpriteKit

class FadeText {
    let text: SKLabelNode
    
    /// Creates SKLabel fading text
    ///
    /// - parameter x, x starting coord
    /// - parameter y, y starting coord
    /// - parameter label, text to display
    /// - Usage Sprite constructor
    init(x: CGFloat, y: CGFloat, label: String) {
        text = SKLabelNode(text: label)
        text.position = CGPoint(x: x, y: y)
        text.fontName = "Helvetica-Bold"
        text.color = UIColor.whiteColor()
        text.fontSize = 25
        text.zPosition = 500
        text.verticalAlignmentMode = .Bottom
    }
    
    ///Add the labelnode to parent
    ///then fade text
    /// - return text node
    func addTo(parentNode: SKNode) -> FadeText {
        parentNode.addChild(text)
        //actions
        text.runAction(
            SKAction.sequence([
                SKAction.scaleBy(1.2, duration: 1.0),
                SKAction.fadeAlphaBy(-0.9, duration: 0.6),
                SKAction.removeFromParent()
            ])
        )
        return self
    }
}
