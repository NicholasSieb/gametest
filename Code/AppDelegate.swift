import UIKit
import SpriteKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    ///default method of AppDelegate
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        ///install Crashlytics framework
        Fabric.with([Crashlytics()])
        ///Attempt to authenticate user
        GCHelper.sharedInstance.authenticateLocalUser()
        return true
    }
    ///Atteempt to save options
    func applicationWillResignActive(application: UIApplication) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(Options.option.getOptions(), forKey: "options")
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }
}

