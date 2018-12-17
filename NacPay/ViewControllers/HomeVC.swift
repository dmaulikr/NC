//
//  HomeVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD
import Charts
import UserNotifications
import SocketIO


class HomeVC: UIViewController,BuyAndSellVCDelegate,DepositeAndWithdrawVCDelegate,UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var lblBuyAndSellPrice: UILabel!
    @IBOutlet weak var lblBTCPrice: UILabel!
    @IBOutlet weak var lblINRPrice: UILabel!
    
    @IBOutlet weak var walletWidth: NSLayoutConstraint!
    @IBOutlet weak var viewINRBalance: UIView!
    @IBOutlet weak var viewBTCBalance: UIView!
    
    @IBOutlet weak var viewSendBTC: UIView!
    @IBOutlet weak var viewReceiveBTC: UIView!
    @IBOutlet weak var viewBID: UIView!
    @IBOutlet weak var viewASK: UIView!
    @IBOutlet weak var viewBuyBTC: UIView!
    @IBOutlet weak var viewSellBTC: UIView!
    @IBOutlet weak var viewDepositBTC: UIView!
    @IBOutlet weak var viewWithdrawBTC: UIView!
    
    @IBOutlet weak var lblBTCtoINR: UILabel!
    @IBOutlet weak var lblIRNtoBTC: UILabel!
    
    @IBOutlet weak var stackUnverfied: UIStackView!
    
    @IBOutlet weak var imgBTC: UIImageView!
    @IBOutlet weak var imgINR: UIImageView!
    
    @IBOutlet weak var btnCheckStatus: UIButton!
    @IBOutlet weak var lblUnderLine: UILabel!
    
    @IBOutlet weak var upperHeight: NSLayoutConstraint!
    
    
    var i = 0 as Int
    let manager = SocketManager(socketURL: URL(string: socketURL)!, config: [.log(false), .forcePolling(true)])
    
    let yourAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 13),
        NSAttributedStringKey.foregroundColor : UIColor.yellow,
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
    
    
    @IBOutlet weak var chartView: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let secondColor =  UIColor(red: 252.0/255, green: 194.0/255, blue: 0, alpha: 1.0).cgColor
        let firstColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 1.0/255, alpha: 1.0).cgColor
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "Dashboard"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        let attributeString = NSMutableAttributedString(string: "Check status",
                                                        attributes: yourAttributes)
        btnCheckStatus.setAttributedTitle(attributeString, for: .normal)
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //viewBTCBalance.layer.cornerRadius = 10
        viewBTCBalance.layer.borderWidth = 1
        viewBTCBalance.layer.borderColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        viewBTCBalance.layer.cornerRadius = 10
        viewINRBalance.layer.cornerRadius = 10
        
        
        imgBTC.layer.cornerRadius = 10
        imgINR.layer.cornerRadius = 10
        
        imgBTC.layer.masksToBounds = true
        imgINR.layer.masksToBounds = true
        
        let gradient = CAGradientLayer()
        gradient.frame.size = viewBTCBalance.frame.size
        gradient.colors = [ secondColor, firstColor, secondColor]
       // viewBTCBalance.layer.insertSublayer(gradient, at: 0)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        
      //  viewINRBalance.layer.cornerRadius = 10
        viewINRBalance.layer.borderWidth = 1
        viewINRBalance.layer.borderColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        let gradient1 = CAGradientLayer()
        gradient1.frame = viewINRBalance.bounds
        gradient1.colors = [secondColor, firstColor, secondColor]
       // viewINRBalance.layer.insertSublayer(gradient1, at: 0)
        gradient1.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient1.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        viewBuyBTC.layer.cornerRadius = 10
        viewBuyBTC.layer.borderWidth = 1
        viewBuyBTC.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        viewSellBTC.layer.cornerRadius = 10
        viewSellBTC.layer.borderWidth = 1
        viewSellBTC.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        viewDepositBTC.layer.cornerRadius = 10
        viewDepositBTC.layer.borderWidth = 1
        viewDepositBTC.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        viewWithdrawBTC.layer.cornerRadius = 10
        viewWithdrawBTC.layer.borderWidth = 1
        viewWithdrawBTC.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        viewSendBTC.layer.cornerRadius = 10
        viewSendBTC.layer.borderWidth = 1
        viewSendBTC.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        viewReceiveBTC.layer.cornerRadius = 10
        viewReceiveBTC.layer.borderWidth = 1
        viewReceiveBTC.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        viewBID.layer.cornerRadius = 10
        viewBID.layer.borderWidth = 1
        viewBID.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        viewASK.layer.cornerRadius = 10
        viewASK.layer.borderWidth = 1
        viewASK.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor

        
        //hide back button of navigation bar
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        //set RightBar button icon
        self.setRightIcon()
        
        //display old value
        self.socketData()
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(HomeVC.socketData), name: Notification.Name(SOCKET_DATA), object: nil)
        
        if Platform.isSimulator {
            print("Running on Simulator")
        }else{
            if UserDefaults.standard.value(forKey: "deviceToken") != nil{
                if UserDefaults.standard.value(forKey: "isTokenRigistered") == nil{
                    self.registerToken()
                }
            }
        }
        
        if let isVerified = UserDefaults.standard.value(forKey: IS_VERIFIED)as? Int{
            if isVerified == 1{
                stackUnverfied.isHidden = true
                upperHeight.constant = -30
            }
        }
        
        let APITimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.callAPI), userInfo: nil, repeats: true)
        
        // Register to receive notification for pin changed
        NotificationCenter.default.addObserver(self, selector: #selector(HomeVC.showPINMsg(notification:)), name: NSNotification.Name(rawValue: "PinChanged"), object: nil)
        
        // Register to receive notification for deposit cancel
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "deposite"), object: nil)
        
        if arrayOfChart.count == 0{
            self.getChartRates()
        }else{
            self.setupChart(max:Double(highest) , min:Double(lowest))
        }
        
        if let is_new_announcement = UserDefaults.standard.value(forKey: IS_NEW_ANNOUNCEMENT)as? Int{
            if is_new_announcement == 1{
                self.callAnnouncementAPI()
            }
        }
        self.checkVersion()
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(HomeVC.checkVersion), name: NSNotification.Name(rawValue: "checkVersion"), object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    
    
    @objc func callAnnouncementAPI() {
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kGetAnnouncement)
        print(url)
        manager.get(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                  print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                         if let announcement = json.value(forKey: "announcement") as? NSDictionary{
                        
                            let alert = UIAlertController(title: announcement.value(forKey: "title")as? String, message: announcement.value(forKey: "content")as? String, preferredStyle: .alert)
                        let yesButton = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                           // self.logoutAPI()
                        })
                        alert.addAction(yesButton)
                        self.present(alert, animated: true) {() -> Void in }
                        } }
                }
            } catch {
                SVProgressHUD.dismiss()
                
                print("error getting string: \(error)")
            }
        })
        
    }
    
    @objc func callAPI() {
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kAuthenticateDevice)
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        let param = ["device_unique_id":deviceID]
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary

                
                if let status = json.value(forKey: "is_verified") as? Int{
                    if status == 0{
                        let alert = UIAlertController(title: "Alert", message: "Logged into another device detected. \nPlease login again to continue Access.", preferredStyle: .alert)
                        let yesButton = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                           self.logoutAPI()
                        })
                        alert.addAction(yesButton)
                        self.present(alert, animated: true) {() -> Void in }
                    }
                }
            } catch {
                SVProgressHUD.dismiss()
                
                print("error getting string: \(error)")
            }
        })
    }
    
    func UpdateApp(){}
    
    func logoutAPI(){
        
        if InternetReachability.isConnectedToNetwork(){
            
            SVProgressHUD.show()
            
            let manager = sessionManager()
            
            let url = kBaseUrl.appending(kLogout)
            // let
            
            print(UserDefaults.standard.value(forKey: "deviceToken"))
            let param = ["device_token":"\(UserDefaults.standard.value(forKey: "deviceToken")!)"]
            
            print(url)
            print(param)
            
            manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
                
                do{
                    let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                    
                    print(json)
                    
                    SVProgressHUD.dismiss()
                    self.clearAllData()
                    
                    
                } catch {
                    SVProgressHUD.dismiss()
                    alert(title: "Server didnt get any responding", msg: "Please try again")
                    print("error getting string: \(error)")
                }
                
            }, failure: { (operation, error) in
                if InternetReachability.isConnectedToNetwork(){
                    giveMeFailure(error: error as NSError, completionHandler: {
                        isTokedUpdated in
                        if isTokedUpdated == true{
                            self.logoutAPI()
                        }
                    })
                }else{
                    SVProgressHUD.dismiss()
                    alert(title: "", msg: "The Internet connection appears to be offline.")
                    print(error.localizedDescription)
                }
            })
            
        }else{
            alert(title: "", msg: "The Internet connection appears to be offline.")
        }
    }
    
    func clearAllData(){
        //clear value from preference
        UserDefaults.standard.removeObject(forKey: IS_LOGIN)
        UserDefaults.standard.removeObject(forKey: ACCESS_TOKEN)
        UserDefaults.standard.removeObject(forKey: TOKEN_TYPE)
        UserDefaults.standard.removeObject(forKey: ACCOUNT_HOLDER_NAME)
        UserDefaults.standard.removeObject(forKey: ACCOUNT_NUMBER)
        UserDefaults.standard.removeObject(forKey: BALANCE_BTC)
        UserDefaults.standard.removeObject(forKey: BALANCE_RS)
        UserDefaults.standard.removeObject(forKey: BANK_NAME)
        UserDefaults.standard.removeObject(forKey: BIRTHDATE)
        UserDefaults.standard.removeObject(forKey: BRANCH_NAME)
        UserDefaults.standard.removeObject(forKey: EMAIL)
        UserDefaults.standard.removeObject(forKey: FIRSTNAME)
        UserDefaults.standard.removeObject(forKey: FROZEN_BTC)
        UserDefaults.standard.removeObject(forKey: GENDER)
        UserDefaults.standard.removeObject(forKey: IFSC_CODE)
        UserDefaults.standard.removeObject(forKey: IS_ACTIVE)
        UserDefaults.standard.removeObject(forKey: IS_EMAIL_VERIFIED)
        UserDefaults.standard.removeObject(forKey: IS_PHONE_VERIFIED)
        UserDefaults.standard.removeObject(forKey: IS_VERIFIED)
        UserDefaults.standard.removeObject(forKey: LASTNAME)
        UserDefaults.standard.removeObject(forKey: LOCK_BTC)
        UserDefaults.standard.removeObject(forKey: LOCK_RS)
        UserDefaults.standard.removeObject(forKey: NAME)
        UserDefaults.standard.removeObject(forKey: PAN_CARD_NUMBER)
        UserDefaults.standard.removeObject(forKey: PAN_CARD_PHOTO)
        UserDefaults.standard.removeObject(forKey: PHONE_NUMBER)
        UserDefaults.standard.removeObject(forKey: PIN_TRIES)
        UserDefaults.standard.removeObject(forKey: PROFILE_IMAGE)
        UserDefaults.standard.removeObject(forKey: PROFILE_IMAGE_URL)
        UserDefaults.standard.removeObject(forKey: WITHDRAW_RS)
        UserDefaults.standard.removeObject(forKey: OTHER_ID_PROOF_NO)
        UserDefaults.standard.removeObject(forKey: OTHER_ID_PROOF_NO_PHOTO)
        UserDefaults.standard.removeObject(forKey: OTHER_ID_PROOF_NO_PHOTO_2)
        UserDefaults.standard.removeObject(forKey: OTHER_ID_PROOF_NO_PHOTO_2_URL)
        
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDel.DrawerSettings()
    }
    
    @IBAction func onCheckStatusClicked(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountVerificationVC") as! AccountVerificationVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc func checkVersion(){
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kiOSVersion)
     // let deviceID = UIDevice.current.identifierForVendor!.uuidString
       // let param = ["device_unique_id":deviceID]
        print(url)
       // print(param)
        
        manager.get(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            do{
                SVProgressHUD.dismiss()
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                  print(json)
                
                if let status = json.value(forKey: "status") as? Int{
                    if status == 1{
                        if let versions = json.value(forKey: "versions") as? Array<Any>{
                            print(versions)
                            if versions.isEmpty == false{
                                let Updatelist = versions[0] as? NSDictionary
                                print(Updatelist)
                                if let forceUpdate = Updatelist?.value(forKey: "is_force_update") as? Double{
                                    if forceUpdate == 0{}
                                    else{
                                        let alert = UIAlertController(title: "Attention!!", message: "New Version of this app is available. Need to+ Update app", preferredStyle: .alert)
                                        let yesButton = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                                            self.UpdateApp()
                                        })
                                        alert.addAction(yesButton)
                                        self.present(alert, animated: true) {() -> Void in }
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                SVProgressHUD.dismiss()
                
                print("error getting string: \(error)")
            }
        })
        
//        do {
//            let isBool = try isUpdateAvailable()
//            print(isBool)
//            if isBool{
//                let alert = UIAlertController(title: "New Version",
//                                              message: "Version \(self.latestVersion) is available on the AppStore.",
//                    preferredStyle: UIAlertControllerStyle.alert)
//
//                let yesAction = UIAlertAction(title: "Update", style: .default) { (alert) in
//                    let url = URL(string: "https://itunes.apple.com/us/app/virtual-coins-bitcoin-india/id1272169376?ls=1&mt=8")!
//                    if #available(iOS 10.0, *) {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    } else {
//                        UIApplication.shared.openURL(url)
//                    }
//                }
//
//                alert.addAction(yesAction)
//                present(alert, animated: true, completion: nil)
//            }
//
//        } catch {}
    }

    var latestVersion = ""
    func isUpdateAvailable() throws -> Bool {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw VersionError.invalidResponse
        }
        if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
            self.latestVersion = version
            return version != currentVersion
        }
        throw VersionError.invalidResponse
    }

    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
    // handle notification
    @objc func showSpinningWheel(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let str = dict["msg"] as? String{
                self.view.makeToast(str, duration: 2.0, position: .bottom)
            }
        }
    }
    
    @objc func showPINMsg(notification: NSNotification){
         self.view.makeToast("Pin Changed Successfully!", duration: 2.0, position: .bottom)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.view.isUserInteractionEnabled = true
        
        if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String , let pin = UserDefaults.standard.value(forKey: PIN)as? String{
            self.login(number: number, pin: pin)
        }
        
//        if InternetReachability.isConnectedToNetwork(){
//            self.checkVersion()
//        }
        
    }
    
    
    
    func sendNotification()
    {
        if #available(iOS 10.0, *){
            
        let content = UNMutableNotificationContent()
        content.title = "Naccoin BTC Price Alert!!"
        content.body = "BUY - ₹ \(buyPrice)   |   SELL - ₹ \(sellPrice)"
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                        repeats: false)
        
        let requestIdentifier = "demoNotification"
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request,
                                               withCompletionHandler: { (error) in
                                                print(Error.self)
        })
        
        let repeatAction = UNNotificationAction(identifier:"repeat",
                                                title:"Repeat",options:[])
        let changeAction = UNTextInputNotificationAction(identifier:
            "change", title: "Change Message", options: [])
        
        let category = UNNotificationCategory(identifier: "actionCategory",
                                              actions: [repeatAction, changeAction],
                                              intentIdentifiers: [], options: [])
        
        content.categoryIdentifier = "actionCategory"
        
        UNUserNotificationCenter.current().setNotificationCategories(
            [category])
        }
    }
    
    //MARK:- Delegate methods
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case "repeat":
            self.sendNotification()
        case "change":
            let textResponse = response
                as! UNTextInputNotificationResponse
           // messageSubtitle = textResponse.userText
            self.sendNotification()
        default:
            break
        }
        completionHandler()
    }
    
    
     
    /*=======================================================================
     * Function Purpose: set Rightbar buttons in NavigationBar
     * ====================================================================*/
    func setRightIcon(){
        //create a rightBar button for Logout
        let button: UIButton = UIButton(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "ic_menu"), for: UIControlState())
        //add function for button
        button.addTarget(self, action: #selector(HomeVC.openDrawer), for: UIControlEvents.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        if #available(iOS 9.0, *) {
            let widthConstraint = button.widthAnchor.constraint(equalToConstant: 28)
            let heightConstraint = button.heightAnchor.constraint(equalToConstant: 33)
            heightConstraint.isActive = true
            widthConstraint.isActive = true
        }
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
        
        
        //create a rightBar button for Logout
        let leftButton: UIButton = UIButton(type: .custom)
        //set image for button
      //  leftButton.setImage(UIImage(named: "ic_app_logo"), for: UIControlState())
      //  leftButton.translatesAutoresizingMaskIntoConstraints = false
        //add function for button
        //leftButton.addTarget(self, action: #selector(HomeVC.openDrawer), for: UIControlEvents.touchUpInside)
        
        if #available(iOS 9.0, *) {
            let widthConstraint = leftButton.widthAnchor.constraint(equalToConstant: 28)
            let heightConstraint = leftButton.heightAnchor.constraint(equalToConstant: 33)
            heightConstraint.isActive = true
            widthConstraint.isActive = true
        }
        
        let leftbarButton = UIBarButtonItem(customView: leftButton)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = leftbarButton
    }
    
    @objc func openDrawer(){
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
    }
    //====================end function for setRightIcons======================
    
    @objc func socketData(){
        
     //   let appDelegate = UIApplication.shared.delegate as! AppDelegate
     //   appDelegate.connectToSocketServer()
        
        if i%15 == 0 {
            connectToSocketServer()
        }
        print(i)
        
        self.lblBuyAndSellPrice.text = "BUY - ₹ \(buyPrice)   |   SELL - ₹ \(sellPrice)"
        
        if let btcPrice = UserDefaults.standard.value(forKey: BALANCE_BTC)as? String{

            var btcPriceFloat = Float(btcPrice)
            
            if btcPriceFloat == 0.000000{
                self.lblBTCPrice.text = "฿ 0.0"
                self.lblBTCPrice.font = UIFont.boldSystemFont(ofSize: 15)
            }else{
                let st = Float(buyPrice) * btcPriceFloat!
                let twoDecimalPlaces = String(format: "%.2f", st)
                self.lblBTCPrice.text = "฿ \(btcPrice)\n(₹ \(twoDecimalPlaces))"
                let str = (Double(btcPrice)! * Double(buyPrice))
                let twoDecimal = String(format: "%.2f", str)
                print((Double(btcPrice)! * Double(buyPrice)))
                self.lblBTCtoINR.text = "(₹ \(twoDecimal) )"
            }
        }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        
        if i%15 == 0 {
           sendNotification()
        }
        
        i += 1
        print(i)
        
        if let inrPrice = UserDefaults.standard.value(forKey: BALANCE_RS)as? String{
            let inr = Float(inrPrice)!
            if inr == 0{
                let st = Float(inr) / Float(buyPrice)
                self.lblINRPrice.text = "₹ \(inrPrice)\n(฿ \(st))"
                let str = Double(inr) / Double(buyPrice)
                let twoDecimal = String(format: "%.6f", str)
                self.lblIRNtoBTC.text = "(฿ \(twoDecimal) )"
            }else{
                let st = Float(inr) / Float(buyPrice)
                self.lblINRPrice.text = "₹ \(inrPrice)\n(฿ \(st))"
                let str = Double(inr) / Double(buyPrice)
                let twoDecimal = String(format: "%.6f", str)
                self.lblIRNtoBTC.text = "(฿ \(twoDecimal) )"
            }
        }
    }
    
    func connectToSocketServer(){
        //connect socket with server
        let socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            socket.emit("afterConnect")

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
         NotificationCenter.default.post(name: Notification.Name(SOCKET_DATA), object: nil)
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
    
    func showToast(msg:String){
        self.view.makeToast(msg, duration: 2.0, position: .bottom)
    }
    
    @IBAction func buttonBuy(_ sender: UIButton) {
        self.view.isUserInteractionEnabled = false
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "BuyAndSellVC")as! BuyAndSellVC
        nextVC.navigationTitle = "BUY BITCOINS"
        nextVC.delegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func buttonSell(_ sender: UIButton) {
        self.view.isUserInteractionEnabled = false
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "BuyAndSellVC")as! BuyAndSellVC
        nextVC.navigationTitle = "SELL BITCOINS"
        nextVC.delegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func buttonDeposite(_ sender: UIButton) {
        self.view.isUserInteractionEnabled = false
        getPendingDeposit { (isSuccess, response) in
            
            if isSuccess{
                
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DepositeWithdrawReceiptVC")as! DepositeWithdrawReceiptVC
                nextVC.isFromDeposite = true
                nextVC.arrayOfData = response
                self.navigationController?.pushViewController(nextVC, animated: true)
                
            }else{
                
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DepositeAndWithdrawVC")as! DepositeAndWithdrawVC
                nextVC.delegate = self
                nextVC.navigationTitle = "DEPOSIT MONEY"
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }
    
    @IBAction func buttonWithdraw(_ sender: UIButton) {
        self.view.isUserInteractionEnabled = false
        getPendingWithdraw { (isSuccess, response) in
            if isSuccess{
                
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DepositeWithdrawReceiptVC")as! DepositeWithdrawReceiptVC
                nextVC.isFromDeposite = false
                nextVC.arrayOfData = response
                self.navigationController?.pushViewController(nextVC, animated: true)

            }else{
                
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DepositeAndWithdrawVC")as! DepositeAndWithdrawVC
                nextVC.navigationTitle = "RS WITHDRAW"
                nextVC.delegate = self
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }
    
    @IBAction func onSendClicked(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SendVC")as! SendVC
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    
    @IBAction func onReceiveClicked(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ReceiveVC")as! ReceiveVC
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    
    @IBAction func onBidClicked(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "BidVC")as! BidVC
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    
    @IBAction func onAskClicked(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "AskVC")as! AskVC
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    
    
    
    @IBAction func buttonHandlerTabBar(_ sender: UIButton) {
        self.view.isUserInteractionEnabled = false
        if sender.tag == 2{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SendVC")as! SendVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }else if sender.tag == 3{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ReceiveVC")as! ReceiveVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }else if sender.tag == 4{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "BidVC")as! BidVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }else if sender.tag == 5{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "AskVC")as! AskVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }
    }
    
    func getPendingDeposit(completionHandler:@escaping (Bool,NSArray) -> ()){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kGetPendingDeposite)
        
        print(url)
        
        manager.post(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
               // print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        if let deposite = json.value(forKey: "deposits") as? NSArray{
                            if deposite.count > 0{
                                SVProgressHUD.dismiss()
                                completionHandler(true, deposite)
                            }
                        }
                    }else{
                        SVProgressHUD.dismiss()
                        completionHandler(false, [])
                    }
                }
                
            } catch {
                SVProgressHUD.dismiss()
                completionHandler(false, [])
                alert(title: "Server didnt get any responding", msg: "Please try again")
                print("error getting string: \(error)")
            }
            
        }, failure: { (operation, error) in
            if InternetReachability.isConnectedToNetwork(){
                giveMeFailure(error: error as NSError, completionHandler: {
                    isTokedUpdated in
                    if isTokedUpdated == true{
                        
                        self.getPendingDeposit { (isSuccess, response) in
                            
                            if isSuccess{
                                
                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DepositeWithdrawReceiptVC")as! DepositeWithdrawReceiptVC
                                nextVC.isFromDeposite = true
                                nextVC.arrayOfData = response
                                self.navigationController?.pushViewController(nextVC, animated: true)
                                
                            }else{
                                
                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DepositeAndWithdrawVC")as! DepositeAndWithdrawVC
                                nextVC.navigationTitle = "DEPOSIT MONEY"
                                nextVC.delegate = self
                                self.navigationController?.pushViewController(nextVC, animated: true)
                            }
                        }
                        
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    
    func getPendingWithdraw(completionHandler:@escaping (Bool,NSArray) -> ()){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kGetPendingWithDraw)
        
        print(url)
        
        manager.post(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
               // print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        if let withdraw = json.value(forKey: "withdraw") as? NSArray{
                            if withdraw.count > 0{
                                SVProgressHUD.dismiss()
                                completionHandler(true, withdraw)
                            }
                        }
                    }else{
                        SVProgressHUD.dismiss()
                        completionHandler(false, [])
                    }
                }
                
            } catch {
                SVProgressHUD.dismiss()
                completionHandler(false, [])
                alert(title: "Server didnt get any responding", msg: "Please try again")
                print("error getting string: \(error)")
            }
            
        }, failure: { (operation, error) in
            if InternetReachability.isConnectedToNetwork(){
                giveMeFailure(error: error as NSError, completionHandler: {
                    isTokedUpdated in
                    if isTokedUpdated == true{
                        
                        self.getPendingWithdraw { (isSuccess, response) in
                            if isSuccess{
                                
                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DepositeWithdrawReceiptVC")as! DepositeWithdrawReceiptVC
                                nextVC.isFromDeposite = false
                                nextVC.arrayOfData = response
                                self.navigationController?.pushViewController(nextVC, animated: true)
                                
                            }else{
                                
                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DepositeAndWithdrawVC")as! DepositeAndWithdrawVC
                                nextVC.delegate = self
                                nextVC.navigationTitle = "RS WITHDRAW"
                                self.navigationController?.pushViewController(nextVC, animated: true)
                            }
                        }
                        
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    
    func login(number:String,pin:String){
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let serializer = AFJSONRequestSerializer()
        serializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        serializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer = serializer
        
        let url = kBaseUrl.appending(kLogin)
        let param = [PHONE_NUMBER:number, PINLOCK:pin]
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let user = json.value(forKey: USER) as? NSDictionary{
                            
                            if let account_holder_name = user.value(forKey: ACCOUNT_HOLDER_NAME)as? String{
                                UserDefaults.standard.set(account_holder_name, forKey: ACCOUNT_HOLDER_NAME)
                            }
                            
                            if let account_number = user.value(forKey: ACCOUNT_NUMBER)as? String{
                                UserDefaults.standard.set(account_number, forKey: ACCOUNT_NUMBER)
                            }
                            
                            if let balance_btc = user.value(forKey: BALANCE_BTC)as? String{
                              //  UserDefaults.standard.set(balance_btc, forKey: BALANCE_BTC)
                                UserDefaults.standard.set("0.108321", forKey: BALANCE_BTC)
                            }
                            
                            if let balance_rs = user.value(forKey: BALANCE_RS)as? String{
                                UserDefaults.standard.set(balance_rs, forKey: BALANCE_RS)
                            }
                            
                            if let bank_name = user.value(forKey: BANK_NAME)as? String{
                                UserDefaults.standard.set(bank_name, forKey: BANK_NAME)
                            }
                            
                            if let birthdate = user.value(forKey: BIRTHDATE)as? String{
                                UserDefaults.standard.set(birthdate, forKey: BIRTHDATE)
                            }
                            
                            if let branch_name = user.value(forKey: BRANCH_NAME)as? String{
                                UserDefaults.standard.set(branch_name, forKey: BRANCH_NAME)
                            }
                            
                            if let email = user.value(forKey: EMAIL)as? String{
                                UserDefaults.standard.set(email, forKey: EMAIL)
                            }
                            
                            if let firstname = user.value(forKey: FIRSTNAME)as? String{
                                UserDefaults.standard.set(firstname, forKey: FIRSTNAME)
                            }
                            
                            if let frozen_btc = user.value(forKey: FROZEN_BTC)as? String{
                                UserDefaults.standard.set(frozen_btc, forKey: FROZEN_BTC)
                            }
                            
                            if let gender = user.value(forKey: GENDER)as? String{
                                UserDefaults.standard.set(gender, forKey: GENDER)
                            }
                            
                            if let ifsc_code = user.value(forKey: IFSC_CODE)as? String{
                                UserDefaults.standard.set(ifsc_code, forKey: IFSC_CODE)
                            }
                            
                            if let is_active = user.value(forKey: IS_ACTIVE)as? Int{
                                UserDefaults.standard.set(is_active, forKey: IS_ACTIVE)
                            }
                            
                            if let is_email_verified = user.value(forKey: IS_EMAIL_VERIFIED)as? Int{
                                UserDefaults.standard.set(is_email_verified, forKey: IS_EMAIL_VERIFIED)
                            }
                            
                            if let is_phone_verified = user.value(forKey: IS_PHONE_VERIFIED)as? Int{
                                UserDefaults.standard.set(is_phone_verified, forKey: IS_PHONE_VERIFIED)
                            }
                            
                            if let is_verified = user.value(forKey: IS_VERIFIED)as? Int{
                                UserDefaults.standard.set(is_verified, forKey: IS_VERIFIED)
                            }
                            
                            if let lastname = user.value(forKey: LASTNAME)as? String{
                                UserDefaults.standard.set(lastname, forKey: LASTNAME)
                            }
                            
                            if let lock_btc = user.value(forKey: LOCK_BTC)as? String{
                                UserDefaults.standard.set(lock_btc, forKey: LOCK_BTC)
                            }
                            
                            if let lock_rs = user.value(forKey: LOCK_RS)as? String{
                                UserDefaults.standard.set(lock_rs, forKey: LOCK_RS)
                            }
                            
                            if let name = user.value(forKey: NAME)as? String{
                                UserDefaults.standard.set(name, forKey: NAME)
                            }
                            
                            if let pan_card_no = user.value(forKey: PAN_CARD_NUMBER)as? String{
                                UserDefaults.standard.set(pan_card_no, forKey: PAN_CARD_NUMBER)
                            }
                            
                            if let pan_card_photo = user.value(forKey: PAN_CARD_PHOTO)as? String{
                                UserDefaults.standard.set(pan_card_photo, forKey: PAN_CARD_PHOTO)
                            }
                            
                            if let phone_number = user.value(forKey: PHONE_NUMBER)as? String{
                                UserDefaults.standard.set(phone_number, forKey: PHONE_NUMBER)
                            }
                            
                            if let tokenString = user.value(forKey: TOKEN) as? String{
                                UserDefaults.standard.set(tokenString, forKey: ACCESS_TOKEN)
                               
                            }
                            
                            if let pin_tries = user.value(forKey: PIN_TRIES)as? Int{
                                UserDefaults.standard.set(pin_tries, forKey: PIN_TRIES)
                            }
                            
                            if let profile_image_url = user.value(forKey: PROFILE_IMAGE_URL)as? String{
                                UserDefaults.standard.set(profile_image_url, forKey: PROFILE_IMAGE_URL)
                            }
                            
                            if let withdraw_rs = user.value(forKey: WITHDRAW_RS)as? Int{
                                UserDefaults.standard.set(withdraw_rs, forKey: WITHDRAW_RS)
                            }
                        }
                    }
                }
                
            } catch {
                print("error getting string: \(error)")
            }
            
        }, failure: { (operation, error) in
            print(error.localizedDescription)
        })
        
    }
    
    func registerToken(){
        
        if InternetReachability.isConnectedToNetwork(){
            
            let manager = sessionManager()
            
            let url = kBaseUrl.appending(kAddUpdateIosDeviceToken)
            let param = ["device_token":"\(UserDefaults.standard.value(forKey: "deviceToken")!)"]
            
            print(url)
            print(param)
            
            manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
                
                do{
                    let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                    
                    print(json)
                    UserDefaults.standard.set(true, forKey: "isTokenRigistered")
                    
                } catch {
                    SVProgressHUD.dismiss()
                    alert(title: "Server didnt get any responding", msg: "Please try again")
                    print("error getting string: \(error)")
                }
                
            }, failure: { (operation, error) in
                if InternetReachability.isConnectedToNetwork(){
                    giveMeFailure(error: error as NSError, completionHandler: {
                        isTokedUpdated in
                        if isTokedUpdated == true{
                            self.registerToken()
                        }
                    })
                }else{
                    SVProgressHUD.dismiss()
                    alert(title: "", msg: "The Internet connection appears to be offline.")
                    print(error.localizedDescription)
                }
            })
            
        }else{
            alert(title: "", msg: "The Internet connection appears to be offline.")
        }
    }
    
    func getChartRates(){
        
        if InternetReachability.isConnectedToNetwork(){
            
            let manager = sessionManager()
            
            let url = kBaseUrl.appending(kGetRates)
            
            let param = ["days":"20"]
            
            manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
                
                do{
                    let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                    
                    print(json)
                    
                    if let status = json[STATUS]as? Int{
                        if status == 1{
                            
                            if let chartArray = json["rates"]as? NSArray{
                                for json in chartArray{
                                    arrayOfChart.add(json as! NSDictionary)
                                }
                                
                                highest = Int(json["highestRate"]as! Double)
                                lowest = Int(json["lowestRate"]as! Double)
                                
                                highest += 30000
                                lowest -= 10000
                                
                                self.setupChart(max:Double(highest) , min:Double(lowest))
                            }
                            
                            SVProgressHUD.dismiss()
                            
                        }else{
                            SVProgressHUD.dismiss()
                            alert(title: "", msg: json[MSG]as! String)
                        }
                    }
                    
                } catch {
                    SVProgressHUD.dismiss()
                    alert(title: "Server didnt get any responding", msg: "Please try again")
                    print("error getting string: \(error)")
                }
                
            }, failure: { (operation, error) in
                if InternetReachability.isConnectedToNetwork(){
                    giveMeFailure(error: error as NSError, completionHandler: {
                        isTokedUpdated in
                        if isTokedUpdated == true{
                            self.getChartRates()
                        }
                    })
                }else{
                    SVProgressHUD.dismiss()
                    alert(title: "", msg: "The Internet connection appears to be offline.")
                    print(error.localizedDescription)
                }
            })
            
        }else{
            alert(title: "", msg: "The Internet connection appears to be offline.")
        }
    }
    
    func setupChart(max:Double,min:Double){
        
        self.chartView.chartDescription?.enabled = false
        self.chartView.dragEnabled = true
        self.chartView.setScaleEnabled(true)
        self.chartView.pinchZoomEnabled = true
        self.chartView.drawGridBackgroundEnabled = false

        // x-axis limit line
        let llXAxis = ChartLimitLine(limit: 10.0, label: "")
        llXAxis.lineWidth = 4.00
        llXAxis.lineDashLengths = [(10.0), (10.0), (0.0)]
        llXAxis.labelPosition = .rightBottom
        llXAxis.valueFont = UIFont.systemFont(ofSize: 10.0)

        chartView.xAxis.gridLineDashLengths = [10.0, 10.0]
        chartView.xAxis.gridLineDashPhase = 0.0

        let leftAxis: YAxis? = chartView.leftAxis
        leftAxis?.labelTextColor = UIColor.white
        leftAxis?.removeAllLimitLines()
        leftAxis?.axisMaximum = max
        leftAxis?.axisMinimum = min
        leftAxis?.gridLineDashLengths = [5.0, 5.0]
        leftAxis?.drawZeroLineEnabled = false
        leftAxis?.drawLimitLinesBehindDataEnabled = true
        chartView.rightAxis.enabled = false

        let marker = BalloonMarker(color: UIColor.white, font: UIFont.systemFont(ofSize: 8.0), textColor: UIColor.white, insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80.0, height: 40.0)
        marker.color = UIColor.init(hexString: "D6B833")
        self.chartView.marker = marker
        self.chartView.legend.form = .line
        self.chartView.animate(xAxisDuration: 2.5)

        let values = NSMutableArray()

        for i in 0..<arrayOfChart.count{
            let json = arrayOfChart.object(at: i)as! NSDictionary
            let val = (json.value(forKey: "rate")as! Double)
            values.add(ChartDataEntry(x: Double(i), y: Double(val)))
        }

        var set1 = LineChartDataSet()
        set1 = LineChartDataSet(values: values as? [ChartDataEntry], label: "")
        set1.drawIconsEnabled = false
        set1.lineDashLengths = [5.0, 2.5]
        set1.highlightLineDashLengths = [5.0, 2.5]
        set1.colors = [UIColor.yellow]
        set1.circleColors = [UIColor.white]
        set1.lineWidth = 1.0
        set1.circleRadius = 1.0
        set1.drawCircleHoleEnabled = false
        set1.valueFont = UIFont.systemFont(ofSize: 0.0)
        set1.valueColors = [UIColor.yellow]
        set1.formLineDashLengths = [5.0, 2.5]
        set1.formLineWidth = 1.0
        set1.formSize = 15.0

        let gradientColors = [ChartColorTemplates.colorFromString("#F2F2A6").cgColor,ChartColorTemplates.colorFromString("#F4F4D0").cgColor]
        let gradient = CGGradient.init(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)

        set1.fillAlpha = 0.3
        set1.fill = Fill(linearGradient: gradient!, angle: 90.0)
        set1.drawFilledEnabled = true
        var dataSets = [Any]()
        dataSets.append(set1)
        let data = LineChartData(dataSets: dataSets as? [IChartDataSet])
        chartView.data = data

        for _ in self.chartView.data!.dataSets{
            set1.mode = .cubicBezier
        }
    }
}
