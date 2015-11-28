import SpriteKit

class Laser: Sprite {
    
    init(x: CGFloat, y: CGFloat) {
        super.init(named: "laserbullet", x: x, y: y)
        self.setScale(1)
    }
    
    
    func moveTo(x: CGFloat, y: CGFloat) {
        let speed: CGFloat = 36
        var dx: CGFloat, dy: CGFloat
        // Compute vector components in direction of the touch
        dx = x - self.position.x
        dy = y - self.position.y + 50
        self.zRotation = atan2(dy + 100, dx) - CGFloat(M_PI_2)
        //Do not move if tap is on sprite
        if (dx >= 1 || dx <= -1) && (dy >= 1 || dy <= 1) {
            let mag = sqrt(dx * dx + dy * dy)
            // Normalize and scale
            dx = dx / mag * speed
            dy = (dy + 50) / mag * speed
            self.position = CGPointMake(self.position.x + dx, self.position.y + dy)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
