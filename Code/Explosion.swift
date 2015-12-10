import SpriteKit

class Explosion: Sprite {
    required init(x: CGFloat, y: CGFloat) {
        super.init(named: "shockwave", x: x, y: y)
    }
    /// Creates explosion animation
    ///
    /// - Warning DEPRECATED, use explode() in GameScene
    func boom(main: GameScene) {
        self.runAction(
        SKAction.sequence([
                SKAction.scaleBy(7, duration: 0.5),
                SKAction.runBlock({ main.removeEnemies = true }),
                SKAction.fadeAlphaBy(-0.9, duration: 0.6),
                SKAction.removeFromParent()
        ])
        )
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
