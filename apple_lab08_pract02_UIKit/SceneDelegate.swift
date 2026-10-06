//
//  SceneDelegate.swift
//  apple_lab08_pract02_UIKit
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        // Los pasteles se ven mejor en modo claro.
        window?.overrideUserInterfaceStyle = .light
        configureTabBar()
    }

    /// Ajusta tabs (títulos, íconos, tercer tab de Resultados) y colores pastel.
    private func configureTabBar() {
        guard let tabBarController = window?.rootViewController as? UITabBarController,
              var controllers = tabBarController.viewControllers else { return }

        let items: [(title: String, icon: String)] = [
            ("Lista", "list.bullet"),
            ("Calculadora", "plus.forwardslash.minus")
        ]

        for (index, item) in items.enumerated() where index < controllers.count {
            controllers[index].tabBarItem = UITabBarItem(title: item.title,
                                                         image: UIImage(systemName: item.icon),
                                                         selectedImage: nil)
        }

        // Tercer tab: historial de resultados (creado por código)
        let historyNav = UINavigationController(rootViewController: HistoryController())
        historyNav.tabBarItem = UITabBarItem(title: "Resultados",
                                             image: UIImage(systemName: "clock.arrow.circlepath"),
                                             selectedImage: nil)
        controllers.append(historyNav)
        tabBarController.setViewControllers(controllers, animated: false)

        // Tab bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = Theme.card
        tabAppearance.shadowColor = Theme.separator
        for layout in [tabAppearance.stackedLayoutAppearance,
                       tabAppearance.inlineLayoutAppearance,
                       tabAppearance.compactInlineLayoutAppearance] {
            layout.selected.iconColor = Theme.accentStrong
            layout.selected.titleTextAttributes = [.foregroundColor: Theme.accentStrong]
            layout.normal.iconColor = Theme.textSecondary
            layout.normal.titleTextAttributes = [.foregroundColor: Theme.textSecondary]
        }
        tabBarController.tabBar.standardAppearance = tabAppearance
        tabBarController.tabBar.scrollEdgeAppearance = tabAppearance
        tabBarController.tabBar.tintColor = Theme.accentStrong

        // Barras de navegación
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = Theme.background
        navAppearance.shadowColor = .clear
        navAppearance.titleTextAttributes = [.foregroundColor: Theme.textPrimary]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: Theme.textPrimary]

        for case let nav as UINavigationController in controllers {
            nav.navigationBar.standardAppearance = navAppearance
            nav.navigationBar.scrollEdgeAppearance = navAppearance
            nav.navigationBar.compactAppearance = navAppearance
            nav.navigationBar.tintColor = Theme.accentStrong
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
