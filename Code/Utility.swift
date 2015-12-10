import SpriteKit

struct Utility {


    
    static func vecAdd(a: CGPoint, b: CGPoint) -> CGPoint {
        return CGPointMake(a.x + b.x, a.y + b.y)
    }
    
    static func vecSub(a: CGPoint, b: CGPoint) -> CGPoint{
        return CGPointMake(a.x - b.x, a.y - b.y)
    }
    
    static func vecMult(a: CGPoint, b: CGFloat) -> CGPoint{
        return CGPointMake(a.x*b, a.y*b)
    }
    
    static func vecLength(a: CGPoint) -> CGFloat{
        return CGFloat(sqrt(a.x * a.x + a.y * a.y))
    }
    
    
    static func vecNormalize(a: CGPoint) -> CGPoint{
        var length: CGFloat
        length = vecLength(a)
        return CGPointMake(a.x / length, a.y / length)
    }
    

    
    static func pressButton(main: SKScene, touched: SKNode, score: String) {
        let size = main.size
        if let name = touched.name {
            if name.characters.startsWith("option".characters) {
                toggle(name, sprite: touched as! SKSpriteNode, main: main)
            }
            switch name {
            case "back":
                let parent = touched.parent
                if parent?.name == "back" {
                    let superp = parent?.parent
                    superp?.removeFromParent()
                } else {
                    touched.removeFromParent()
                    parent?.removeFromParent()
                }
            case "faq":
                 FAQ(size: size).addTo(main)
            case "back":
                let parent = touched.parent
                if parent?.name == "back"{
                    let superp = parent?.parent
                    superp?.removeFromParent()
                } else {
                    touched.removeFromParent()
                    parent?.removeFromParent()
                }
            case "settings":
                let parent = touched.parent! as SKNode
                touched.removeFromParent()
                OptionsMenu(menu: parent, size: size)
            default:
                break
            }
        }
    }

    static func toggle(option: String, sprite: SKSpriteNode, main: SKScene) {
        let opt = option.stringByReplacingOccurrencesOfString("option_", withString: "")
        
        var next = "on"
        if Options.option.get(opt) {
            next = "off"
        }
        let text = FadeText(x: 0, y: -70, label: "\(opt) \(next)")
        text.addTo(sprite)

        sprite.texture = SKTexture(imageNamed: "\(opt)\(next)")
        Options.option.toggle(opt)
    }
}