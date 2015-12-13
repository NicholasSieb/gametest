import SpriteKit

class PopupMenu {
    var menu: SKNode
    /// Creates popupmenu sprite
    ///
    /// - parameter size size of width and height
    /// - parameter title
    /// - parameter label
    /// - parameter id
    /// - Usage Sprite constructor
    init(size: CGSize, title: String, label: String, id: String, connectOption: Bool) {
        let width = size.width
        let height = size.height
        self.menu = SKNode()
        menu.zPosition = 5
        if(connectOption){
            Button(x: width / 2, y: height / 3, width: width / 3, height: height / 12, label: label, id: id).addTo(menu)
            Button(x: width / 2, y: 5*height / 24, width: width / 3, height: height / 12, label: "Connect", id: "connect").addTo(menu)
        }
        else {
            Button(x: width / 2, y: height / 3, width: width / 3, height: height / 6, label: label, id: id).addTo(menu)
        }
        Sprite(named: "faq", x:14*width / 15, y: 4 * height / 5, size: CGSizeMake(height / 12, height / 12)).addTo(menu)
        let options = Sprite(named: "settings", x: 51 * width / 60, y: 4 * height / 5, size: CGSizeMake(height / 12, height / 12))
        options.addTo(menu)
        Sprite(named: "score", x: width / 4, y: height / 3, size: CGSizeMake(height / 6, height / 6)).addTo(menu)
        
        //Sprite(named: "laserSize", x: size.width/2 - 2*size.width/17,  y: size.height - size.height / 5, size: CGSizeMake(size.height / 6, size.height / 6)).addTo(menu)
        addTitle(title, position: CGPointMake(width / 2, 3 * height / 5))
        
    }

    ///helper function to add Title
    func addTitle(title: String, position: CGPoint) {
        let node = SKLabelNode(text: title)
        node.fontName = "Helvetica-Bold"
        node.fontSize = 200
        node.color = UIColor.whiteColor()
        node.position = position
        menu.addChild(node)
    }
    
    ///add to parent
    func addTo(parentNode: SKScene) -> PopupMenu {
        parentNode.addChild(menu)
        return self
    }

    func removeThis() {
        menu.removeFromParent()
    }
}