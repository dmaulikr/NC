//
//  SetupPINVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD


protocol SetupPINVCDelegate {
    func buyBitcoins(isPinVerify:Bool,type:String,otp:String)
}

protocol SetupPINVCDelegate1 {
    func createWithdraw(isPinVerify:Bool,otp:String)
}


class SetupPINVC: UIViewController,VerifyCodeVCDelegate {
    
    
    @IBOutlet weak var pinCodeField: NPPinCodeField!
    @IBOutlet weak var lblText: UILabel!
    
    @IBOutlet weak var mylabel: UILabel!
    var phoneNumber = String()
    var isPinSet = Int()
    var pincode = String()
    var isPinCodeEntered = false
    var isFromBuy = false
    var isFromSell = false
    var isLogin = false
    var isFromWithDrawWithOTP = ""
    var isFromSetting = false
    var isFromSend = false
    var isFromSendWithoutOTP = ""
    var isFromSetNewPassword = false
    var isName = false
    var isEmail = false
    var otp = ""
    var isPhoneNumber = false
    var isFrom = ""
    var isFromOutGoing = false
    var isFromBid = false
    var isFromAsk = false
    var delegate:SetupPINVCDelegate!
    var delegate1:SetupPINVCDelegate1!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var myGradient = UIImage(named: "text.png")
        lblText.textColor = UIColor(patternImage: myGradient ?? UIImage())
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        if self.isFromBuy || self.isFromSell || self.isFromWithDrawWithOTP == "false" || self.isFromSetting || self.isFrom != "" || self.isFromSend || self.isFromWithDrawWithOTP == "true" || self.isFromOutGoing || self.isFromBid || self.isFromAsk{
            lblTitle.text  = "CONFIRM PIN"
        }else{
            lblTitle.text  = "SETUP PIN"
        }
        
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //hide back button of navigation bar
        if self.isFromBuy || self.isFromSell || self.isFromSetting{
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
       else if self.isFrom != ""{
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
       else if self.isFromSend{
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
       else if self.isFromWithDrawWithOTP == "true"{
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
       else if self.isFromOutGoing{
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
       else if self.isFromBid{
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
       else if self.isFromAsk{
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        else{
            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        //open keyboard
        self.pinCodeField.becomeFirstResponder()


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        pinCodeField.resignFirstResponder()
    }
    

    @IBAction func pinCodeChanged(_ sender: NPPinCodeField) {
        
        if sender.isFilled {
            sender.resignFirstResponder()
            
            if self.isLogin{
                if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
                    self.login(number: number, pin: sender.text)
                }
            }else if self.isFromBuy{
                if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
                    self.checkPin(number: number, pin: sender.text)
                }
            }else if self.isFromSell{
                if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
                    self.checkPin(number: number, pin: sender.text)
                }
            }else if self.isFromWithDrawWithOTP == "false"{
                if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
                    self.checkPin(number: number, pin: sender.text)
                }
            }else if self.isFromWithDrawWithOTP == "true"{
                if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
                    self.checkPin(number: number, pin: sender.text)
                }
            }else if self.isFromSetting{
                if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
                    self.verifyPIN(number: number, pin: sender.text)
                }
            }else if self.isFromSendWithoutOTP == "false"{
                if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
                    self.checkPin(number: number, pin: sender.text)
                }
            }else if self.isFromSendWithoutOTP == "true"{
                if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
                    self.checkPin(number: number, pin: sender.text)
                }
            }else if self.isFrom != ""{
                if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
                    self.checkPin(number: number, pin: sender.text)
                }
            }else if self.isFromOutGoing{
                if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
                    self.checkPin(number: number, pin: sender.text)
                }
            }else if self.isFromBid{
                if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
                    self.checkPin(number: number, pin: sender.text)
                }
            }else if self.isFromAsk{
                if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
                    self.checkPin(number: number, pin: sender.text)
                }
            }else{
                if self.isPinSet == 0{
                    if !self.isPinCodeEntered{
                        self.pincode = sender.text
                        self.lblText.text = "Please confirm your 4 digit PIN"
                        self.pinCodeField.text = ""
                        self.isPinCodeEntered = true
                    }else{
                        if sender.text == self.pincode{
                            if self.isFromSetNewPassword{
                                self.changePIN(pin: sender.text)
                            }else{
                                self.setupPIN(pin: sender.text)
                            }
                        }else{
                            alert(title: "Pin did not match", msg: "Please try again..")
                            self.pincode = ""
                            self.lblText.text = "Please Enter your 4 digit PIN"
                            self.pinCodeField.text = ""
                            self.isPinCodeEntered = false
                        }
                    }
                }else{
                    self.login(number: phoneNumber, pin: sender.text)
                }
            }
        }
    }
    
    func setupPIN(pin:String){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kVerifyPin)
        let param = [PHONE_NUMBER:phoneNumber, PIN:pin]
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json[STATUS]as? Int{
                    if status == 1{
                        self.login(number: self.phoneNumber, pin: pin)
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
            SVProgressHUD.dismiss()
            print(error.localizedDescription)
            
        })
        
    }
    
    func changePIN(pin:String){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        var oldPIN = ""
        if UserDefaults.standard.value(forKey: PIN) != nil{
            oldPIN = "\(UserDefaults.standard.value(forKey: PIN)!)"
        }
        
        let url = kBaseUrl.appending(kChangePin)
        let param = ["otp":self.otp, "new_pin":pin,"current_pin":oldPIN]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json[STATUS]as? Int{
                    if status == 1{
                        SVProgressHUD.dismiss()
                        
                        DispatchQueue.main.async(execute: { 
                            // Post notification
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PinChanged"), object: nil)
                        })
                        
                        //setup drawer
                        let appDel = UIApplication.shared.delegate as! AppDelegate
                        appDel.DrawerSettings()
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
                        self.changePIN(pin: pin)
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
        
        view.endEditing(true)
        SVProgressHUD.show()
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let serializer = AFJSONRequestSerializer()
        serializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        serializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer = serializer
        
        let url = kBaseUrl.appending(kLogin)
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        let param = [PHONE_NUMBER:number, PINLOCK:pin, "device_unique_id":deviceID]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let user = json.value(forKey: USER) as? NSDictionary{
                            
                            if let account_holder_name = user.value(forKey: ACCOUNT_HOLDER_NAME)as? String{
                                UserDefaults.standard.set(account_holder_name, forKey: ACCOUNT_HOLDER_NAME)
                                print(account_holder_name)
                            }
                            
                            if let account_number = user.value(forKey: ACCOUNT_NUMBER)as? String{
                                UserDefaults.standard.set(account_number, forKey: ACCOUNT_NUMBER)
                                print(account_number)
                            }
                            
                            if let balance_btc = user.value(forKey: BALANCE_BTC)as? String
                            {
                            //    UserDefaults.standard.set(balance_btc, forKey: BALANCE_BTC)
                                UserDefaults.standard.set("0.108321", forKey: BALANCE_BTC)
                                print(balance_btc)
                            }
                            
                            if let balance_rs = user.value(forKey: BALANCE_RS)as? String{
                                UserDefaults.standard.set(balance_rs, forKey: BALANCE_RS)
                                print(balance_rs)
                            }
                            
                            if let bank_name = user.value(forKey: BANK_NAME)as? String{
                                UserDefaults.standard.set(bank_name, forKey: BANK_NAME)
                                print(bank_name)
                            }
                            
                            if let birthdate = user.value(forKey: BIRTHDATE)as? String{
                                UserDefaults.standard.set(birthdate, forKey: BIRTHDATE)
                                print(birthdate)
                            }
                            
                            if let branch_name = user.value(forKey: BRANCH_NAME)as? String{
                                UserDefaults.standard.set(branch_name, forKey: BRANCH_NAME)
                                print(branch_name)
                            }
                            
                            if let email = user.value(forKey: EMAIL)as? String{
                                UserDefaults.standard.set(email, forKey: EMAIL)
                                if email != ""{
                                    self.isEmail = true
                                }else{
                                    self.isEmail = false
                                }
                            }
                            
                            if let firstname = user.value(forKey: FIRSTNAME)as? String{
                                UserDefaults.standard.set(firstname, forKey: FIRSTNAME)
                                print(firstname)
                            }
                            
                            if let frozen_btc = user.value(forKey: FROZEN_BTC)as? String{
                                UserDefaults.standard.set(frozen_btc, forKey: FROZEN_BTC)
                                print(frozen_btc)
                            }
                            
                            if let gender = user.value(forKey: GENDER)as? String{
                                UserDefaults.standard.set(gender, forKey: GENDER)
                                print(gender)
                            }
                            
                            if let ifsc_code = user.value(forKey: IFSC_CODE)as? String{
                                UserDefaults.standard.set(ifsc_code, forKey: IFSC_CODE)
                                print(ifsc_code)
                            }
                            
                            if let is_active = user.value(forKey: IS_ACTIVE)as? Int{
                                UserDefaults.standard.set(is_active, forKey: IS_ACTIVE)
                                print(is_active)
                            }
                            
                            if let is_email_verified = user.value(forKey: IS_EMAIL_VERIFIED)as? Int{
                                UserDefaults.standard.set(is_email_verified, forKey: IS_EMAIL_VERIFIED)
                                print(is_email_verified)
                            }
                            
                            if let is_new_announcement = user.value(forKey: IS_NEW_ANNOUNCEMENT)as? Int{
                                UserDefaults.standard.set(is_new_announcement, forKey: IS_NEW_ANNOUNCEMENT)
                                print(is_new_announcement)
                            }
                            
                            if let is_otp_on_transactions = user.value(forKey: IS_OTP_ON_TRANSACTION)as? Int{
                                UserDefaults.standard.set(is_otp_on_transactions, forKey: IS_OTP_ON_TRANSACTION)
                                print(is_otp_on_transactions)
                            }
                            
                            if let is_phone_verified = user.value(forKey: IS_PHONE_VERIFIED)as? Int{
                                UserDefaults.standard.set(is_phone_verified, forKey: IS_PHONE_VERIFIED)
                                print(is_phone_verified)
                            }
                            
                            if let is_verified = user.value(forKey: IS_VERIFIED)as? Int{
                                UserDefaults.standard.set(is_verified, forKey: IS_VERIFIED)
                                print(is_verified)
                            }
                            
                            if let lastname = user.value(forKey: LASTNAME)as? String{
                                UserDefaults.standard.set(lastname, forKey: LASTNAME)
                                print(lastname)
                            }
                            
                            if let lock_btc = user.value(forKey: LOCK_BTC)as? Float{
                                UserDefaults.standard.set(lock_btc, forKey: LOCK_BTC)
                                print(lock_btc)
                            }
                            
                            if let lock_rs = user.value(forKey: LOCK_RS)as? String{
                                UserDefaults.standard.set(lock_rs, forKey: LOCK_RS)
                                print(lock_rs)
                            }
                            
                            if let name = user.value(forKey: NAME)as? String{
                                UserDefaults.standard.set(name, forKey: NAME)
                                if name != ""{
                                    self.isName = true
                                }else{
                                    self.isName = false
                                }
                                print(name)
                            }
                            
                            if let pan_card_no = user.value(forKey: PAN_CARD_NUMBER)as? String{
                                UserDefaults.standard.set(pan_card_no, forKey: PAN_CARD_NUMBER)
                                print(pan_card_no)
                            }
                            
                            if let pan_card_photo = user.value(forKey: PAN_CARD_PHOTO)as? String{
                                UserDefaults.standard.set(pan_card_photo, forKey: PAN_CARD_PHOTO)
                                print(pan_card_photo)
                            }
                            
                            if let phone_number = user.value(forKey: PHONE_NUMBER)as? String{
                                UserDefaults.standard.set(phone_number, forKey: PHONE_NUMBER)
                                print(phone_number)
                            }
                            
                            if let pin_tries = user.value(forKey: PIN_TRIES)as? Int{
                                UserDefaults.standard.set(pin_tries, forKey: PIN_TRIES)
                                print(pin_tries)
                            }
                            
                            if let profile_image = user.value(forKey: PROFILE_IMAGE)as? String{
                                UserDefaults.standard.set(profile_image, forKey: PROFILE_IMAGE)
                                print(profile_image)
                            }
                            
                            if let profile_image_url = user.value(forKey: PROFILE_IMAGE_URL)as? String{
                                UserDefaults.standard.set(profile_image_url, forKey: PROFILE_IMAGE_URL)
                            }
                            
                            if let withdraw_rs = user.value(forKey: WITHDRAW_RS)as? Int{
                                UserDefaults.standard.set(withdraw_rs, forKey: WITHDRAW_RS)
                                print(withdraw_rs)
                            }
                            
                            if let other_id_proof_no = user.value(forKey: OTHER_ID_PROOF_NO)as? String{
                                UserDefaults.standard.set(other_id_proof_no, forKey: OTHER_ID_PROOF_NO)
                                print(other_id_proof_no)
                            }
                            
                            if let other_id_proof_no_photo = user.value(forKey: OTHER_ID_PROOF_NO_PHOTO)as? String{
                                UserDefaults.standard.set(other_id_proof_no_photo, forKey: OTHER_ID_PROOF_NO_PHOTO)
                                print(other_id_proof_no_photo)
                            }
                            
                            if let tokenString = user.value(forKey: TOKEN) as? String{
                                UserDefaults.standard.set(tokenString, forKey: ACCESS_TOKEN)
                                print(tokenString)
                            }
                            
                            if let other_id_proof_no = user.value(forKey: OTHER_ID_PROOF_NO_PHOTO_2)as? String{
                                UserDefaults.standard.set(other_id_proof_no, forKey: OTHER_ID_PROOF_NO_PHOTO_2)
                                print(other_id_proof_no)
                            }
                            
                            if let other_id_proof_no_photo = user.value(forKey: OTHER_ID_PROOF_NO_PHOTO_2_URL)as? String{
                                UserDefaults.standard.set(other_id_proof_no_photo, forKey: OTHER_ID_PROOF_NO_PHOTO_2_URL)
                                print(other_id_proof_no_photo)
                            }
                            
                            
                            SVProgressHUD.dismiss()
                            UserDefaults.standard.set(true, forKey: IS_LOGIN)
                            UserDefaults.standard.set(pin, forKey: PIN)
                            
                            //Generate Token
                            //                            if UserDefaults.standard.value(forKey: ACCESS_TOKEN) == nil{
                            //                                let appDel = UIApplication.shared.delegate as! AppDelegate
                            //                                appDel.issuesUserAccessToken(number: number, pin: pin, completionHandler: { (isBool) in
                            //                                    if isBool {
                            //                                        print("token generated succeed..")
                            //                                    }
                            //                                })
                            //                            }
                            
                            
                            if !self.isName && !self.isEmail{
                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC")as! EditProfileVC
                                nextVC.isFromPin = true
                                self.navigationController?.pushViewController(nextVC, animated: true)
                            }else{
                                //setup drawer
                                let appDel = UIApplication.shared.delegate as! AppDelegate
                                appDel.DrawerSettings()
                            }
                        }
                        
                    }else{
                        SVProgressHUD.dismiss()
                        self.pinCodeField.text = ""
                        self.view.makeToast(json[MSG]as! String, duration: 3.0, position: .bottom)
                    }
                }
                
            } catch {
                SVProgressHUD.dismiss()
                alert(title: "Server didnt get any responding", msg: "Please try again")
                print("error getting string: \(error)")
            }
            
        }, failure: { (operation, error) in
            SVProgressHUD.dismiss()
            print(error.localizedDescription)
            
        })
        
//        view.endEditing(true)
//        SVProgressHUD.show()
//
//        let manager = AFHTTPSessionManager()
//        manager.requestSerializer = AFHTTPRequestSerializer()
//        manager.responseSerializer = AFHTTPResponseSerializer()
//
//        let serializer = AFJSONRequestSerializer()
//        serializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        serializer.setValue("application/json", forHTTPHeaderField: "Accept")
//        manager.requestSerializer = serializer
//
//        let url = kBaseUrl.appending(kLogin)
//        let param = [PHONE_NUMBER:number, PINLOCK:pin]
//
//        print(url)
//        print(param)
//
//        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
//
//            do{
//                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
//
//                print(json)
//
//                if let status = json.value(forKey: STATUS) as? Int{
//                    if status == 1{
//
//                        if let user = json.value(forKey: USER) as? NSDictionary{
//
//                            if let account_holder_name = user.value(forKey: ACCOUNT_HOLDER_NAME)as? String{
//                                UserDefaults.standard.set(account_holder_name, forKey: ACCOUNT_HOLDER_NAME)
//                            }
//
//                            if let account_number = user.value(forKey: ACCOUNT_NUMBER)as? String{
//                                UserDefaults.standard.set(account_number, forKey: ACCOUNT_NUMBER)
//                            }
//
//                            if let balance_btc = user.value(forKey: BALANCE_BTC)as? Float{
//                                UserDefaults.standard.set(balance_btc, forKey: BALANCE_BTC)
//                            }
//
//                            if let balance_rs = user.value(forKey: BALANCE_RS)as? Int{
//                                UserDefaults.standard.set(balance_rs, forKey: BALANCE_RS)
//                            }
//
//                            if let bank_name = user.value(forKey: BANK_NAME)as? String{
//                                UserDefaults.standard.set(bank_name, forKey: BANK_NAME)
//                            }
//
//                            if let birthdate = user.value(forKey: BIRTHDATE)as? String{
//                                UserDefaults.standard.set(birthdate, forKey: BIRTHDATE)
//                            }
//
//                            if let branch_name = user.value(forKey: BRANCH_NAME)as? String{
//                                UserDefaults.standard.set(branch_name, forKey: BRANCH_NAME)
//                            }
//
//                            if let email = user.value(forKey: EMAIL)as? String{
//                                UserDefaults.standard.set(email, forKey: EMAIL)
//                                if email != ""{
//                                    self.isEmail = true
//                                }else{
//                                    self.isEmail = false
//                                }
//                            }
//
//                            if let firstname = user.value(forKey: FIRSTNAME)as? String{
//                                UserDefaults.standard.set(firstname, forKey: FIRSTNAME)
//                            }
//
//                            if let frozen_btc = user.value(forKey: FROZEN_BTC)as? String{
//                                UserDefaults.standard.set(frozen_btc, forKey: FROZEN_BTC)
//                            }
//
//                            if let gender = user.value(forKey: GENDER)as? String{
//                                UserDefaults.standard.set(gender, forKey: GENDER)
//                            }
//
//                            if let ifsc_code = user.value(forKey: IFSC_CODE)as? String{
//                                UserDefaults.standard.set(ifsc_code, forKey: IFSC_CODE)
//                            }
//
//                            if let is_active = user.value(forKey: IS_ACTIVE)as? Int{
//                                UserDefaults.standard.set(is_active, forKey: IS_ACTIVE)
//                            }
//
//                            if let is_email_verified = user.value(forKey: IS_EMAIL_VERIFIED)as? Int{
//                                UserDefaults.standard.set(is_email_verified, forKey: IS_EMAIL_VERIFIED)
//                            }
//
//                            if let is_new_announcement = user.value(forKey: IS_NEW_ANNOUNCEMENT)as? Int{
//                                UserDefaults.standard.set(is_new_announcement, forKey: IS_NEW_ANNOUNCEMENT)
//                            }
//
//                            if let is_otp_on_transactions = user.value(forKey: IS_OTP_ON_TRANSACTION)as? Int{
//                                UserDefaults.standard.set(is_otp_on_transactions, forKey: IS_OTP_ON_TRANSACTION)
//                            }
//
//                            if let is_phone_verified = user.value(forKey: IS_PHONE_VERIFIED)as? Int{
//                                UserDefaults.standard.set(is_phone_verified, forKey: IS_PHONE_VERIFIED)
//                            }
//
//                            if let is_verified = user.value(forKey: IS_VERIFIED)as? Int{
//                                UserDefaults.standard.set(is_verified, forKey: IS_VERIFIED)
//                            }
//
//                            if let lastname = user.value(forKey: LASTNAME)as? String{
//                                UserDefaults.standard.set(lastname, forKey: LASTNAME)
//                            }
//
//                            if let lock_btc = user.value(forKey: LOCK_BTC)as? String{
//                                UserDefaults.standard.set(lock_btc, forKey: LOCK_BTC)
//                            }
//
//                            if let lock_rs = user.value(forKey: LOCK_RS)as? Int{
//                                UserDefaults.standard.set(lock_rs, forKey: LOCK_RS)
//                            }
//
//                            if let name = user.value(forKey: NAME)as? String{
//                                UserDefaults.standard.set(name, forKey: NAME)
//                                if name != ""{
//                                    self.isName = true
//                                }else{
//                                    self.isName = false
//                                }
//                            }
//
//                            if let pan_card_no = user.value(forKey: PAN_CARD_NUMBER)as? String{
//                                UserDefaults.standard.set(pan_card_no, forKey: PAN_CARD_NUMBER)
//                            }
//
//                            if let pan_card_photo = user.value(forKey: PAN_CARD_PHOTO)as? String{
//                                UserDefaults.standard.set(pan_card_photo, forKey: PAN_CARD_PHOTO)
//                            }
//
//                            if let phone_number = user.value(forKey: PHONE_NUMBER)as? String{
//                                UserDefaults.standard.set(phone_number, forKey: PHONE_NUMBER)
//                            }
//
//                            if let pin_tries = user.value(forKey: PIN_TRIES)as? Int{
//                                UserDefaults.standard.set(pin_tries, forKey: PIN_TRIES)
//                            }
//
//                            if let profile_image = user.value(forKey: PROFILE_IMAGE)as? String{
//                                UserDefaults.standard.set(profile_image, forKey: PROFILE_IMAGE)
//                            }
//
//                            if let profile_image_url = user.value(forKey: PROFILE_IMAGE_URL)as? String{
//                                UserDefaults.standard.set(profile_image_url, forKey: PROFILE_IMAGE_URL)
//                            }
//
//                            if let withdraw_rs = user.value(forKey: WITHDRAW_RS)as? Int{
//                                UserDefaults.standard.set(withdraw_rs, forKey: WITHDRAW_RS)
//                            }
//
//                            if let other_id_proof_no = user.value(forKey: OTHER_ID_PROOF_NO)as? String{
//                                UserDefaults.standard.set(other_id_proof_no, forKey: OTHER_ID_PROOF_NO)
//                            }
//
//                            if let other_id_proof_no_photo = user.value(forKey: OTHER_ID_PROOF_NO_PHOTO)as? String{
//                                UserDefaults.standard.set(other_id_proof_no_photo, forKey: OTHER_ID_PROOF_NO_PHOTO)
//                            }
//
//                            if let other_id_proof_no = user.value(forKey: OTHER_ID_PROOF_NO_PHOTO_2)as? String{
//                                UserDefaults.standard.set(other_id_proof_no, forKey: OTHER_ID_PROOF_NO_PHOTO_2)
//                            }
//
//                            if let other_id_proof_no_photo = user.value(forKey: OTHER_ID_PROOF_NO_PHOTO_2_URL)as? String{
//                                UserDefaults.standard.set(other_id_proof_no_photo, forKey: OTHER_ID_PROOF_NO_PHOTO_2_URL)
//                            }
//
//                            if let tokenString = user.value(forKey: TOKEN) as? String{
//                                UserDefaults.standard.set(tokenString, forKey: ACCESS_TOKEN)
//                                print(tokenString)
//                            }
//
//                            SVProgressHUD.dismiss()
//                            UserDefaults.standard.set(true, forKey: IS_LOGIN)
//                            UserDefaults.standard.set(pin, forKey: PIN)
//
////                            //Generate Token
////                            if UserDefaults.standard.value(forKey: ACCESS_TOKEN) == nil{
////                                let appDel = UIApplication.shared.delegate as! AppDelegate
////                                appDel.issuesUserAccessToken(number: number, pin: pin, completionHandler: { (isBool) in
////                                    if isBool {
////                                        print("token generated succeed..")
////                                    }
////                                })
////                            }
//
//                            if !self.isName && !self.isEmail{
//                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC")as! EditProfileVC
//                                nextVC.isFromPin = true
//                                self.navigationController?.pushViewController(nextVC, animated: true)
//                            }else{
//                                //setup drawer
//                                let appDel = UIApplication.shared.delegate as! AppDelegate
//                                appDel.DrawerSettings()
//                            }
//                        }
//
//                    }else{
//                        SVProgressHUD.dismiss()
//                        self.pinCodeField.text = ""
//                        self.view.makeToast(json[MSG]as! String, duration: 3.0, position: .bottom)
//                    }
//                }
//
//            } catch {
//                SVProgressHUD.dismiss()
//                alert(title: "Server didnt get any responding", msg: "Please try again")
//                print("error getting string: \(error)")
//            }
//
//        }, failure: { (operation, error) in
//            SVProgressHUD.dismiss()
//            print(error.localizedDescription)
//        })
    }
    
    
    func checkPin(number:String,pin:String){
        
        SVProgressHUD.show()
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let serializer = AFJSONRequestSerializer()
        serializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        serializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer = serializer
        
        let url = kBaseUrl.appending(kLogin)
        let param = [PHONE_NUMBER:number, PINLOCK:pin]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        if self.isFromBuy || self.isFromSell{
                            _ = self.navigationController?.popViewController(animated: true)
                            self.delegate.buyBitcoins(isPinVerify: true, type: self.isFromBuy == true ? "Buy" : "Sell", otp: "")
                        }else if self.isFromWithDrawWithOTP == "false"{
                            _ = self.navigationController?.popToRootViewController(animated: true)
                            self.delegate1.createWithdraw(isPinVerify: true, otp: "")
                        }else if self.isFromWithDrawWithOTP == "true"{
                            
                            // post a notification
                            let dic = ["otp": self.otp]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "withdraw"), object: nil, userInfo: dic)
                            
                            _ = self.navigationController?.popToRootViewController(animated: true)
                            
                        }else if self.isFromSendWithoutOTP == "true"{
                            _ = self.navigationController?.popViewController(animated: true)
                            // post a notification
                            let dic = ["otp": "","isPhoneNumber":self.isPhoneNumber] as [String : Any]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendBitCoin"), object: nil, userInfo: dic)
                        }else if self.isFromSendWithoutOTP == "false"{
                            // post a notification
                            let dic = ["otp": self.otp,"isPhoneNumber":self.isPhoneNumber] as [String : Any]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendBitCoin"), object: nil, userInfo: dic)
                            
                            _ = self.navigationController?.popToViewController((self.navigationController?.viewControllers[2])!, animated: true)
                            
                        }else if self.isFrom != ""{
                            // post a notification
                            let dic = ["otp": self.otp,"type":self.isFrom]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "buysell"), object: nil, userInfo: dic)
                            
                            _ = self.navigationController?.popToRootViewController(animated: true)
                        }else if self.isFromOutGoing{
                            // post a notification
                            let dic = ["otp": self.otp]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OutGoingTransaction"), object: nil, userInfo: dic)
                            
                            _ = self.navigationController?.popToRootViewController(animated: true)
                        }else if self.isFromBid{
                            // post a notification
                            let dic = ["otp": self.otp]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bid"), object: nil, userInfo: dic)
                            
                            _ = self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                            
                           // _ = self.navigationController?.popToRootViewController(animated: true)
                        }else if self.isFromAsk{
                            // post a notification
                            let dic = ["otp": self.otp]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ask"), object: nil, userInfo: dic)
                            
                            _ = self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                            
                           // _ = self.navigationController?.popToRootViewController(animated: true)
                        }
                    }else{
                        SVProgressHUD.dismiss()
                        self.pinCodeField.text = ""
                        self.pinCodeField.becomeFirstResponder()
                        alert(title: "", msg: json[MSG]as! String)
                    }
                }
                
            } catch {
                SVProgressHUD.dismiss()
                alert(title: "Server didnt get any responding", msg: "Please try again")
                print("error getting string: \(error)")
            }
            
        }, failure: { (operation, error) in
            SVProgressHUD.dismiss()
            print(error.localizedDescription)
            
        })
        
    }
    
    func checkPinTrans(number:String,pin:String){
        
        SVProgressHUD.show()
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        var access_token = ""
        if UserDefaults.standard.value(forKey: ACCESS_TOKEN) != nil{
            access_token = "\(UserDefaults.standard.value(forKey: ACCESS_TOKEN)!)"
        }
        
        var token_type = ""
        if UserDefaults.standard.value(forKey: TOKEN_TYPE) != nil{
            token_type = "\(UserDefaults.standard.value(forKey: TOKEN_TYPE)!)"
        }
        
        let token = "\(token_type) \(access_token)"
        
        let serializer = AFJSONRequestSerializer()
        serializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        serializer.setValue("application/json", forHTTPHeaderField: "Accept")
        serializer.setValue(token, forHTTPHeaderField: "Authorization")
        manager.requestSerializer = serializer
        
        let url = kBaseUrl.appending(ktxnVerifyCurrentPin)
        let param = [PINLOCK:pin]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        if self.isFromBuy || self.isFromSell{
                            _ = self.navigationController?.popViewController(animated: true)
                            self.delegate.buyBitcoins(isPinVerify: true, type: self.isFromBuy == true ? "Buy" : "Sell", otp: "")
                        }else if self.isFromWithDrawWithOTP == "false"{
                            _ = self.navigationController?.popToRootViewController(animated: true)
                            self.delegate1.createWithdraw(isPinVerify: true, otp: "")
                        }else if self.isFromWithDrawWithOTP == "true"{
                            
                            // post a notification
                            let dic = ["otp": self.otp]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "withdraw"), object: nil, userInfo: dic)
                            
                            _ = self.navigationController?.popToRootViewController(animated: true)
                            
                        }else if self.isFromSendWithoutOTP == "true"{
                            _ = self.navigationController?.popViewController(animated: true)
                            // post a notification
                            let dic = ["otp": "","isPhoneNumber":self.isPhoneNumber] as [String : Any]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendBitCoin"), object: nil, userInfo: dic)
                        }else if self.isFromSendWithoutOTP == "false"{
                            // post a notification
                            let dic = ["otp": self.otp,"isPhoneNumber":self.isPhoneNumber] as [String : Any]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendBitCoin"), object: nil, userInfo: dic)
                            
                            _ = self.navigationController?.popToViewController((self.navigationController?.viewControllers[2])!, animated: true)
                            
                        }else if self.isFrom != ""{
                            // post a notification
                            let dic = ["otp": self.otp,"type":self.isFrom]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "buysell"), object: nil, userInfo: dic)
                            
                            _ = self.navigationController?.popToRootViewController(animated: true)
                        }else if self.isFromOutGoing{
                            // post a notification
                            let dic = ["otp": self.otp]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OutGoingTransaction"), object: nil, userInfo: dic)
                            
                            _ = self.navigationController?.popToRootViewController(animated: true)
                        }else if self.isFromBid{
                            // post a notification
                            let dic = ["otp": self.otp]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bid"), object: nil, userInfo: dic)
                            
                            _ = self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                            
                            // _ = self.navigationController?.popToRootViewController(animated: true)
                        }else if self.isFromAsk{
                            // post a notification
                            let dic = ["otp": self.otp]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ask"), object: nil, userInfo: dic)
                            
                            _ = self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                            
                            // _ = self.navigationController?.popToRootViewController(animated: true)
                        }
                    }else{
                        SVProgressHUD.dismiss()
                        self.pinCodeField.text = ""
                        self.pinCodeField.becomeFirstResponder()
                        alert(title: "", msg: json[MSG]as! String)
                    }
                }
                
            } catch {
                SVProgressHUD.dismiss()
                alert(title: "Server didnt get any responding", msg: "Please try again")
                print("error getting string: \(error)")
            }
            
        }, failure: { (operation, error) in
            SVProgressHUD.dismiss()
            print(error.localizedDescription)
            
        })
        
    }
    
    func verifyPIN(number:String,pin:String){
        
        SVProgressHUD.show()
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let serializer = AFJSONRequestSerializer()
        serializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        serializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer = serializer
        
        let url = kBaseUrl.appending(kLogin)
        let param = [PHONE_NUMBER:number, PINLOCK:pin]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        SVProgressHUD.dismiss()
                        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC")as! VerifyCodeVC
                        nextVC.phoneNumber = number
                        nextVC.isFromSetting = true
                        self.navigationController?.pushViewController(nextVC, animated: true)
                        
                    }else{
                        SVProgressHUD.dismiss()
                        self.pinCodeField.text = ""
                        self.pinCodeField.becomeFirstResponder()
                        alert(title: "", msg: json[MSG]as! String)
                    }
                }
                
            } catch {
                SVProgressHUD.dismiss()
                alert(title: "Server didnt get any responding", msg: "Please try again")
                print("error getting string: \(error)")
            }
            
        }, failure: { (operation, error) in
            SVProgressHUD.dismiss()
            print(error.localizedDescription)
            
        })
        
    }
    
    
    
    @IBAction func buttonForgotPin(_ sender: Any) {
        view.endEditing(true)
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC")as! VerifyCodeVC
        nextVC.isFromForgotPin = true
        nextVC.delegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func showForgotPinMsg(msg:String){
        self.view.makeToast(msg, duration: 10.0, position: .bottom)
    }
    

}
