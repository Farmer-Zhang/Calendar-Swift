
//
//  AppDelegate.swift
//  Calendar
//
//  Created by 张一雄 on 2016/6/21.
//  Copyright © 2016年 HuaXiong. All rights reserved.
//

import UIKit
let TAPPKEY = "1105512254"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GDTSplashAdDelegate {

    var window: UIWindow?

    var splash: GDTSplashAd? = nil
    var bottomView: UIView? = nil
    var viewController: UINavigationController? = nil
    
    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        

        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController() as? UINavigationController
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
        
        let splashAD = GDTSplashAd.init(appkey: TAPPKEY, placementId: "2050011208959120")
        splashAD?.delegate = self
//        if UIScreen.main().bounds.size.height == 568.0 {
//            splashAD?.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "LaunchImage-568h")!)
//        } else {
//             splashAD?.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "LaunchImage")!)
        splashAD?.backgroundColor = UIColor.white
//        }
        splashAD?.fetchDelay = 1
        splashAD?.loadAndShow(in: window)
//        bottomView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main().bounds.size.height, height: 100))
//        let logo = UIImageView.init(image: UIImage.init(named: "SplashBottomLogo"))
//        bottomView?.addSubview(logo)
//        logo.center = (bottomView?.center)!
//        bottomView?.backgroundColor = UIColor.white()
//        splashAD?.loadAndShow(in: self.window, withBottomView: bottomView)
        splash = splashAD
            
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

