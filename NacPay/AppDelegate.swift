//
//  AppDelegate.swift
//  NacPay
//
//  Created by Maulik D'sai on 10/11/17.
//  Copyright © 2017 Maulik D'sai. All rights reserved.
//

import UIKit
import SVProgressHUD
import AFNetworking
import SocketIO
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    var paymentOptionVC : UIViewController?
    
    // -----------
    var centerContainer : MMDrawerController?
    //----------
    
    var reach: Reachability?
    
    
    let manager = SocketManager(socketURL: URL(string: socketURL)!, config: [.log(false), .forcePolling(true)])
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //set navigationBar
        self.navigationSetting()
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
            case 1334:
                print("iPhone 6/6S/7/8")
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                print("iPhone X")
                application.isStatusBarHidden = false
            default:
                print("unknown")
            }
        }
        
      //  Fabric.with([Crashlytics.self])
      //  Crashlytics.sharedInstance().debugMode = true
        
        //setupKeyboard
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
        //connect to socket
        self.connectToSocketServer()
        
        self.registerForPushNotifications(application: application)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if let isPinLock = UserDefaults.standard.value(forKey: "isPinLock")as? Bool{
            if !isPinLock{
                //setup drawer
                DrawerSettings()
            }
        }
        
        self.reach = Reachability.forInternetConnection()
        self.reach!.reachableOnWWAN = false
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AppDelegate.reachabilityChanged(notification:)),
                                               name: NSNotification.Name.reachabilityChanged,
                                               object: nil)
        
        self.reach!.startNotifier()
        
        
        // Override point for customization after application launch.
        return true
    }
    
    func navigationSetting()
    {
        // Set navigation bar color
        UINavigationBar.appearance().barTintColor = UIColor.white
        
        //Set navigation bar back button color
        UINavigationBar.appearance().tintColor = UIColor.init(hexString: "FFD700")
        
        //Set translucent false to set original color in navigation
        UINavigationBar.appearance().isTranslucent = false
        
    }
    
    func DrawerSettings()
    {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        var centerViewController = UIViewController()
        if UserDefaults.standard.value(forKey: IS_LOGIN) != nil{
            centerViewController = mainStoryboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        }else{
            centerViewController = mainStoryboard.instantiateViewController(withIdentifier: "VerifyPhoneVC") as! VerifyPhoneVC
        }
        
        let rightViewController = mainStoryboard.instantiateViewController(withIdentifier: "RightDrawerVC") as! RightDrawerVC
        
        let rightSideNav = UINavigationController(rootViewController: rightViewController)
        let centerNav = UINavigationController(rootViewController: centerViewController)
        
        centerContainer = MMDrawerController(center: centerNav, rightDrawerViewController: rightSideNav)
        
        //centerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
        centerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.all
        
        window!.rootViewController = centerContainer
        window!.makeKeyAndVisible()
    }
    
    func connectToSocketServer(){
        //connect socket with server
        let socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            socket.emit("afterConnect")
            print(data)
            NotificationCenter.default.post(name: Notification.Name(SOCKET_DATA), object: nil)
        }
        
        //connect socket
        socket.connect()
        
        //fetch data from socket
        
        socket.emit("afterConnect")
        
        socket.on("updateBtcPrice") { (data, emitter) in
            let array = NSArray(array: (data.reversed()))
            if let json = array.object(at: 0) as? NSDictionary{
                print(json)
                let _ = SocketModel(dict: json)
                
                // Post notification
                NotificationCenter.default.post(name: Notification.Name(SOCKET_DATA), object: nil)
            }
        }
        
        //fetch data from socket
        socket.on("notifyMaintenance") { (data, emitter) in
            
            let array = NSArray(array: (data.reversed()))
            if let json = array.object(at: 0) as? NSDictionary{
                if let val = json.value(forKey: "is_maintenance_mode")as? String{
                    is_maintenance_mode = val
                    if is_maintenance_mode == "1"{
                        alert(title: BodyTitle, msg: subTitle)
                    }
                }
            }
        }
    }
    
    // Support for background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("fetch")
    }
    
    func registerForPushNotifications(application: UIApplication) {
        
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
                if (granted)
                {
                    DispatchQueue.main.async(execute: {
                        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
                        application.registerForRemoteNotifications()
                    })
                }
                else{
                    //Do stuff if unsuccessful...
                }
            })
        }
        else{
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            application.registerForRemoteNotifications()
            
        }
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token = String(format: "%@", deviceToken as CVarArg)
            .trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
            .replacingOccurrences(of: " ", with: "")
        
        print("deviceToken ==> \(token)")
        UserDefaults.standard.set(token, forKey: "deviceToken")
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("deviceToken error ==>  %@", error.localizedDescription)
    }
    
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        NSLog("Notification value is --> %@", userInfo)
//
//                let state = UIApplication.shared.applicationState
//                if state == .background || state == .inactive {
//
//                }
//                else if state == .active {
//                    // foreground
//                    if let aps = userInfo["aps"] as? NSDictionary {
//                        if let alert = aps["alert"] as? NSDictionary {
//                            if let message = alert["body"] as? String {
//                                let banner = Banner(title: "PropStop", subtitle: message, image: UIImage(named: "Logo"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
//                                banner.dismissesOnTap = true
//                                banner.show(duration: 5.0)
//                            }
//                        }
//                    }
//                }
        
    }
    
    
    func issuesUserAccessToken(number:String,pin:String,completionHandler:@escaping (Bool) -> ()){
        
        SVProgressHUD.show()
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let TOKEN_URL = TokenAPI
        
        let param = ["grant_type":"password","client_id":"2","client_secret":"BNiY9O50ON2CNBmihJeHTZzE23XBW8wrdo1a8nu4","password":pin,"username":number]
        
        print(TOKEN_URL)
        print(param)
        
        manager.post(TOKEN_URL, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                if let access_token = json[ACCESS_TOKEN]as? String{
                    UserDefaults.standard.set(access_token, forKey: ACCESS_TOKEN)
                }
                
                if let refresh_token = json[REFRESH_TOKEN]as? String{
                    UserDefaults.standard.set(refresh_token, forKey: REFRESH_TOKEN)
                }
                
                if let token_type = json[TOKEN_TYPE]as? String{
                    UserDefaults.standard.set(token_type, forKey: TOKEN_TYPE)
                }
                
                
                SVProgressHUD.dismiss()
                completionHandler(true)
                
                
            } catch {
                SVProgressHUD.dismiss()
                completionHandler(false)
                print("error getting string: \(error)")
            }
            
        }, failure: { (operation, error) in
            SVProgressHUD.dismiss()
            completionHandler(false)
            print("Error: " + error.localizedDescription)
            
            if let dataError = (error as NSError).userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? Data {
                if let ErrorResponse = String(data: dataError, encoding: String.Encoding.utf8){
                    if ErrorResponse != ""{
                        print(ErrorResponse)
                    }
                }
            }
        })
    }
    
    func refreshUserAccessToken(refresh_token:String,completionHandler:@escaping (Bool) -> ()){
        
        SVProgressHUD.show()
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let TOKEN_URL = TokenAPI
        
        let param = ["grant_type":"password","client_id":"2","client_secret":"BNiY9O50ON2CNBmihJeHTZzE23XBW8wrdo1a8nu4","refresh_token":refresh_token]
        
        print(TOKEN_URL)
        print(param)
        
        manager.post(TOKEN_URL, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let access_token = json[ACCESS_TOKEN]as? String{
                    UserDefaults.standard.set(access_token, forKey: ACCESS_TOKEN)
                }
                
                if let token_type = json[TOKEN_TYPE]as? String{
                    UserDefaults.standard.set(token_type, forKey: TOKEN_TYPE)
                }
                
                SVProgressHUD.dismiss()
                completionHandler(true)
                
            } catch {
                SVProgressHUD.dismiss()
                completionHandler(false)
                print("error getting string: \(error)")
            }
            
        }, failure: { (operation, error) in
            if InternetReachability.isConnectedToNetwork(){
                giveMeFailure(error: error as NSError, completionHandler: {
                    isTokedUpdated in
                    if isTokedUpdated == true{
                        completionHandler(true)
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
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
        
        // Post notification
  //  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkVersion"), object: nil)
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    @objc func reachabilityChanged(notification: NSNotification) {
        
        if self.reach!.isReachableViaWiFi() || self.reach!.isReachableViaWWAN() || self.reach!.isReachable(){
            
            print("Service avalaible!!!")
            
            // Post notification
          //  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkVersion"), object: nil)
            
        } else {
            print("No service avalaible!!!")
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

