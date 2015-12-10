import SpriteKit

class Background {
    let background = SKNode()

    var size: CGSize
    /// Creates a background Sprite to draw on top of
    init(size: CGSize) {
        background.zPosition = -15
        self.size = size
    }

    

    
    
    ///adds sprite to parent
    func addTo(parentNode: SKNode) -> SKNode {
        parentNode.addChild(background)
        return background
    }
}
