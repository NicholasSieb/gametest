import SpriteKit

class Background {
    let background = SKNode()

    var size: CGSize
    init(size: CGSize) {
        background.zPosition = -1
        self.size = size
    }

    

    
    
    
    func addTo(parentNode: SKNode) -> SKNode {
        parentNode.addChild(background)
        return background
    }
}
