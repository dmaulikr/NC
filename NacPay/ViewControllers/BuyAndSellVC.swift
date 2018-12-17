//
//  BuyAndSellVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import SVProgressHUD
import AFNetworking

protocol BuyAndSellVCDelegate {
    func showToast(msg:String)
}

class BuyAndSellVC: UIViewController,UITextFieldDelegate,SetupPINVCDelegate{
    
    
    @IBOutlet weak var lblBuyBalance: UILabel!
    @IBOutlet weak var lblBuyMainBalance: UILabel!
    @IBOutlet weak var txtBuyEnterAmount: UITextField!
    
    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var sellView: UIView!
    
    @IBOutlet weak var lblSellBalance: UILabel!
    @IBOutlet weak var lblSellMainBalance: UILabel!
    @IBOutlet weak var txtSellEnterAmount: UITextField!
    
    @IBOutlet weak var lblBuyLine: UILabel!
    @IBOutlet weak var lblSellLine: UILabel!
    
    @IBOutlet weak var buyVerifyImage: UIImageView!
    @IBOutlet weak var sellVerifyImage: UIImageView!
    
    @IBOutlet weak var buyVerifyImageHeight: NSLayoutConstraint!
    @IBOutlet weak var SellVerifyImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var buyBtn: UIButton!
    @IBOutlet weak var sellBtn: UIButton!
    
    @IBOutlet weak var lblBuyConvertedMoney: UILabel!
    @IBOutlet weak var lblSellConvertedMoney: UILabel!

    
    @IBOutlet weak var lblBuyMinBalance: UILabel!
    @IBOutlet weak var lblBuySupportNumber: UILabel!
    
    @IBOutlet weak var lblSellMinBalance: UILabel!
    @IBOutlet weak var lblSellSupportNumber: UILabel!
    
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var btnBuyConverter: UIButton!
    @IBOutlet weak var btnSellConverter: UIButton!
    
    @IBOutlet weak var btnSellNotVerified: UIButton!
    @IBOutlet weak var btnBuyNotVerified: UIButton!
    
    
    var delegate:BuyAndSellVCDelegate!
    
    var isSellValue = 0
    var isBuyValue = 0
    
    var navigationTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        self.setNavigationTitle(title: navigationTitle)
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //set RightBar button icon
        self.setRightIcon()
        
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = ""
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButtonItem
        
        //set textField Placeholder color
        setWhiteTextFieldPlaceHolderColor(txtName: self.txtBuyEnterAmount, placeHolderText: "Enter Amount")
        setWhiteTextFieldPlaceHolderColor(txtName: self.txtSellEnterAmount, placeHolderText: "Enter Amount")
        
        sellBtn.layer.borderWidth = 0.5
        sellBtn.layer.cornerRadius = 15
        sellBtn.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        btn.layer.borderWidth = 0.5
        btn.layer.cornerRadius = 12
        btn.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        buyBtn.layer.borderWidth = 0.5
        buyBtn.layer.cornerRadius = 15
        buyBtn.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        if navigationTitle == "BUY BITCOINS"{
            self.buyView.isHidden = false
            self.sellView.isHidden = true
            self.lblBuyLine.backgroundColor = UIColor.init(hexString: "FFD700")
            self.lblSellLine.backgroundColor = UIColor.clear
        }else{
            self.buyView.isHidden = true
            self.sellView.isHidden = false
            self.lblBuyLine.backgroundColor = UIColor.clear
            self.lblSellLine.backgroundColor = UIColor.init(hexString: "FFD700")
        }
        
        if let isVerified = UserDefaults.standard.value(forKey: IS_VERIFIED)as? Int{
            if isVerified == 1{
                self.buyVerifyImageHeight.constant = 0
                self.SellVerifyImageHeight.constant = 0
                self.buyVerifyImage.isHidden = true
                self.sellVerifyImage.isHidden = true
                self.buyBtn.isUserInteractionEnabled = true
                self.sellBtn.isUserInteractionEnabled = true
                btnSellNotVerified.isHidden = true
                btnBuyNotVerified.isHidden = true
            }else{
                self.buyVerifyImageHeight.constant = 30
                self.SellVerifyImageHeight.constant = 30
                self.buyVerifyImage.isHidden = false
                self.sellVerifyImage.isHidden = false
                self.buyBtn.isUserInteractionEnabled = false
                self.sellBtn.isUserInteractionEnabled = false
                self.buyBtn.setTitleColor(UIColor.gray, for: .normal)
                self.sellBtn.setTitleColor(UIColor.gray, for: .normal)
            }
        }
        
       self.setValue()
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(BuyAndSellVC.socketData), name: Notification.Name(SOCKET_DATA), object: nil)
        
        //set delegate
        self.txtBuyEnterAmount.delegate = self
        self.txtSellEnterAmount.delegate = self

        // Register to receive notification for deposite cancel
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "buysell"), object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // handle notification
    @objc func showSpinningWheel(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let str = dict["otp"] as? String , let type = dict["type"] as? String{
                self.buyBitcoins(isPinVerify: true, type: type, otp: str)
            }
        }
    }

    
    @objc func socketData(){
        self.setValue()
    }
    
    func setValue(){
        
        //buy
        self.lblBuyBalance.text = "Balance: ₹ \(UserDefaults.standard.value(forKey: BALANCE_RS)!)"
        self.lblBuyMainBalance.text = "1฿ = ₹ \(buyPrice)"
        self.lblBuyMinBalance.text = "(min: ₹ \(min_buy_bitcoin_amount) and max: ₹ \(max_buy_bitcoin_amount))"
        self.lblBuySupportNumber.text = "For higher amounts, call \(support_phone_number)"
        
        //Sell
        if let btcPrice = UserDefaults.standard.value(forKey: BALANCE_BTC)as? String{
            let st = Double(sellPrice) * Double(btcPrice)!
            let twoDecimalPlaces = String(format: "%.3f", st)
            self.lblSellBalance.text = "BTC Balance: ฿ \(btcPrice) (₹ \(twoDecimalPlaces))"
        }
        
        self.lblSellMainBalance.text = "1฿ = ₹ \(sellPrice)"
        self.lblSellMinBalance.text = "(min: ₹ \(min_sell_bitcoin_amount) and max:  ₹ \(max_sell_bitcoin_amount))"
        self.lblSellSupportNumber.text = "For higher amounts, call \(support_phone_number)"
    }
    

    @IBAction func onACVerificationClicked(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountVerificationVC") as! AccountVerificationVC
        self.navigationController?.pushViewController(nextVC, animated: true)
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
        button.addTarget(self, action: #selector(BuyAndSellVC.openDrawer), for: UIControlEvents.touchUpInside)
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

    func setNavigationTitle(title:String){
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = title
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        self.navigationTitle = title
    }
    
    /*============================================================
     Automatically format phone while typing phone number in the text field
     ============================================================*/
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if newString.countInstances(of: ".") > 1 {
            return false
        }
        if navigationTitle == "BUY BITCOINS"{
            if self.isBuyValue == 0{
                if newString != ""{
                    
                    if newString != "."{
                        let val = Float(newString)! / Float(buyPrice)
                        
                        let formatter = NumberFormatter()
                        formatter.maximumFractionDigits = 9
                        formatter.roundingMode = .up
                        var str = formatter.string(from: NSNumber(value: val))
                        
                        if str!.characters.first == "."{
                            str = "0\(str!)"
                        }

                        self.lblBuyConvertedMoney.text = "= \(str!) ฿"
                        
                    }
                    
                }else{
                    self.lblBuyConvertedMoney.text = ""
                }
            }else{
                if newString != ""{
                    
                    if newString != "."{
                        let val = Float(newString)! * Float(buyPrice)
                        
                        let formatter = NumberFormatter()
                        formatter.maximumFractionDigits = 9
                        formatter.roundingMode = .up
                        let str = formatter.string(from: NSNumber(value: val))
                        
                        self.lblBuyConvertedMoney.text = "= ₹ \(str!)"
                    }
                }
            }
        }else{
            if self.isSellValue == 0{
                    if newString != ""{
                        
                        if newString != "."{
                            let val = Float(newString)! * Float(sellPrice)
                            
                            let formatter = NumberFormatter()
                            formatter.maximumFractionDigits = 9
                            formatter.roundingMode = .up
                            let str = formatter.string(from: NSNumber(value: val))
                            
                            self.lblSellConvertedMoney.text = "= ₹ \(str!)"
                        }

                    }
            }else{
                 if newString != ""{
                    
                    if newString != "."{
                        let val = Float(newString)! / Float(sellPrice)
                        
                        let formatter = NumberFormatter()
                        formatter.maximumFractionDigits = 9
                        formatter.roundingMode = .up
                        var str = formatter.string(from: NSNumber(value: val))
                        
                        if str!.first == "."{
                            str = "0\(str!)"
                        }
                        
                        self.lblSellConvertedMoney.text = "= \(str!) ฿"
                    }
                    
                }else{
                    self.lblSellConvertedMoney.text = ""
                }
            }
            
        }
        
        return true
    }
    //=========================================================================/
    
    
    @IBAction func buttonBuyDeposite(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DepositeAndWithdrawVC")as! DepositeAndWithdrawVC
        nextVC.navigationTitle = "DEPOSIT MONEY"
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func buttonBuy(_ sender: UIButton) {
        self.view.endEditing(true)
        if is_maintenance_mode == "1"{
            alert(title: BodyTitle, msg: subTitle)
        }else{
            if self.isBuyValue == 0{
                
                if let inrPrice = UserDefaults.standard.value(forKey: BALANCE_RS)as? String{
                    print(inrPrice)
                    let inr = Double(inrPrice)!
                    print(inr)
                
                if txtBuyEnterAmount.text!.isEmpty{
                    self.view.makeToast("Please enter valid amount", duration: 2.0, position: .bottom)
                }else if Float(txtBuyEnterAmount.text!)! < Float(min_buy_bitcoin_amount)!{
                    self.view.makeToast("Buy amount can not be less than minimum allowed", duration: 2.0, position: .bottom)
                }else if Float(txtBuyEnterAmount.text!)! > Float(max_buy_bitcoin_amount)!{
                    self.view.makeToast("Buy amount can not be greater than maximum allowed", duration: 2.0, position: .bottom)
                }else if Double(txtBuyEnterAmount.text!)! > inr {
                    self.view.makeToast("You don't have enuogh balance to buy", duration: 2.0, position: .bottom)
                    }
                else{
                    
                    if let isOTP = UserDefaults.standard.value(forKey: IS_OTP_ON_TRANSACTION)as? Int{
                        if isOTP == 0{
                            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
                            nextVC.isFromBuy = true
                            nextVC.delegate = self
                            navigationController?.pushViewController(nextVC, animated: true)
                        }else{
                            //code
                            self.buyBitcoins(isPinVerify: true, type: "Buy", otp: "")
                        }
                    }
                    }}
            }else{
                
                let str = self.lblBuyConvertedMoney.text!.replacingOccurrences(of: "=", with: "").replacingOccurrences(of: "₹", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "฿", with: "")
                print(Float(min_buy_bitcoin_amount)!)
                
                if let inrPrice = UserDefaults.standard.value(forKey: BALANCE_RS)as? String{
                    print(inrPrice)
                    let inr = Double(inrPrice)!
                    print(inr)
                if txtBuyEnterAmount.text!.isEmpty{
                    self.view.makeToast("Please enter valid amount", duration: 2.0, position: .bottom)
                }else if Float(str)! < Float(min_buy_bitcoin_amount)!{
                    self.view.makeToast("Buy amount can not be less than minimum allowed", duration: 2.0, position: .bottom)
                }else if Float(str)! > Float(max_buy_bitcoin_amount)!{
                    self.view.makeToast("Buy amount can not be greater than maximum allowed", duration: 2.0, position: .bottom)
                }else if Double(str)! > inr{
                    self.view.makeToast("You don't have enuogh balance to buy", duration: 2.0, position: .bottom)
                }else{
                    
                    
                    if let isOTP = UserDefaults.standard.value(forKey: IS_OTP_ON_TRANSACTION)as? Int{
                        if isOTP == 0{
                            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
                            nextVC.isFromBuy = true
                            nextVC.delegate = self
                            navigationController?.pushViewController(nextVC, animated: true)
                        }else{
                            //code
                            self.buyBitcoins(isPinVerify: true, type: "Buy", otp: "")
                        }
                    }}
                }
            }
        }
    }
    
    @IBAction func buttonSell(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if is_maintenance_mode == "1"{
            alert(title: BodyTitle, msg: subTitle)
        }else{
            
            if self.isSellValue == 0{
                
                let str = self.lblSellConvertedMoney.text!.replacingOccurrences(of: "=", with: "").replacingOccurrences(of: "₹", with: "").replacingOccurrences(of: " ", with: "")
                
                if let btcPrice = UserDefaults.standard.value(forKey: BALANCE_BTC)as? String{
                    let st = Float(btcPrice)
                    print(btcPrice)
                    
                    print(min_sell_bitcoin_amount)
                    if txtSellEnterAmount.text!.isEmpty{
                        self.view.makeToast("Please enter valid amount", duration: 2.0, position: .bottom)
                    }else if Float(str)! < Float(min_sell_bitcoin_amount)!{
                        self.view.makeToast("Sell amount can not be less than minimum allowed", duration: 2.0, position: .bottom)
                    }else if Float(str)! > Float(max_sell_bitcoin_amount)!{
                        self.view.makeToast("Sell amount can not be greater than maximum allowed", duration: 2.0, position: .bottom)
                    }else if Float(txtSellEnterAmount.text!)! > Float(st!){
                        self.view.makeToast("You don't have enough bitcoin to sell", duration: 2.0, position: .bottom)
                    }else{
                        
                        if let isOTP = UserDefaults.standard.value(forKey: IS_OTP_ON_TRANSACTION)as? Int{
                            if isOTP == 0{
                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
                                nextVC.isFromSell = true
                                nextVC.delegate = self
                                navigationController?.pushViewController(nextVC, animated: true)
                            }else{
                                //code
                                self.buyBitcoins(isPinVerify: true, type: "Sell", otp: "")
                            }
                        }
                    }
                }
            }
            else{
                let str = self.lblSellConvertedMoney.text!.replacingOccurrences(of: "=", with: "").replacingOccurrences(of: "฿", with: "").replacingOccurrences(of: " ", with: "")
                if let btcPrice = UserDefaults.standard.value(forKey: BALANCE_BTC)as? String{
                    let st = Float(btcPrice)
                    print(btcPrice)
                    
                    if txtSellEnterAmount.text!.isEmpty{
                        self.view.makeToast("Please enter valid amount", duration: 2.0, position: .bottom)
                    }else if Float(txtSellEnterAmount.text!)! < Float(min_sell_bitcoin_amount)!{
                        self.view.makeToast("Sell amount can not be less than minimum allowed", duration: 2.0, position: .bottom)
                    }else if Float(txtSellEnterAmount.text!)! > Float(max_sell_bitcoin_amount)!{
                        self.view.makeToast("Sell amount can not be greater than maximum allowed", duration: 2.0, position: .bottom)
                    }else if Float(str)! > Float(st!) {
                        self.view.makeToast("You don't have enough bitcoin to sell", duration: 2.0, position: .bottom)
                    }else{
                        
                        if let isOTP = UserDefaults.standard.value(forKey: IS_OTP_ON_TRANSACTION)as? Int{
                            if isOTP == 0{
                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
                                nextVC.isFromSell = true
                                nextVC.delegate = self
                                navigationController?.pushViewController(nextVC, animated: true)
                            }else{
                                //code
                                self.buyBitcoins(isPinVerify: true, type: "Sell", otp: "")
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    @IBAction func buttonBuyTab(_ sender: Any) {
        self.buyView.isHidden = false
        self.sellView.isHidden = true
        self.lblBuyLine.backgroundColor = UIColor.init(hexString: "FFD700")
        self.lblSellLine.backgroundColor = UIColor.clear
        self.setNavigationTitle(title: "BUY BITCOINS")
    }
    
    @IBAction func buttonSellTab(_ sender: Any) {
        self.buyView.isHidden = true
        self.sellView.isHidden = false
        self.lblBuyLine.backgroundColor = UIColor.clear
        self.lblSellLine.backgroundColor = UIColor.init(hexString: "FFD700")
        self.setNavigationTitle(title: "SELL BITCOINS")
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

    @IBAction func buttonBuyConverter(_ sender: UIButton) {
        if sender.tag == 0{
            sender.tag = 1
            self.btnBuyConverter.setBackgroundImage(UIImage(named:"B"), for: .normal)
            self.isBuyValue = 1
            if !self.txtBuyEnterAmount.text!.isEmpty{
                
                self.lblBuyConvertedMoney.text = "= ₹ \(self.txtBuyEnterAmount.text!)"
                
                let val = Float(self.txtBuyEnterAmount.text!)! / Float(buyPrice)
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 9
                formatter.roundingMode = .up
                let str = formatter.string(from: NSNumber(value: val))
                self.txtBuyEnterAmount.text = "\(str!)"
            }
        }else{
            sender.tag = 0
            self.btnBuyConverter.setBackgroundImage(UIImage(named:"R"), for: .normal)
            self.isBuyValue = 0
            if !self.txtBuyEnterAmount.text!.isEmpty{
                
                let tt = self.lblBuyConvertedMoney.text!.replacingOccurrences(of: "=", with: "").replacingOccurrences(of: "₹", with: "").replacingOccurrences(of: " ", with: "")
                self.txtBuyEnterAmount.text = "\(tt)"
                
                let val1 = Float(self.txtBuyEnterAmount.text!)! / Float(buyPrice)
                let formatter1 = NumberFormatter()
                formatter1.maximumFractionDigits = 9
                formatter1.roundingMode = .up
                let str1 = formatter1.string(from: NSNumber(value: val1))
                self.lblBuyConvertedMoney.text = "= \(str1!) ฿"
            }
        }
    }
    
    @IBAction func buttonSellConverter(_ sender: UIButton) {
        if sender.tag == 0{
            sender.tag = 1
            self.btnSellConverter.setBackgroundImage(UIImage(named:"R"), for: .normal)
            self.isSellValue = 1
            if !self.txtSellEnterAmount.text!.isEmpty{
                
                self.lblSellConvertedMoney.text = "= \(self.txtSellEnterAmount.text!) ฿"
                
                let val = Double(self.txtSellEnterAmount.text!)! * Double(sellPrice)
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 0
                formatter.roundingMode = .up
                let str = String(format: "%.3f", val)
                self.txtSellEnterAmount.text = "\(str)"
            }
        }else{
            sender.tag = 0
            self.btnSellConverter.setBackgroundImage(UIImage(named:"B"), for: .normal)
            self.isSellValue = 0
            if !self.txtSellEnterAmount.text!.isEmpty{
                
                let tt = self.lblSellConvertedMoney.text!.replacingOccurrences(of: "=", with: "").replacingOccurrences(of: "฿", with: "").replacingOccurrences(of: " ", with: "")
                
                self.txtSellEnterAmount.text = "\(tt)"
                
                let val1 = Float(tt)! * Float(sellPrice)
                let formatter1 = NumberFormatter()
                formatter1.maximumFractionDigits = 0
                formatter1.roundingMode = .up
                let str1 = formatter1.string(from: NSNumber(value: val1))
                self.lblSellConvertedMoney.text = "= ₹ \(str1!)"
            }
        }
    }
    
    @IBAction func buttonSellAll(_ sender: Any) {
        if self.isSellValue == 0{
            
            //Sell
            if let btcPrice = UserDefaults.standard.value(forKey: BALANCE_BTC)as? String{
                self.txtSellEnterAmount.text = String(btcPrice)
            }
            
            //Sell
            if let btcPrice = UserDefaults.standard.value(forKey: BALANCE_BTC)as? String{
                let st = Float(sellPrice) * Float(btcPrice)!
                let str = Int(st)
                self.lblSellConvertedMoney.text = "= ₹ \(str)"
            }
            
        }else{
            
            //Sell
            if let btcPrice = UserDefaults.standard.value(forKey: BALANCE_BTC)as? String{
                self.lblSellConvertedMoney.text = "= \(btcPrice) ฿"
            }
            
            //Sell
            if let btcPrice = UserDefaults.standard.value(forKey: BALANCE_BTC)as? String{
                let st = Float(sellPrice) * Float(btcPrice)!
                let str = Int(st)
                self.txtSellEnterAmount.text = "\(str)"
            }
        }
    }
    
    func buyBitcoins(isPinVerify:Bool,type:String,otp:String){
        if isPinVerify{
            
            view.endEditing(true)
            SVProgressHUD.show()
            
            let manager = sessionManager()
            
            var bitCoinQuantity = ""
            var bitCoinAmount = ""
            if self.isSellValue == 0{
                bitCoinQuantity = self.txtSellEnterAmount.text!
                bitCoinAmount = self.lblSellConvertedMoney.text!
            }else{
                bitCoinQuantity = self.lblSellConvertedMoney.text!
                bitCoinAmount = self.txtSellEnterAmount.text!
            }
            
            var buyBitCoinQuantity = ""
            var buyBitCoinAmount = ""
            if self.isBuyValue == 0{
                buyBitCoinQuantity = self.lblBuyConvertedMoney.text!
                buyBitCoinAmount = self.txtBuyEnterAmount.text!
            }else{
                buyBitCoinQuantity = self.txtBuyEnterAmount.text!
                buyBitCoinAmount = self.lblBuyConvertedMoney.text!
            }
            
            let bitCoin = type == "Buy" ? buyBitCoinQuantity : bitCoinQuantity
            let bitAmount = type == "Buy" ? buyBitCoinAmount : bitCoinAmount
            
            let FinalBitCoin = bitCoin.replacingOccurrences(of: "=", with: "").replacingOccurrences(of: "฿", with: "").replacingOccurrences(of: " ", with: "")
            let FinalBitCoinAmount = bitAmount.replacingOccurrences(of: "=", with: "").replacingOccurrences(of: "฿", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "₹", with: "")
           
            
            let url = kBaseUrl.appending(type == "Buy" ? kBuyBitcoins : kSellBitcoins)
            let param = ["bitcoin_amount_rs":FinalBitCoinAmount,"bitcoin_qty":FinalBitCoin,"otp":otp]
            
            print(url)
            print(param)
            
            manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
                
                do{
                    let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                    SVProgressHUD.dismiss()
                    print(json)
                    
                    if let status = json.value(forKey: STATUS) as? Int{
                        if status == 1{
                            
                            self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
                            
                            if let response_code = json.value(forKey: "response_code") as? Int{
                                if response_code == 612{
                                    SVProgressHUD.dismiss()
                                    let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC")as! VerifyCodeVC
                                    nextVC.isFrom = type
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
                            self.buyBitcoins(isPinVerify: true, type: type, otp: "")
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
    
}

