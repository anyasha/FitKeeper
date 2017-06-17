//
//  AppDelegate.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

import UIKit
import Firebase
import PieCharts
import SwiftChart

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //Создаём окно загрузки
    var actIdc = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var conteiner: UIView!
    
    class func instance() -> AppDelegate {
        
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    //Показать окно загрузки
    func showActivityIndicator() {
        
        if let window = window {
            conteiner = UIView()
            conteiner.frame = window.frame
            conteiner.center = window.center
            conteiner.backgroundColor = UIColor(white: 0, alpha: 0.8)
            
            actIdc.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            actIdc.hidesWhenStopped = true
            actIdc.center = CGPoint(x: conteiner.frame.size.width / 2, y: conteiner.frame.size.height / 2)
            
            conteiner.addSubview(actIdc)
            window.addSubview(conteiner)
            
            actIdc.startAnimating()
        }
    }
    
    //Убрать окно загрузки
    func dismissActivityIndicators() {
        
        if let _ = window {
            conteiner.removeFromSuperview()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Подключаем Firebase
        FirebaseApp.configure()
        
        //Вызов функции перехода к главному экрану
        logUser()
        
        //Белый статус бар
        UIApplication.shared.statusBarStyle = .lightContent
        
        //Заголовок
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Avenir", size: 20)!]
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //Переход к главному экрану
    func logUser(){
        
        if Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let home = storyboard.instantiateViewController(withIdentifier: "Home")
            self.window?.rootViewController = home
        }
    }
    
    //Переход к регистрации
    func SignUp(){
        
        if Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let home = storyboard.instantiateViewController(withIdentifier: "SignUp")
            self.window?.rootViewController = home
        }
    }

    
    //Переход к  шагу 1
    func Step1User(){
        
        if Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let home = storyboard.instantiateViewController(withIdentifier: "Step1")
            self.window?.rootViewController = home
        }
    }
    
    //Переход к  шагу MarList
    func ManageMarathones(){
        
        if Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let home = storyboard.instantiateViewController(withIdentifier: "ManageMarathone")
            self.window?.rootViewController = home
        }
    }


    
}

