import SpriteKit

class OptionsMenu {
    /// Creates options sprite
    ///
    /// - parameter menu, options node to use
    /// - parameter size
    /// - Usage Sprite constructor
    init(menu: SKNode, size: CGSize) {
        let options = ["sound", "music"]
        var pos: CGFloat = 51
        for option in options {
            addOption(menu, size: size, option: option, pos: pos)
            pos -= 5
        }
    }
    ///Add an option to menu
    func addOption(menu: SKNode, size: CGSize, option: String, pos: CGFloat) {
        let height = size.height
        let isOn = Options.option.get(option) ? "on" : "off"
        let sprite = Sprite(named: "\(option)\(isOn)", x: size.width * pos / 60, y: 4 * height / 5, size: CGSizeMake(height / 12, height / 12))
        sprite.name = "option_\(option)"
        sprite.addTo(menu)
    }
}
