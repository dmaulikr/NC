//
//  DepositeAndWithdrawVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import SVProgressHUD
import AFNetworking


protocol DepositeAndWithdrawVCDelegate {
    func showToast(msg:String)
}

class DepositeAndWithdrawVC: UIViewController,SetupPINVCDelegate1,UITextFieldDelegate {

    var navigationTitle = ""
    
    var arrayOfWithdrawFees = NSMutableArray()
    
    @IBOutlet weak var lblFees: UILabel!
    var feesValue = ""
    
    @IBOutlet weak var lblDepositeBalance: UILabel!
    @IBOutlet weak var txtDepositeEnterAmount: UITextField!
    
    @IBOutlet weak var depositeView: UIView!
    @IBOutlet weak var withdrawView: UIView!
    
    @IBOutlet weak var lblWithdrawbalance: UILabel!
    @IBOutlet weak var txtWithdrawEnterAmount: UITextField!
    @IBOutlet weak var lblDepositeValidate: UILabel!
    @IBOutlet weak var lblWithdrawValidate: UILabel!
    @IBOutlet weak var lblLockedForBid: UILabel!
    @IBOutlet weak var lblLocked: UILabel!
    
    
    
    @IBOutlet weak var btnPaytm: UIButton!
    @IBOutlet weak var btnBankDeposit: UIButton!
    @IBOutlet weak var btnWithdraw: UIButton!
    var delegate:DepositeAndWithdrawVCDelegate!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = navigationTitle
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //set RightBar button icon
        self.setRightIcon()
        
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = ""
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButtonItem
        
        btnWithdraw.layer.cornerRadius = 10
        btnWithdraw.layer.borderWidth = 0.5
        btnWithdraw.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        btnBankDeposit.layer.cornerRadius = 10
        btnBankDeposit.layer.borderWidth = 0.5
        btnBankDeposit.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        btnPaytm.layer.cornerRadius = 10
        btnPaytm.layer.borderWidth = 0.5
        btnPaytm.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        //set textField Placeholder color
        setWhiteTextFieldPlaceHolderColor(txtName: self.txtDepositeEnterAmount, placeHolderText: "Enter Amount")
        setWhiteTextFieldPlaceHolderColor(txtName: self.txtWithdrawEnterAmount, placeHolderText: "Enter Amount")
        
        if navigationTitle == "DEPOSIT MONEY"{
            self.depositeView.isHidden = false
            self.withdrawView.isHidden = true
            
            self.lblDepositeValidate.text = "(Bank deposit - min: ₹ \(min_bank_deposit_amount), max: ₹ \(max_bank_deposit_amount))\n(PayUMoney - min: ₹ \(min_PayU_deposit_amount), max: ₹ \(max_PayU_deposit_amount))"
            
        }else{
            self.depositeView.isHidden = true
            self.withdrawView.isHidden = false
            
            if let account_number = UserDefaults.standard.value(forKey: ACCOUNT_NUMBER)as? String{
                self.lblWithdrawValidate.text = "Pay to bank account : \(account_number)\n\n(Withdraw - min: ₹ \(min_withdraw_amount), max: ₹ \(max_withdraw_amount))"
            }
        }
        
        if let balanceValue = UserDefaults.standard.value(forKey: BALANCE_RS)as? String{
            self.lblDepositeBalance.text = "₹ \(balanceValue)"
            self.lblWithdrawbalance.text = "₹ \(balanceValue)"
        }
        
        if let lock_rs = UserDefaults.standard.value(forKey: LOCK_RS)as? String{
            self.lblLockedForBid.text = "₹ \(lock_rs) (locked for bid orders)"
            self.lblLocked.text = "₹ \(lock_rs) (locked for bid orders)"
        }else{
            if let lock_rs = UserDefaults.standard.value(forKey: LOCK_RS)as? Int{
                self.lblLockedForBid.text = "₹ \(lock_rs) (locked for bid orders)"
                self.lblLocked.text = "₹ \(lock_rs) (locked for bid orders)"
            }
        }
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(DepositeAndWithdrawVC.socketData), name: Notification.Name(SOCKET_DATA), object: nil)
        
        self.txtWithdrawEnterAmount.delegate = self
        
       // self.getWithdrawFees()
        
        
        // Register to receive notification for deposite cancel
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "withdraw"), object: nil)
        
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
                self.createWithdraw(isPinVerify: true , otp: str)
            }
        }
    }
    
    @objc func socketData(){
        
        self.lblDepositeValidate.text = "(Bank deposit - min: ₹ \(min_bank_deposit_amount), max: ₹ \(max_bank_deposit_amount))\n(PayUMoney - min: ₹ \(min_PayU_deposit_amount), max: ₹ \(max_PayU_deposit_amount))"
        
        if let account_number = UserDefaults.standard.value(forKey: ACCOUNT_NUMBER)as? String{
            self.lblWithdrawValidate.text = "Pay to bank account : \(account_number)\n\n(Withdraw - min: ₹ \(min_withdraw_amount), max: ₹ \(max_withdraw_amount))"
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
        button.addTarget(self, action: #selector(DepositeAndWithdrawVC.openDrawer), for: UIControlEvents.touchUpInside)
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
    }
    
    @objc func openDrawer(){
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
    }
    //====================end function for setRightIcons======================
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        let components = newString.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
        
        let decimalString = components.joined(separator: "") as NSString
        let decimalStrLength = decimalString.length
        let hasLeadingOne = decimalStrLength > 0 && decimalString.character(at: 0) == (1 as unichar)
        
        if decimalStrLength == 0 || (decimalStrLength > 15 && !hasLeadingOne) || decimalStrLength > 15
        {
            let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
            self.lblFees.text = "(Fees 0)"
            self.feesValue = "0"
            return (newLength > 15) ? false : true
        }
        print(self.arrayOfWithdrawFees)
        if newString != ""{
            for i in 0..<self.arrayOfWithdrawFees.count{
                let json = self.arrayOfWithdrawFees.object(at: i)as! NSDictionary
                
                let rate_from = json.value(forKey: "rate_from")as! Int
                let rate_to = json.value(forKey: "rate_to")as! Int
                let fee = json.value(forKey: "fee")as! Int
                
                let lastJson = self.arrayOfWithdrawFees.lastObject as! NSDictionary
                let lastVal = lastJson.value(forKey: "rate_to")as! Int
                let lastfee = lastJson.value(forKey: "fee")as! Int

                let val = Int(newString)!
                
                if val >= rate_from && val <= rate_to{
                    self.lblFees.text = "(Fees ₹ \(fee))"
                    self.feesValue = "\(fee)"
                    break
                }
                
                if val >= lastVal{
                    self.lblFees.text = "(Fees ₹ \(lastfee))"
                    self.feesValue = "\(lastfee)"
                }
            }
        }
        
        return true
    }
    
    @IBAction func buttonDeposite(_ sender: Any) {
        view.endEditing(true)
        if let isVerified = UserDefaults.standard.value(forKey: IS_VERIFIED)as? Int{
            if isVerified == 1{
                if txtDepositeEnterAmount.text!.isEmpty{
                    self.view.makeToast("Please enter valid amount", duration: 2.0, position: .bottom)
                }else if Int(txtDepositeEnterAmount.text!)! < Int(min_bank_deposit_amount)!{
                    self.view.makeToast("Minimum amount to Bank Deposit is \(min_bank_deposit_amount)", duration: 2.0, position: .bottom)
                }else if Double(txtDepositeEnterAmount.text!)! > Double(max_bank_deposit_amount)!{
                    self.view.makeToast("Maximum amount to Bank Deposit is \(max_bank_deposit_amount)", duration: 2.0, position: .bottom)
                }else{
                    let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "BankAndPayUDepositeVC")as! BankAndPaytmDepositeVC
                    nextVC.type = "Bank"
                    nextVC.isFromDepositeAndWithdrawVC = true
                    nextVC.depositAmount = txtDepositeEnterAmount.text!
                    navigationController?.pushViewController(nextVC, animated: true)
                }
            }else{
                self.view.makeToast("Please verify your account!", duration: 2.0, position: .bottom)
            }
        }          
    }
    
    @IBAction func buttonPaytm(_ sender: Any) {
        view.endEditing(true)
        if let isVerified = UserDefaults.standard.value(forKey: IS_VERIFIED)as? Int{
            if isVerified == 1{
                if txtDepositeEnterAmount.text!.isEmpty{
                    self.view.makeToast("Please enter valid amount", duration: 2.0, position: .bottom)
                }else if Int(txtDepositeEnterAmount.text!)! < Int(min_PayU_deposit_amount)!{
                    self.view.makeToast("Minimum amount to PayU Deposit is \(min_PayU_deposit_amount)", duration: 2.0, position: .bottom)
                }else if Int(txtDepositeEnterAmount.text!)! > Int(max_PayU_deposit_amount)!{
                    self.view.makeToast("Maximum amount to Bank Deposit is \(max_PayU_deposit_amount)", duration: 2.0, position: .bottom)
                }else{
                    let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "BankAndPayUDepositeVC")as! BankAndPaytmDepositeVC
                    nextVC.type = "PayU"
                    nextVC.isFromDepositeAndWithdrawVC = true
                    nextVC.depositAmount = txtDepositeEnterAmount.text!
                    navigationController?.pushViewController(nextVC, animated: true)
                }
            }else{
                self.view.makeToast("Please verify your account!", duration: 2.0, position: .bottom)
            }
        }
    }
    
    @IBAction func buttonWithdraw(_ sender: Any) {
        view.endEditing(true)
        
        if is_maintenance_mode == "1"{
            alert(title: BodyTitle, msg: subTitle)
        }else{
            
            if let isVerified = UserDefaults.standard.value(forKey: IS_VERIFIED)as? Int{
                if isVerified == 1{
                    if let inrPrice = UserDefaults.standard.value(forKey: BALANCE_RS)as? String{
                        print(inrPrice)
                        let inr = Double(inrPrice)!
                        print(inr)
                        print(txtWithdrawEnterAmount.text!)
                        print(min_withdraw_amount)
                        
                    if txtWithdrawEnterAmount.text!.isEmpty{
                        self.view.makeToast("Please enter valid amount", duration: 2.0, position: .bottom)
                    }else if Double(txtWithdrawEnterAmount.text!)! < Double(min_withdraw_amount)!{
                        self.view.makeToast("Minimum amount to Withdraw is \(min_withdraw_amount)", duration: 2.0, position: .bottom)
                    }else if Int(txtWithdrawEnterAmount.text!)! > Int(max_withdraw_amount)!{
                        self.view.makeToast("Maximum amount to Withdraw is \(max_withdraw_amount)", duration: 2.0, position: .bottom)
                    }else if Double(txtWithdrawEnterAmount.text!)! > inr{
                        self.view.makeToast("Withdraw amount cannot be greater then available balance.", duration: 2.0, position: .bottom)
                    }else{
                        
                        if let isOTP = UserDefaults.standard.value(forKey: IS_OTP_ON_TRANSACTION)as? Int{
                            if isOTP == 0{
                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
                                nextVC.isFromWithDrawWithOTP = "false"
                                nextVC.delegate1 = self
                                navigationController?.pushViewController(nextVC, animated: true)
                            }else{
                                //code
                                self.createWithdraw(isPinVerify: true , otp: "")
                            }
                        }
                    }
                    }}else{
                    self.view.makeToast("Please verify your account!", duration: 2.0, position: .bottom)
                }
            }
        }
    }
    
    
    
    
    
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
    
    
    
    
    
    func createWithdraw(isPinVerify:Bool,otp:String){
        if isPinVerify{
            
            SVProgressHUD.show()
            
            let manager = sessionManager()
            
            let url = kBaseUrl.appending(kCreateWithdraw)
            let param = ["txnAmount":self.txtWithdrawEnterAmount.text!,"otp":otp]
            
            print(url)
            print(param)
            
            manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
                
                do{
                    let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                    
                    print(json)
                    SVProgressHUD.dismiss()
                    if let status = json[STATUS]as? Int{
                        if status == 1{
                        
                            self.view.makeToast(json.value(forKey: MSG) as? String, duration: 2.0, position: .bottom)
                            
                            if let response_code = json.value(forKey: "response_code") as? Int{
                                if response_code == 612{
                                    SVProgressHUD.dismiss()
                                    let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC")as! VerifyCodeVC
                                    nextVC.isFromWithDraw = true
                                    self.navigationController?.pushViewController(nextVC, animated: true)
                                    
                                }else{
                                    if let user = json.value(forKey: USER) as? NSDictionary{
                                        
                                        if let account_holder_name = user.value(forKey: ACCOUNT_HOLDER_NAME)as? String{
                                            UserDefaults.standard.set(account_holder_name, forKey: ACCOUNT_HOLDER_NAME)
                                        }
                                        
                                        if let account_number = user.value(forKey: ACCOUNT_NUMBER)as? String{
                                            UserDefaults.standard.set(account_number, forKey: ACCOUNT_NUMBER)
                                        }
                                        
                                        if let balance_btc = user.value(forKey: BALANCE_BTC)as? String{
                                            UserDefaults.standard.set(balance_btc, forKey: BALANCE_BTC)
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
                                        
                                        if let is_new_announcement = user.value(forKey: IS_NEW_ANNOUNCEMENT)as? Int{
                                            UserDefaults.standard.set(is_new_announcement, forKey: IS_NEW_ANNOUNCEMENT)
                                        }
                                        
                                        if let is_otp_on_transactions = user.value(forKey: IS_OTP_ON_TRANSACTION)as? Int{
                                            UserDefaults.standard.set(is_otp_on_transactions, forKey: IS_OTP_ON_TRANSACTION)
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
                                        
                                        if let pin_tries = user.value(forKey: PIN_TRIES)as? Int{
                                            UserDefaults.standard.set(pin_tries, forKey: PIN_TRIES)
                                        }
                                        
                                        if let profile_image = user.value(forKey: PROFILE_IMAGE)as? String{
                                            UserDefaults.standard.set(profile_image, forKey: PROFILE_IMAGE)
                                        }
                                        
                                        if let profile_image_url = user.value(forKey: PROFILE_IMAGE_URL)as? String{
                                            UserDefaults.standard.set(profile_image_url, forKey: PROFILE_IMAGE_URL)
                                        }
                                        
                                        if let withdraw_rs = user.value(forKey: WITHDRAW_RS)as? Int{
                                            UserDefaults.standard.set(withdraw_rs, forKey: WITHDRAW_RS)
                                        }
                                        
                                        if let other_id_proof_no = user.value(forKey: OTHER_ID_PROOF_NO)as? String{
                                            UserDefaults.standard.set(other_id_proof_no, forKey: OTHER_ID_PROOF_NO)
                                        }
                                        
                                        if let other_id_proof_no_photo = user.value(forKey: OTHER_ID_PROOF_NO_PHOTO)as? String{
                                            UserDefaults.standard.set(other_id_proof_no_photo, forKey: OTHER_ID_PROOF_NO_PHOTO)
                                        }
                                        
                                        SVProgressHUD.dismiss()
                                        self.delegate.showToast(msg: json[MSG]as! String)
                                        _ = self.navigationController?.popViewController(animated: true)
                                        
                                    }
                                }
                            }
                            
                        }else{
                            SVProgressHUD.dismiss()
                            self.delegate.showToast(msg: json[MSG]as! String)
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
                            self.createWithdraw(isPinVerify: true, otp: otp)
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
    
//    func getWithdrawFees(){
//        
//        let manager = sessionManager()
//        
//        let url = kBaseUrl.appending(kGetWithdrawFees)
//        
//        print(url)
//        
//        manager.get(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
//            
//            do{
//                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
//                
//                print(json)
//                
//                if let status = json.value(forKey: STATUS) as? Int{
//                    if status == 1{
//                        
//                        if let statements = json.value(forKey: "withdraw_fees")as? NSArray{
//                            self.arrayOfWithdrawFees.removeAllObjects()
//                            for dic in statements{
//                                self.arrayOfWithdrawFees.add(dic)
//                            }
//                        }
//                    }
//                }
//            } catch {
//                alert(title: "Server didnt get any responding", msg: "Please try again")
//                print("error getting string: \(error)")
//            }
//            
//        }, failure: { (operation, error) in
//            if InternetReachability.isConnectedToNetwork(){
//                giveMeFailure(error: error as NSError, completionHandler: {
//                    isTokedUpdated in
//                    if isTokedUpdated == true{
//                        self.getWithdrawFees()
//                    }
//                })
//            }else{
//                alert(title: "", msg: "The Internet connection appears to be offline.")
//                print(error.localizedDescription)
//            }
//        })
//        
//    }
    
    
}
