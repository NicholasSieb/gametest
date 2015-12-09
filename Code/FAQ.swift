

import SpriteKit

class FAQ{
    var faq: SKSpriteNode
    
    init(size: CGSize){
        let x = size.width / 2
        let y = size.height / 2
    
        faq = SKSpriteNode(color: UIColor.blackColor(), size: size)
        faq.position = CGPoint(x: x, y: y)
        faq.zPosition = 7
        faq.name = "FAQ"
        let back = Button(x:0, y: -y/3, width: x * 2 / 3, height: y / 3, label: "Back", id: "back").addTo(faq)
        back.button.zPosition = 10
        addInfo(x, y: y)
    
        
    }
    
    func addInfo(x:CGFloat, y:CGFloat){
        addText("Control the ship by holding where you want to go", size: 100, x: 150, y: 100)
        addText("Shoot the enemies and upgrade in the pause menu", size: 100, x: -550, y: 100)
    }
    
    func addText(text: String, size: CGFloat, x: CGFloat, y: CGFloat) {
        let textToWrite = SKLabelNode(text: text)
        textToWrite.fontSize = size
        textToWrite.color = UIColor.whiteColor()
        textToWrite.position = CGPointMake(x,y)
        textToWrite.fontName = "Helvetica-Bold"
        textToWrite.name = "Info"
        textToWrite.zPosition = 500
        faq.addChild(textToWrite)
    }
    
    func addTo(parentNode: SKScene) -> FAQ {
        parentNode.addChild(faq)
        return self
    }
}
