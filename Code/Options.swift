class Options {
    class var option: Options {
        return _Options
    }

    var options: [String:Bool]
    ///create options list
    init(options: [String:Bool]) {
        self.options = options
    }
    ///return options
    func getOptions() -> [String:Bool] {
        return self.options
    }
    ///set options to saved values
    func setOptions(options: [String:Bool]) {
        self.options = options
    }
    ///get status of an option
    func get(option: String) -> Bool {
        return options[option]!
    }
    ///toggle an option
    func toggle(option: String) {
        if let opt = options[option] {
            options[option] = !opt
        }
    }
    ///set an option
    func set(option: String, val: Bool) {
        options[option] = val
    }
}
///create list of options
private let _Options = Options(options:
["sound": true]
)
