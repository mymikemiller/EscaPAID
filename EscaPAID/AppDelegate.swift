//
//  AppDelegate.swift
//  EscaPAID
//
//  Created by Michael Miller on 11/10/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FBSDKCoreKit
import Firebase
import UserNotifications
import Alamofire
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // FirebaseApp.configure() looks in the project for a GoogleService-Info.plist. We have multiple, but that's ok because only one is included with each target. If this ever requires specifying which file to use for the options when configuring, see this post:
        // https://medium.com/@brunolemos/how-to-setup-a-different-firebase-project-for-debug-and-release-environments-157b40512164
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Set the tint color for things like the tab bar icons
        UITabBar.appearance().tintColor = Config.current.mainColor
        
        setUpPageControl()
        registerForPushNotifications(application)
        
        // Check if launched from notification
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            // Don't do respondToPushNotification because it causes the app to crash unless the user is already logged in (which they aren't if we're just launching the app)
            
            //let aps = notification["aps"] as! [String: AnyObject]
            //respondToPushNotification(aps)
        }

        return true
    }
    
    override init() {        
        // Stripe payment configuration
        STPPaymentConfiguration.shared().companyName = Config.current.stripeCompanyName
        STPPaymentConfiguration.shared().publishableKey = Config.current.stripePublishableKey
        
        super.init()
    }
    
    func setUpPageControl() {
        // Make the PageController indicator dots show up
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.backgroundColor = UIColor.white
    }
    
    func registerForPushNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        return handled
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
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "EscaPAID")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // This happens when the app is backgrounded, so we're able to call Firebase functions because we're already logged in
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Only respond to the notifications when the user actually clicked the Notification Center popup (not if the app is already running)
        if application.applicationState == UIApplicationState.inactive {
            
            respondToPushNotification(userInfo)
        }
    }
    
    func respondToPushNotification(_ userInfo: [AnyHashable : Any]) {
        
        // Get the specified user
        let uid = userInfo["uid"] as! String
        FirebaseManager.getUser(uid: uid) { (user) in
            guard let user = user else {
                print("Error responding to push notification. No user at uid /\(uid)")
                return
            }
            
            let data = ["user" : user]
            
            // Send a broadcast notification to let the inbox know which thread to show
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ThreadsNavigationController.SHOW_THREAD_POST), object: data)
        }
    }
    
    // Handle app links for the redirect URI from Stripe. We are coming back from onboarding a user and now have the authorization code, but there is one more step. We have to call into https://connect.stripe.com/oauth/token, but that happens on our server because it needs the Stripe secret key (client secret).
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return false
        }
        
        let authorization_code = url.getQueryStringParameter(param: "code")!
        
        MainAPIClient.shared.redeemOnboardingAuthorizationCode(authCode: authorization_code) { (curatorId) in
            
            // We received the code (user id) from Stripe. Store it for the user.
            FirebaseManager.user?.stripeCuratorId = curatorId
            FirebaseManager.user?.update()
            
            // The app refocused, so we need to refresh the settings page. We accomplish that by sending out a "became curator" notification
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SettingsTableVC.BECAME_CURATOR), object: nil)
        }
        
        
        return true
    }
}

extension AppDelegate : MessagingDelegate {
    // This callback is fired at each app startup and whenever a new token is generated.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        // Store the token so we can write it to the database once we're logged in
        TabBarController.firebaseCloudMessagingToken = fcmToken
    }
}

extension URL {
    func getQueryStringParameter(param: String) -> String? {
        guard let urlComponents = NSURLComponents(url: self, resolvingAgainstBaseURL: false),
            let queryItems = urlComponents.queryItems else {
                return nil
        }
        
        return queryItems.first(where: { $0.name == param })?.value
    }
}
