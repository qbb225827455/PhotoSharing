//
//  AppDelegate.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/18.
//

import UIKit
import FirebaseCore
import FacebookCore
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        customUI()
        
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        var handled: Bool
        
        if url.absoluteString.contains("fb") {
            
            handled = ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
            
        } else {
            
            handled = GIDSignIn.sharedInstance.handle(url)
            
        }
        
        return handled
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate {
    
    func customUI() {
         
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir", size: 16.0)!, NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.normal)
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .black
        barAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Futura", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
        
        //UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().tintColor = UIColor.white
       
        
        let tabBarApperance = UITabBarAppearance()
        tabBarApperance.configureWithTransparentBackground()
        
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().backgroundColor = UIColor.black
        UITabBar.appearance().standardAppearance = tabBarApperance
        UITabBar.appearance().scrollEdgeAppearance = tabBarApperance
    }
}

