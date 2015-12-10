import SpriteKit

class Button {
    var button: SKSpriteNode

    /// Creates stylish button
    ///
    /// - parameter x, x starting coord
    /// - parameter y, y starting coord
    /// - parameter width, width of button
    /// - parameter height, height of button
    /// - parameter label, text to put in button
    /// - id name of button
    /// - Usage Sprite constructor
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, label: String, id: String) {
        button = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(width, height))
        button.position = CGPointMake(x, y);
        button.zPosition = 10
        button.name = id
        addText(label, id: id)
    }
    
    /// Adds text to label
    ///
    /// - parameter label text to place in albel
    /// - parameter name name of label
    /// - Usage Sprite constructor
    func addText(label: String, id: String) {
        let text = SKLabelNode(text: label)
        text.fontName = "Helvetica-Bold"
        text.name = id
        text.fontSize = 100
        text.verticalAlignmentMode = .Center
        button.addChild(text)
    }

    ///add to parent
    func addTo(parentNode: SKNode) -> Button {
        parentNode.addChild(button)
        return self
    }

    func removeThis() {
        button.removeFromParent()
    }
}