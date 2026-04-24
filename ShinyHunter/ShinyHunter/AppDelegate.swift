import UIKit
import Observation

@Observable
final class AppDelegate: NSObject, UIApplicationDelegate {
    var pendingShowAddHunt = false

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if let shortcut = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem,
           shortcut.type == "com.nayzex.ShinyHunter.newHunt" {
            pendingShowAddHunt = true
        }
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        setupShortcuts()
    }

    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        if shortcutItem.type == "com.nayzex.ShinyHunter.newHunt" {
            pendingShowAddHunt = true
        }
        completionHandler(true)
    }

    private func setupShortcuts() {
        var shortcuts = [makeNewHuntShortcut()]
        if let huntShortcut = makeActiveHuntShortcut() {
            shortcuts.insert(huntShortcut, at: 0)
        }
        UIApplication.shared.shortcutItems = shortcuts
    }

    private func makeNewHuntShortcut() -> UIApplicationShortcutItem {
        UIApplicationShortcutItem(
            type: "com.nayzex.ShinyHunter.newHunt",
            localizedTitle: "Nouvelle chasse",
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(systemImageName: "plus"),
            userInfo: nil
        )
    }

    private func makeActiveHuntShortcut() -> UIApplicationShortcutItem? {
        guard
            let defaults = UserDefaults(suiteName: "group.com.nayzex.shinyhunter"),
            let data = defaults.data(forKey: "widgetHuntData"),
            let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let name = payload["pokemonName"] as? String,
            let huntID = payload["huntID"] as? String
        else { return nil }
        return UIApplicationShortcutItem(
            type: "com.nayzex.ShinyHunter.openHunt",
            localizedTitle: name,
            localizedSubtitle: "Continuer la chasse",
            icon: UIApplicationShortcutIcon(systemImageName: "target"),
            userInfo: ["huntID": huntID as NSSecureCoding]
        )
    }
}
