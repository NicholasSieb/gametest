

import SpriteKit

class FAQ{
    var FAQ: SKSpriteNode
    
    init(size: CGSize){
        let x = size.width / 2
        let y = size.height / 2
        
    
        FAQ = SKSpriteNode(color: UIColor.blackColor(), size: size)
        FAQ.position = CGPoint(x: x, y: y)
        FAQ.zPosition = 7
        FAQ.name = "FAQ"
        
        
    }
}
