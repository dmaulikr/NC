//
//  BidVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import SVProgressHUD
import AFNetworking


class BidVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    
    @IBOutlet weak var lblBuy: UILabel!
    @IBOutlet weak var lblRupees: UILabel!
    @IBOutlet weak var txtRate: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtQuantity: UITextField!
    @IBOutlet weak var lblBidBalance: UILabel!
    @IBOutlet weak var lblAskBalance: UILabel!
    @IBOutlet weak var lblInterval: UILabel!
    
    @IBOutlet weak var btnConfirmBID: UIButton!
    @IBOutlet weak var tblView: UITableView!
    
    var arrayOfBidTransactions = NSMutableArray()
    var isTransactionFound = false
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "BID BITCOINS"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        btnConfirmBID.layer.borderWidth = 0.5
        btnConfirmBID.layer.cornerRadius = 15
        btnConfirmBID.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //hide back button of navigation bar
        self.navigationItem.setHidesBackButton(false, animated: true)
        
        //set RightBar button icon
        self.setRightIcon()

        self.getBidTransactions(isProgress: true)
        
        //set corner radious to textField view
        setCornerRadiouToView(viewName:self.view1)
        setCornerRadiouToView(viewName:self.view2)
        setCornerRadiouToView(viewName:self.view3)
        
        
        //display old value
        self.socketData()
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(BidVC.socketData), name: Notification.Name(SOCKET_DATA), object: nil)
        
        self.txtAmount.delegate = self
        self.txtRate.delegate = self
        self.txtQuantity.delegate = self
        
        // Register to receive notification for deposite cancel
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "bid"), object: nil)
        
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
                self.tradeBuyBitcoin(otp:str)
            }
        }
    }
    
    @objc func socketData(){
        
        self.lblBuy.text = "Buy 1฿ = \(buyPrice)₹    |    Sell 1฿ = \(sellPrice)₹"
        if let inrPrice = UserDefaults.standard.value(forKey: BALANCE_RS)as? String{
            self.lblRupees.text = "₹ \(inrPrice)"
        }
        
        
        
        if let lock_btc = UserDefaults.standard.value(forKey: LOCK_BTC)as? String{
            self.lblAskBalance.text = "฿ \(lock_btc)"
            
        }
        
        if let lock_rs = UserDefaults.standard.value(forKey: LOCK_RS)as? String{
             self.lblBidBalance.text = "₹ \(lock_rs)"
        }
        
        let bidInterval = Double(Double(buyPrice) - Double(bid_amount_interval)!)
        
        lblInterval.text = "Rate allowed from \(bidInterval) to \(buyPrice)"
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
        button.addTarget(self, action: #selector(BidVC.openDrawer), for: UIControlEvents.touchUpInside)
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
//        let leftButton: UIButton = UIButton(type: .custom)
//        //set image for button
//        leftButton.setImage(UIImage(named: "ic_app_logo"), for: UIControlState())
//        leftButton.translatesAutoresizingMaskIntoConstraints = false
//        //add function for button
//        //leftButton.addTarget(self, action: #selector(HomeVC.openDrawer), for: UIControlEvents.touchUpInside)
//
//        if #available(iOS 9.0, *) {
//            let widthConstraint = leftButton.widthAnchor.constraint(equalToConstant: 28)
//            let heightConstraint = leftButton.heightAnchor.constraint(equalToConstant: 33)
//            heightConstraint.isActive = true
//            widthConstraint.isActive = true
//        }
//
//        let leftbarButton = UIBarButtonItem(customView: leftButton)
//        //assign button to navigationbar
//        self.navigationItem.leftBarButtonItem = leftbarButton
    }
    
    @objc func openDrawer(){
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
    }
    //====================end function for setRightIcons======================
    

    @IBAction func buttonConfirmBID(_ sender: UIButton) {
        view.endEditing(true)
        
        if let inrPrice = UserDefaults.standard.value(forKey: BALANCE_RS)as? String{
            print(inrPrice)
            let inr = Double(inrPrice)!
            print(inr)
           
            let bidInterval = Double(Double(buyPrice) - Double(bid_amount_interval)!)
            
            if self.txtRate.text!.isEmpty{
                self.view.makeToast("Please enter valid rate", duration: 2.0, position: .bottom)
            }else if self.txtAmount.text!.isEmpty{
                self.view.makeToast("Please enter valid amount", duration: 2.0, position: .bottom)
            }else if self.txtQuantity.text!.isEmpty{
                self.view.makeToast("Please enter valid quantity", duration: 2.0, position: .bottom)
            }else if Double(self.txtAmount.text!)! > inr {
                self.view.makeToast("You don't have enuogh balance to bid", duration: 2.0, position: .bottom)
            }else if Double(txtRate.text!)!<bidInterval{
                self.view.makeToast("You cannot bid less then Given Interval", duration: 2.0, position: .bottom)
            }
            else{
                self.tradeBuyBitcoin(otp:"")
            }
            
        }
        
        
        
    }
    
    @IBAction func buttonCancel(_ sender: UIButton) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.tblView)
        let indexPath = self.tblView.indexPathForRow(at: buttonPosition)
        
        let json = self.arrayOfBidTransactions.object(at: indexPath!.row)as! NSDictionary
        let tID = json.value(forKey: "_id")as! String
        print(tID)
        self.deleteOrder(trade_id: "\(tID)")
    }
    
    
   
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if newString.countInstances(of: ".") > 1 {
            return false
        }
        
        if textField == self.txtAmount{
            if self.txtRate.text != ""{
                if newString != ""{
                    
                    let val = Float(newString)! / Float(self.txtRate.text!)!
                    
                    let formatter = NumberFormatter()
                    formatter.maximumFractionDigits = 9
                    formatter.roundingMode = .up
                    var str = formatter.string(from: NSNumber(value: val))
                    
                    if str!.characters.first == "."{
                        str = "0\(str!)"
                    }
                    
                    self.txtQuantity.text = "\(str!)"
                    
                }else{
                    self.txtQuantity.text = ""
                }
            }else{
                self.txtAmount.text = ""
                self.txtQuantity.text = ""
            }
        }else if textField == self.txtQuantity{
            if self.txtRate.text != ""{
                if newString != ""{
                    
                    if newString != "."{
                        let val = Float(newString)! * Float(self.txtRate.text!)!
                        
                        if val == 0{
                            self.txtAmount.text = ""
                            self.txtQuantity.text = ""
                        }else{
                            let st = Int(val)
                            self.txtAmount.text = "\(st)"
                        }
                    }
                    
                }else{
                    self.txtAmount.text = ""
                }
            }else{
                self.txtAmount.text = ""
                self.txtQuantity.text = ""
            }
        }else if textField == self.txtRate{
            if self.txtAmount.text != "" || self.txtQuantity.text != ""{
                if newString != ""{
                    
                    let val = Float(self.txtAmount.text!)! / Float(newString)!
                    
                    let formatter = NumberFormatter()
                    formatter.maximumFractionDigits = 9
                    formatter.roundingMode = .up
                    var str = formatter.string(from: NSNumber(value: val))
                    
                    if str!.characters.first == "."{
                        str = "\(val)"
                    }
                    
                    self.txtQuantity.text = "\(str!)"
                    
                }else{
                    self.txtQuantity.text = ""
                }

            }else{
                self.txtAmount.text = ""
                self.txtQuantity.text = ""
            }
        }
        
        return true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isTransactionFound == true ? self.arrayOfBidTransactions.count : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.isTransactionFound == true ? 100 : 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.isTransactionFound{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

            let json = self.arrayOfBidTransactions.object(at: indexPath.row)as! NSDictionary
            
            if let lblDate = cell.viewWithTag(1)as? UILabel{
                if let order_id = json.value(forKey: "order_id")as? String{
                    lblDate.text = "Order Id : \(order_id)"
                }
            }
            
            if let lblDate = cell.viewWithTag(2)as? UILabel{
                if let bitcoin_price = json.value(forKey: "bitcoin_price")as? Int{
                    lblDate.text = "Bid Rate : ₹\(bitcoin_price)"
                }
            }
            
            if let lblDate = cell.viewWithTag(3)as? UILabel{
                if let bitcoin_amount_rs = json.value(forKey: "bitcoin_amount_rs")as? Int{
                    lblDate.text = "Bid Amount : ₹\(bitcoin_amount_rs)"
                }
            }
            
            if let lblDate = cell.viewWithTag(4)as? UILabel{
                if let bitcoin_qty = json.value(forKey: "bitcoin_qty")as? Double{
                    lblDate.text = "Bitcoin Qty : ฿ \(bitcoin_qty)"
                }
            }
            
            return cell

        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
            
            return cell
        }
        
    }
    
    
    
    
    func getBidTransactions(isProgress:Bool){
        
        if isProgress{
            SVProgressHUD.show()
        }
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kGetUserBidTransaction)
        
        print(url)
        
        manager.post(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                SVProgressHUD.dismiss()
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    
                    self.arrayOfBidTransactions.removeAllObjects()
                    
                    if status == 1{
                        
                        self.view.makeToast(json.value(forKey: MSG) as? String, duration: 2.0, position: .bottom)
                        
                        if let statements = json.value(forKey: "list")as? NSArray{
                            for dic in statements{
                                self.arrayOfBidTransactions.add(dic as! NSDictionary)
                            }
                        }
                        
                        if self.arrayOfBidTransactions.count > 0{
                            self.isTransactionFound = true
                        }
                        
                        SVProgressHUD.dismiss()
                        self.tblView.reloadData()
                    }else{
                        SVProgressHUD.dismiss()
                        self.tblView.reloadData()
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
                        self.getBidTransactions(isProgress: isProgress)
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    
    func tradeBuyBitcoin(otp:String){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let sixDecimalPlaces = Double(self.txtQuantity.text!)!.rounded(toPlaces: 6)
               
        let url = kBaseUrl.appending(kTradeBuyBitcoins)
        let param = ["bitcoin_price":self.txtRate.text!,"bitcoin_amount_rs":self.txtAmount.text!,"bitcoin_qty":"\(sixDecimalPlaces)","otp":otp]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                         SVProgressHUD.dismiss()
                        self.view.makeToast(json.value(forKey: MSG) as? String, duration: 3.0, position: .bottom)
                        if let response_code = json.value(forKey: "response_code") as? Int{
                            if response_code == 612{
                                SVProgressHUD.dismiss()
                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC")as! VerifyCodeVC
                                nextVC.isFromBid = true
                                self.navigationController?.pushViewController(nextVC, animated: true)
                                
                            }else{
                                
                                if let user = json.value(forKey: USER) as? NSDictionary{
                                    
                                    if let account_holder_name = user.value(forKey: ACCOUNT_HOLDER_NAME)as? String{
                                        UserDefaults.standard.set(account_holder_name, forKey: ACCOUNT_HOLDER_NAME)
                                    }
                                    
                                    if let account_number = user.value(forKey: ACCOUNT_NUMBER)as? String{
                                        UserDefaults.standard.set(account_number, forKey: ACCOUNT_NUMBER)
                                    }
                                    
                                    if let balance_btc = user.value(forKey: BALANCE_BTC)as? Float{
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
                                    
                                    if let lock_btc = user.value(forKey: LOCK_BTC)as? Float{
                                        UserDefaults.standard.set(lock_btc, forKey: LOCK_BTC)
                                        self.lblAskBalance.text = "฿ \(lock_btc)"
                                    }
                                    
                                    if let lock_rs = user.value(forKey: LOCK_RS)as? String{
                                        UserDefaults.standard.set(lock_rs, forKey: LOCK_RS)
                                        self.lblBidBalance.text = "₹ \(lock_rs)"
                                    }else{
                                        if let lock_rs = user.value(forKey: LOCK_RS)as? Int{
                                            UserDefaults.standard.set(lock_rs, forKey: LOCK_RS)
                                            self.lblBidBalance.text = "₹ \(lock_rs)"
                                        }
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
                                    
                                    self.txtRate.text = ""
                                    self.txtQuantity.text = ""
                                    self.txtAmount.text = ""
                                    
                                    self.getBidTransactions(isProgress: false)
                                    
                                }
                            }
                        }
                        
                    }else{
                        SVProgressHUD.dismiss()
                        self.view.makeToast(json.value(forKey: MSG) as? String, duration: 3.0, position: .bottom)
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
                        self.tradeBuyBitcoin(otp:"")
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    
    func deleteOrder(trade_id:String){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kCancelTradeBuyBitcoins)
        let param = ["trade_id":trade_id]
        
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
                            }
                            
                            if let account_number = user.value(forKey: ACCOUNT_NUMBER)as? String{
                                UserDefaults.standard.set(account_number, forKey: ACCOUNT_NUMBER)
                            }
                            
                            if let balance_btc = user.value(forKey: BALANCE_BTC)as? Float{
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
                                self.lblAskBalance.text = "฿ \(lock_btc)"
                            }
                            
                            if let lock_rs = user.value(forKey: LOCK_RS)as? String{
                                UserDefaults.standard.set(lock_rs, forKey: LOCK_RS)
                                self.lblBidBalance.text = "₹ \(lock_rs)"
                            }else{
                                if let lock_rs = user.value(forKey: LOCK_RS)as? Int{
                                    UserDefaults.standard.set(lock_rs, forKey: LOCK_RS)
                                    self.lblBidBalance.text = "₹ \(lock_rs)"
                                }
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
                            
                            self.getBidTransactions(isProgress: false)
                            
                        }
                        
                    }else{
                        SVProgressHUD.dismiss()
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
                        self.deleteOrder(trade_id: trade_id)
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
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
        }else if sender.tag == 5{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "AskVC")as! AskVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }
    }
    
    
    
    

}
