//
//  AppDelegate.swift
//  Little Family Tree
//
//  Created by Melissa on 9/12/15.
//  Copyright (c) 2015 Melissa. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        FIRAuth.auth()?.signIn(withEmail: "service@yellowforktech.com", password: "I <3 Little Family Tree") { (user, error) in
            // nohting to do
            print(user)
            print(error)
        }
        return true
    }
    
    func application(_ application:UIApplication, completionHandler: (UIBackgroundFetchResult) -> Void) {
        let dbhelper = DBHelper.getInstance()
        let lastRun = dbhelper.getProperty("last_birthday_check")
        if lastRun != nil {
            let time = Double(lastRun!)
            let date = Foundation.Date(timeIntervalSince1970: time!)
            if date.timeIntervalSinceNow > -60 * 60 * 24 {
                completionHandler(UIBackgroundFetchResult.noData)
                return
            }
        }
        let people = dbhelper.getNextBirthdays(15, maxLevel: 4)
        var hasData = false
        if people.count > 0 {
            let ageComponentsNow = (Calendar.current as NSCalendar).components([.month, .day],
                                                                           from: Foundation.Date())
            let monthN = ageComponentsNow.month
            let dayN = ageComponentsNow.day
            for person in people {
                let ageComponents = (Calendar.current as NSCalendar).components([.month, .day],
                                                                            from: person.birthDate!)
                let month = ageComponents.month
                let day = ageComponents.day
                
                if day == dayN && month == monthN {
                    hasData = true
                    setupNotificationReminder(person)
                }
            }
        }
        let now = Foundation.Date()
        dbhelper.saveProperty("last_birthday_check", value: now.timeIntervalSince1970.description)
        if hasData {
            completionHandler(UIBackgroundFetchResult.newData)
        } else {
            completionHandler(UIBackgroundFetchResult.noData)
        }
    }
    
    func setupNotificationReminder(_ person:LittlePerson) {
        let title:String = "Today is \(person.name!)'s birthday! Decorate a birthday card for them in Little Family Tree."
        
        var calendar = Calendar.current
        var calendarComponents = DateComponents()
        calendarComponents.hour = 12
        calendarComponents.second = 0
        calendarComponents.minute = 30
        calendar.timeZone = TimeZone.current
        let dateToFire = calendar.date(from: calendarComponents)
        
        // create a corresponding local notification
        let notification = UILocalNotification()
        
        let dict:NSDictionary = ["ID" : person.id!.description]
        notification.userInfo = dict as! [String : String]
        notification.alertBody = title
        notification.alertAction = "Open"
        notification.fireDate = dateToFire
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
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
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

