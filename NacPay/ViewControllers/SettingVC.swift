//
//  SettingVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

class SettingVC: UIViewController {
    
    
    @IBOutlet weak var switchPinLock: UISwitch!
    @IBOutlet weak var switchLockOutGoingTransaction: UISwitch!
    @IBOutlet weak var switchSound: UISwitch!
    @IBOutlet weak var switchVibration: UISwitch!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "SETTING"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //hide back button of navigation bar
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        //set RightBar button icon
        self.setRightIcon()
        
        if let isOTP = UserDefaults.standard.value(forKey: IS_OTP_ON_TRANSACTION)as? Int{
            if isOTP == 1{
                self.switchLockOutGoingTransaction.isOn = true
            }else{
                self.switchLockOutGoingTransaction.isOn = false
            }
        }
        
        if let isPinLock = UserDefaults.standard.value(forKey: "isPinLock")as? Bool{
            if isPinLock{
                self.switchPinLock.isOn = true
            }else{
                self.switchPinLock.isOn = false
            }
        }
        
        // Register to receive notification for OutGoingTransaction
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "OutGoingTransaction"), object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // handle notification
    @objc func showSpinningWheel(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let str = dict["otp"] as? String{
                self.setUserSetting(val: "0", otp: str)
            }
        }
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
        button.addTarget(self, action: #selector(SettingVC.openDrawer), for: UIControlEvents.touchUpInside)
        //set frame
        if #available(iOS 9.0, *) {
            let widthConstraint = button.widthAnchor.constraint(equalToConstant: 28)
            let heightConstraint = button.heightAnchor.constraint(equalToConstant: 33)
            heightConstraint.isActive = true
            widthConstraint.isActive = true
        }
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func openDrawer(){
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
    }
    //====================end function for setRightIcons======================

    
    @IBAction func buttonHandlerTabBar(_ sender: UIButton) {
        if sender.tag == 1{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC")as! HomeVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }else if sender.tag == 2{
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
    
    
    
    @IBAction func buttonChangePin(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
        nextVC.isFromSetting = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func switchPinLock(_ sender: UISwitch) {
        if sender.isOn{
            UserDefaults.standard.set(true, forKey: "isPinLock")
        }else{
            UserDefaults.standard.set(false, forKey: "isPinLock")
        }
    }
    
    @IBAction func switchOutgoinLock(_ sender: UISwitch) {
        if sender.isOn{
            
            // use the feature only available in iOS 9
            let alert = UIAlertController(title: "", message: "Please confirm that you want to lock all your outgoing bitcoin transactions. You can enable/disable it again anytime.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "CANCEL", style: .destructive) { (action) in
                self.switchLockOutGoingTransaction.isOn = false
            }
            
            let okAction = UIAlertAction(title: "CONFIRM", style: .default) { (action) in
                self.setUserSetting(val: "1", otp: "")
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        }else{
            self.setUserSetting(val: "0", otp: "")
        }
    }

    @IBAction func switchSound(_ sender: UISwitch) {
    }
    
    @IBAction func switchVibration(_ sender: UISwitch) {
    }
    
    
    
    func setUserSetting(val:String,otp:String){
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kUpdateUserSettings)
        
        let param = ["is_otp_on_transactions":val,"otp":otp]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let response_code = json.value(forKey: "response_code") as? Int{
                            if response_code == 613{
                                SVProgressHUD.dismiss()
                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC")as! VerifyCodeVC
                                nextVC.isFromOutGoing = true
                                self.navigationController?.pushViewController(nextVC, animated: true)
                            }else{
                                if let user = json.value(forKey: USER) as? NSDictionary{
                                    if let is_otp_on_transactions = user.value(forKey: IS_OTP_ON_TRANSACTION)as? Int{
                                        UserDefaults.standard.set(is_otp_on_transactions, forKey: IS_OTP_ON_TRANSACTION)
                                        if is_otp_on_transactions == 1{
                                            self.switchLockOutGoingTransaction.isOn = true
                                        }else{
                                            self.switchLockOutGoingTransaction.isOn = false
                                        }
                                    }
                                    self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
                                    SVProgressHUD.dismiss()
                                }
                            }
                        }
                    }else{
                        SVProgressHUD.dismiss()
                        self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
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
                        self.setUserSetting(val: val, otp: otp)
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
    }
    
    
    
    

}
