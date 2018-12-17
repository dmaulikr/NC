//
//  VerifyCodeVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD
import MBCircularProgressBar


protocol VerifyCodeVCDelegate {
    func showForgotPinMsg(msg:String)
}


class VerifyCodeVC: UIViewController {
    
    
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var txtVerificationCodeView: UIView!
    @IBOutlet weak var txtVerificationCode: UITextField!
    @IBOutlet weak var btnVerify: UIButton!
    
    
    @IBOutlet weak var timerView: MBCircularProgressBarView!
    @IBOutlet weak var lblSeconds: UILabel!
    @IBOutlet weak var btnResend: UIButton!
    
    var delegate:VerifyCodeVCDelegate!
    
    var phoneNumber = String()
    var otp = ""
    
    var timer = Timer()
    var val = 0
    
    var isFromSetting = false
    var isFromForgotPin = false
    var isFromSend = false
    var isFrom = ""
    var isFromWithDraw = false
    var isFromOutGoing = false
    var isFromSendWithoutOTP = false
    var isPhoneNumber = false
    var isFromBid = false
    var isFromAsk = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "ENTER VERIFICATION CODE"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        if !self.isFromForgotPin && !self.isFromSetting{
            //hide back button of navigation bar
            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        
        btnResend.layer.cornerRadius = 10
        btnResend.layer.borderWidth = 1
        btnResend.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        btnVerify.layer.cornerRadius = 10
        btnVerify.layer.borderWidth = 1
        btnVerify.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        if self.isFromSend{
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
        if self.isFrom != ""{
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
        if self.isFromWithDraw{
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
        if self.isFromOutGoing{
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
        if self.isFromBid{
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
        if self.isFromAsk{
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
        
        //set corner radious to textField view
        setCornerRadiouToView(viewName:self.txtVerificationCodeView)
        
        //set phoneNumber to lbl
        self.lblText.text = "Waiting to automatically detect SMS of 6 digit verification code sent to \(self.phoneNumber)"
        
        
        if self.isFromSetting{
            self.setupTimer()
            self.sentOTP(number: phoneNumber)
        }
        
        if self.phoneNumber == "9429149530"{
            self.verify(otp: self.otp)
        }else{
            self.setupTimer()
        }
        
        if self.isFromForgotPin{
            if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
                self.sentOTP(number: number)
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    func setupTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(VerifyCodeVC.updateTimer)), userInfo: nil, repeats: true)
        self.btnResend.isUserInteractionEnabled = false
        self.btnResend.setTitleColor(UIColor.gray, for: .normal)
    }
    
    @objc func updateTimer() {
        self.val += 1
        if val > 60{
            self.val = 0
            self.timer.invalidate()
            self.timerView.value = 0
            self.lblSeconds.text = "00"
            self.btnResend.isUserInteractionEnabled = true
            self.btnResend.setTitleColor(UIColor.init(hexString: "FFD700"), for: .normal)
        }else{
            let percent = Double(self.val) / Double(60)
            self.timerView.value = CGFloat(percent * 100)
            let finalVal = 60 - self.val
            self.lblSeconds.text = String(finalVal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func buttonVerify(_ sender: UIButton) {
        
        //hide keyboard
        self.view.endEditing(true)
        
        if self.txtVerificationCode.text!.isEmpty{
            alert(title: "", msg: "Enter verification code")
        }else{
            if self.isFromSetting{
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
                nextVC.isFromSetNewPassword = true
                nextVC.phoneNumber = self.phoneNumber
                nextVC.otp = self.txtVerificationCode.text!
                self.navigationController?.pushViewController(nextVC, animated: true)
            }else if self.isFromForgotPin{
                self.verifyForgotOTP()
            }else if self.isFromSend{
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
                nextVC.isFromSend = true
                nextVC.isPhoneNumber = self.isPhoneNumber
                nextVC.isFromSendWithoutOTP = self.isFromSendWithoutOTP == true ? "true" : "false"
                nextVC.otp = self.txtVerificationCode.text!
                self.navigationController?.pushViewController(nextVC, animated: true)
            }else if self.isFrom == "Buy"{
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
                nextVC.isFrom = "Buy"
                nextVC.otp = self.txtVerificationCode.text!
                self.navigationController?.pushViewController(nextVC, animated: true)
            }else if self.isFrom == "Sell"{
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
                nextVC.isFrom = "Sell"
                nextVC.otp = self.txtVerificationCode.text!
                self.navigationController?.pushViewController(nextVC, animated: true)
            }else if self.isFromWithDraw{
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
                nextVC.isFromWithDrawWithOTP = "true"
                nextVC.otp = self.txtVerificationCode.text!
                self.navigationController?.pushViewController(nextVC, animated: true)
            }else if self.isFromOutGoing{
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
                nextVC.isFromOutGoing = true
                nextVC.otp = self.txtVerificationCode.text!
                self.navigationController?.pushViewController(nextVC, animated: true)
            }else if self.isFromBid{
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
                nextVC.isFromBid = true
                nextVC.otp = self.txtVerificationCode.text!
                self.navigationController?.pushViewController(nextVC, animated: true)
            }else if self.isFromAsk{
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
                nextVC.isFromAsk = true
                nextVC.otp = self.txtVerificationCode.text!
                self.navigationController?.pushViewController(nextVC, animated: true)
            }else{
                self.verify(otp: self.txtVerificationCode.text!)
            }
        }
        
    }
    
    func verify(otp:String){
        
        SVProgressHUD.show()
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let serializer = AFJSONRequestSerializer()
        serializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        serializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer = serializer
        
        let url = kBaseUrl.appending(kVerifyOTP)
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        let param = [PHONE_NUMBER:self.phoneNumber,OTP:otp]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json[STATUS]as? Int{
                    if status == 1{
                        
                        
                        SVProgressHUD.dismiss()
                        
                        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCompleteVC")as! VerifyCompleteVC
                        nextVC.phoneNumber = self.phoneNumber
                        nextVC.isPinSet = json[IS_PIN_SET]as! Int
                        self.navigationController?.pushViewController(nextVC, animated: true)
                        
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
    
    func verifyForgotOTP(){
        view.endEditing(true)
        
        SVProgressHUD.show()
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let serializer = AFJSONRequestSerializer()
        serializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        serializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer = serializer
        
        var num = ""
        if let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
            num = number
        }

        
        let url = kBaseUrl.appending(kForgotPin)
        let param = ["phone_number":num,"otp":self.txtVerificationCode.text!]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json[STATUS]as? Int{
                    if status == 1{
                        
                        SVProgressHUD.dismiss()
                        self.delegate.showForgotPinMsg(msg: json[MSG]as! String)
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    }else{
                        SVProgressHUD.dismiss()
                        self.view.makeToast(json[MSG]as! String, duration: 2.0, position: .bottom)
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
    
    
    @IBAction func buttonResendOTP(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let serializer = AFJSONRequestSerializer()
        serializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        serializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer = serializer
        
        let url = kBaseUrl.appending(kResendOTP)
        let param = [PHONE_NUMBER:UserDefaults.standard.value(forKey: PHONE_NUMBER)as! String]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json[STATUS]as? Int{
                    if status == 1{
                        
                        SVProgressHUD.dismiss()
                        self.view.makeToast(json[MSG]as! String, duration: 2.0, position: .bottom)
                        
                        DispatchQueue.main.async(execute: {
                            self.setupTimer()
                        })
                        
                    }else{
                        SVProgressHUD.dismiss()
                        self.view.makeToast(json[MSG]as! String, duration: 2.0, position: .bottom)
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
    
    
    
    
    func sentOTP(number:String){
                
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let serializer = AFJSONRequestSerializer()
        serializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        serializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer = serializer
        
        let url = kBaseUrl.appending(kForgotPin)
        let param = [PHONE_NUMBER:number]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json[STATUS]as? Int{
                    if status == 1{
                        
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
    
    
    

}
