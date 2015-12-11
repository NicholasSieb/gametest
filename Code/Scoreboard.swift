import SpriteKit
import GameKit

class Scoreboard {

    var viewController: GameViewController?
    let scoreboard = SKLabelNode(text: "Credits: 0")
    var score: Int = 0
    var isHighScore = false
    /// Creates scoreboard sprite
    ///
    /// - parameter x, x starting coord
    /// - parameter y, y starting coord
    /// - Usage Sprite constructor
    init(x: CGFloat, y: CGFloat) {
        scoreboard.setScale(2.5)
        scoreboard.fontName = "Helvetica-Bold"
        scoreboard.position = CGPoint(x: x, y: y)
        scoreboard.horizontalAlignmentMode = .Left
        scoreboard.zPosition = 10
    }
    /// Reports highscore
    /// - Usage highscore()
    func highScore() {
        if score > NSUserDefaults.standardUserDefaults().integerForKey("highscore"){
            NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highscore")
            NSUserDefaults.standardUserDefaults().synchronize()
            isHighScore = true
            GCHelper.sharedInstance.reportLeaderboardIdentifier("leaderBoardID", score: score)
        }
    }
    /// adds scoreboard Sprite to GameScene
    ///
    /// - Returns Scoreboard sprite
    func addTo(parentNode: GameScene) -> Scoreboard {
        parentNode.addChild(scoreboard)
        return self
    }
    /// Adds a point to the score
    ///
    /// - parameter score, value to modify score by
    func addScore(score: Int) {
        self.score += score
        scoreboard.text = "Credits: \(self.score)"
        highScore()
    }
    /// Function to access score value
    ///
    /// - returns score as int
    func getScore() -> Int {
        return score
    }
    /// Boolean to check if highscore occured
    ///
    /// - returns boolean value
    func isHighscore() -> Bool {
        return isHighScore
    }
    /// Show highscore event as a popup
    ///
    /// - returns label
    func getHighscoreLabel(size: CGSize) -> SKLabelNode {
        let highscore = SKLabelNode(text: "High Score!")
        highscore.position = CGPointMake(size.width / 2, size.height / 2 + 50)
        highscore.fontColor = UIColor.redColor()
        highscore.fontSize = 80
        highscore.fontName = "Helvetica-Bold"
        highscore.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeInWithDuration(0.3), SKAction.fadeOutWithDuration(0.3)])))
        return highscore
    }
}