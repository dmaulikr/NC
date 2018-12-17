 //
//  SendReceiveTransactionVC.swift
 //  NacPay
 //
 //  Created by Maulik Desai on 8/11/17.
 //  Copyright © 2017 Maulik Desai. All rights reserved.
 //

import UIKit
import AFNetworking
import SVProgressHUD
 
 
 protocol SendReceiveTransactionVCDelegate {
    func refreshUserAddress()
 }
 

class SendReceiveTransactionVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var BTCBalance: UILabel!
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var txtEnterAmount: UITextField!
    @IBOutlet weak var lblNoDataFound: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtNumber: UITextField!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnBit: UIButton!
    
    var delegate:SendReceiveTransactionVCDelegate!
    
    var name = ""
    var number = ""
    var address = ""
    var is_primary = ""
    var isFrom = ""
    
    var arrayOfTransaction = NSMutableArray()
    var arrayOfFeeCharts = NSMutableArray()
    
    var isValue = 0
    
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var popUpLabel: UILabel!
    
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "TRANSACTIONS"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        self.txtName.text = name
        self.txtNumber.text = self.isFrom == "Phone" ? number : address
        self.txtEnterAmount.delegate = self
        
        if self.isFrom == "Phone"{
            self.getTransactionThorughPhoneNumber(isProgress: true)
        }else{
            self.getTransactionThorughAddress()
            self.getFeeCharts()
        }
        
        if let btcPrice = UserDefaults.standard.value(forKey: BALANCE_BTC)as? String{
            self.BTCBalance.text = "(BTC Balance: ฿\(btcPrice) )"
        }
        
        self.bottomView.layer.cornerRadius = 5
        self.bottomView.clipsToBounds = true
        
        if self.isFrom == "Receive"{
            self.bottomView.isHidden = true
            if is_primary == "1"{
                self.txtName.isUserInteractionEnabled = false
                self.btnEdit.isHidden = true
            }else{
                self.txtName.isUserInteractionEnabled = true
                self.btnEdit.isHidden = false
            }
            
        }else{
            self.bottomView.isHidden = false
            self.txtName.isUserInteractionEnabled = false
            self.btnEdit.isHidden = true
        }
        
        // Register to receive notification for deposit cancel
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "sendBitCoin"), object: nil)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // handle notification
    @objc func showSpinningWheel(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let isPhoneNumber = dict["isPhoneNumber"] as? Bool{
                if isPhoneNumber{
                    if let str = dict["otp"] as? String{
                        self.sendMoneyOnNumber(otpValue: str)
                    }
                }else{
                    if let str = dict["otp"] as? String{
                        self.sendMoneyOnAddress(otpValue: str)
                    }
                }
            }
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        
        let newText = oldText.replacingCharacters(in: r, with: string)
        let isNumeric = newText.isEmpty || (Double(newText) != nil)
        let numberOfDots = newText.components(separatedBy: ".").count - 1
        
        let numberOfDecimalDigits: Int
        if let dotIndex = newText.index(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }
        
        return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 8
    }
    
    @IBAction func buttonBitCoin(_ sender: UIButton) {
        if sender.tag == 0{
            sender.tag = 1
            self.btnBit.setBackgroundImage(UIImage(named:"R1"), for: .normal)
            self.isValue = 1
            
            if !self.txtEnterAmount.text!.isEmpty{
                if self.txtEnterAmount.text?.characters.count != 1 && self.txtEnterAmount.text != "."{
                    let val = Float(self.txtEnterAmount.text!)! * Float(buyPrice)
                    let formatter = NumberFormatter()
                    formatter.maximumFractionDigits = 9
                    formatter.roundingMode = .up
                    let str = formatter.string(from: NSNumber(value: val))
                    self.txtEnterAmount.text = "\(str!)"
                }
            }
            
        }else{
            sender.tag = 0
            self.btnBit.setBackgroundImage(UIImage(named:"B1"), for: .normal)
            self.isValue = 0
            
            if !self.txtEnterAmount.text!.isEmpty{
                if self.txtEnterAmount.text?.characters.count != 1 && self.txtEnterAmount.text != "."{
                    let val1 = Float(self.txtEnterAmount.text!)! / Float(buyPrice)
                    let formatter1 = NumberFormatter()
                    formatter1.maximumFractionDigits = 9
                    formatter1.roundingMode = .up
                    let str1 = formatter1.string(from: NSNumber(value: val1))
                    self.txtEnterAmount.text = "\(str1!)"
                }
            }
        }
    }
    
    @IBAction func buttonSend(_ sender: Any) {
        
        view.endEditing(true)
        
        if self.txtEnterAmount.text!.isEmpty{
            self.view.makeToast("Please enter valid amount", duration: 2.0, position: .bottom)
        }else{
            
            if is_maintenance_mode == "1"{
                alert(title: BodyTitle, msg: subTitle)
            }else{
                
                let alert = UIAlertController(title: "Aleart!!", message: "Do you really want to transfer \(Double(self.txtEnterAmount.text!)!)", preferredStyle: .alert)
                let yesButton = UIAlertAction(title: "YES", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                    
                    if let isOTP = UserDefaults.standard.value(forKey: IS_OTP_ON_TRANSACTION)as? Int{
                        if isOTP == 0{
                            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
                            nextVC.isFromSendWithoutOTP = "true"
                            nextVC.isPhoneNumber = self.isFrom == "Phone" ? true : false
                            self.navigationController?.pushViewController(nextVC, animated: true)
                        }else{
                            if self.isFrom == "Phone"{
                                self.sendMoneyOnNumber(otpValue: "")
                            }else{
                                self.sendMoneyOnAddress(otpValue: "")
                            }
                        }
                    }
                    
                })
                let NOBtn = UIAlertAction(title: "NO", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                    // self.logoutAPI()
                })
                alert.addAction(yesButton)
                alert.addAction(NOBtn)
                self.present(alert, animated: true) {() -> Void in }
                
                
            }
        }
    }
    
    @IBAction func buttonSendAll(_ sender: Any) {
        
        if self.isValue == 0{
            if let btcPrice = UserDefaults.standard.value(forKey: BALANCE_BTC)as? String{

                var feesRate = ""
                for i in 0..<self.arrayOfFeeCharts.count{
                    let json = self.arrayOfFeeCharts.object(at: i)as! NSDictionary
                    
                    print(json)
                    
                    let rate_from = json.value(forKey: "rate_from")as! Double
                    let rate_to = json.value(forKey: "rate_to")as! Double
                    let fee = json.value(forKey: "fee")as! Double

                    let lastJson = self.arrayOfFeeCharts.lastObject as! NSDictionary
                    let lastVal = lastJson.value(forKey: "rate_to")as! Double
                    let lastfee = lastJson.value(forKey: "fee")as! Double

                    let str1:Double = Double(btcPrice)!
                    let str2:Double = Double(rate_from)
                    let str3:Double = Double(rate_to)
                    let str4:Double = Double(lastVal)
                    
                    if str1 >= str2 && str1 <= str3{
                        feesRate = String(fee)
                        break
                    }

                    if str1 >= str4{
                        feesRate = String(lastfee)
                    }
                }
                
                if feesRate == ""{
                    let st1 = Float(btcPrice)!
                    let twoDecimal = String(format: "%.8f", st1)
                    self.txtEnterAmount.text = "\(twoDecimal)"
                }
                else{
                    let st1 = Float(btcPrice)!
                    let st2:Float = Float(feesRate)!
                    
                    let st = st1 - st2
                    let twoDecimal = String(format: "%.8f", st)
                    self.txtEnterAmount.text = "\(twoDecimal)"
                    //self.txtEnterAmount.text = "\(st)"
                }
              
            }
        }else{
            if let btcPrice = UserDefaults.standard.value(forKey: BALANCE_BTC)as? String{
                
                let btcPriceFloat = Float(btcPrice)
                var feesRate = ""
                for i in 0..<self.arrayOfFeeCharts.count{
                    let json = self.arrayOfFeeCharts.object(at: i)as! NSDictionary
                    
                    print(json)
                    
                    let rate_from = json.value(forKey: "rate_from")as! Double
                    let rate_to = json.value(forKey: "rate_to")as! Double
                    let fee = json.value(forKey: "fee")as! Double
                    
                    let lastJson = self.arrayOfFeeCharts.lastObject as! NSDictionary
                    let lastVal = lastJson.value(forKey: "rate_to")as! Double
                    let lastfee = lastJson.value(forKey: "fee")as! Double
                    
                    let str1:Float = Float(btcPrice)!
                    let str2:Float = Float(rate_from)
                    let str3:Float = Float(rate_to)
                    let str4:Float = Float(lastVal)
                    
                    if str1 >= str2 && str1 <= str3{
                        feesRate = String(fee)
                        break
                    }
                    
                    if str1 >= str4{
                        feesRate = String(lastfee)
                    }
                }
                
                let st = Float(buyPrice) * btcPriceFloat!
                let twoDecimalPlaces = String(format: "%.2f", st)
                let str = Double(btcPriceFloat!) * Double(buyPrice)
                let twoDecimal = String(format: "%.8f", str)
                print((Double(btcPrice)! * Double(buyPrice)))

                self.txtEnterAmount.text = "\(twoDecimal)"
            }
        }
    }
    
    @IBAction func buttonEdit(_ sender: Any) {
        self.updateUserAddress()
    }
    
    
    @IBAction func buttonShowDetails(_ sender: UIButton) {
        self.popUpView.isHidden = false
        self.popUpView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tblView)
        var indexPath = self.tblView.indexPathForRow(at: buttonPosition)!
        let json = self.arrayOfTransaction.object(at: indexPath.row)as! NSDictionary
        print(json)
        
        let status = json.value(forKey: "status") as! Int
        let fees = json.value(forKey: "btc_fee") as! String
        print(fees)
        print(status)
        
        if status == 0 {
            let btc_address = "Address: \(json.value(forKey: "btc_address")as! String) \n Amount: \(json.value(forKey: "btc_amount")as! Double) ฿ /\(json.value(forKey: "rs_amount")as! Float) ₹ received \n Fees:\(json.value(forKey: "btc_fee") as! String) \n Status : Pending"
            
            let underlineAttribute = [NSAttributedStringKey.font: UIFont(name: "Helvetica-Bold", size: 13.0)!]
            let underlineAttributedString = NSAttributedString(string: btc_address, attributes: underlineAttribute)
            self.popUpLabel.attributedText = underlineAttributedString
        }
        else if status == 1{
             let btc_address = "Address: \(json.value(forKey: "btc_address")as! String) \n Amount: \(json.value(forKey: "btc_amount")as! Double) ฿ /\(json.value(forKey: "rs_amount")as! Float) ₹ received \n Fees:\(json.value(forKey: "btc_fee") as! String) \n Status : Sent"
            
            let underlineAttribute = [NSAttributedStringKey.font: UIFont(name: "Helvetica-Bold", size: 13.0)!]
            let underlineAttributedString = NSAttributedString(string: btc_address, attributes: underlineAttribute)
            self.popUpLabel.attributedText = underlineAttributedString
        }
        else if status == 2{
             let btc_address = "Address: \(json.value(forKey: "btc_address")as! String) \n Amount: \(json.value(forKey: "btc_amount")as! Double) ฿ /\(json.value(forKey: "rs_amount")as! Float) ₹ received \n Fees:\(json.value(forKey: "btc_fee") as! String) \n Status : Cancelled"
            
            let underlineAttribute = [NSAttributedStringKey.font: UIFont(name: "Helvetica-Bold", size: 13.0)!]
            let underlineAttributedString = NSAttributedString(string: btc_address, attributes: underlineAttribute)
            self.popUpLabel.attributedText = underlineAttributedString
        }
    }
    
    
    @IBAction func buttonCopyAddress(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tblView)
        var indexPath = self.tblView.indexPathForRow(at: buttonPosition)!
        let json = self.arrayOfTransaction.object(at: indexPath.row)as! NSDictionary
        let txn_hash = json.value(forKey: "txn_hash")as! String
        let url = URL(string: "https://blockchain.info/tx/\(txn_hash)")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    @IBAction func buttonHidePopUp(_ sender: Any) {
        self.popUpView.isHidden = true
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfTransaction.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let json = self.arrayOfTransaction.object(at: indexPath.row)as! NSDictionary
        
        print(json)
        
        if isFrom == "Receive"{
            let txn_type = json.value(forKey: "txn_type")as! Int
            
            if txn_type == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "rightCell", for: indexPath)
                
               if let lblName = cell.viewWithTag(1)as? UILabel{
            //    print(json.value(forKey: "btc_amount")as! String)
             //   print(json.value(forKey: "rs_amount")as! Float)
                let status = json.value(forKey: "status") as! Int
                let fees = json.value(forKey: "btc_fee") as! String
                print(fees)
                print(status)
                
                if status == 0 {}
                else if status == 1{}
                else if status == 2{}
                    lblName.text = "+ \(json.value(forKey: "btc_amount")as! Double) ฿ /\(json.value(forKey: "rs_amount")as! Float) ₹ received"
                }
                
                if let lblNumber = cell.viewWithTag(2)as? UILabel{
                    if let st = json.value(forKey: "created_at")as? Int{
                        lblNumber.text = self.elapsedTime(dateValue: String(st))
                        
                    }
                }
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "leftCell", for: indexPath)
                
                if let lblName = cell.viewWithTag(3)as? UILabel{
                    lblName.text = "- \(json.value(forKey: "btc_amount")as! Double) ฿ /\(json.value(forKey: "rs_amount")as! Double) ₹ sent"
                }
                
                if let lblNumber = cell.viewWithTag(4)as? UILabel{
                    if let st = json.value(forKey: "created_at")as? Int{
                        lblNumber.text = self.elapsedTime(dateValue: String(st))
                        
                    }
                }
                
                return cell
            }
            
        }else{
            
            let txn_type = json.value(forKey: "txn_type")as! Int
            
            if txn_type == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "rightCell", for: indexPath)
                
                if let lblName = cell.viewWithTag(1)as? UILabel{
                    lblName.text = "+ \(json.value(forKey: "btc_amount")as! Double) ฿ /\(json.value(forKey: "rs_amount")as! Double) ₹ received"
                }
                
                if let lblNumber = cell.viewWithTag(2)as? UILabel{
                    if let st = json.value(forKey: "created_at")as? Int{
                        lblNumber.text = self.elapsedTime(dateValue: String(st))
                        
                    }
                }
                return cell
                
            }else{
                
                if self.isFrom == "Phone"{
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "leftCell", for: indexPath)
                    
                    if let lblName = cell.viewWithTag(3)as? UILabel{
                        
                        let status = json.value(forKey: "status") as! Int
                        let fees = json.value(forKey: "btc_fee") as! String
                        print(fees)
                        print(status)
                       
                        lblName.text = "- \(json.value(forKey: "btc_amount")as! Double) ฿ /\(json.value(forKey: "rs_amount")as! Double) ₹ sent"
                    }
                    
                    if let lblNumber = cell.viewWithTag(4)as? UILabel{
                        if let st = json.value(forKey: "created_at")as? Int{
                            lblNumber.text = self.elapsedTime(dateValue: String(st))
                            
                        }
                    }
                    return cell
                    
                }else{
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "leftCell1", for: indexPath)
                    
                    let status = json.value(forKey: "status") as! Int
                    let fees = json.value(forKey: "btc_fee") as! String
                    print(fees)
                    print(status)
                    
                    if status == 0 {}
                    else if status == 1{}
                    else if status == 2{}
                    
                    
                    if let lblName = cell.viewWithTag(3)as? UILabel{
                        lblName.text = "- \(json.value(forKey: "btc_amount")as! Double) ฿ /\(json.value(forKey: "rs_amount")as! Double) ₹ sent"
                    }
                    
                    if let lblNumber = cell.viewWithTag(4)as? UILabel{
                        if let st = json.value(forKey: "created_at")as? Int{
                            lblNumber.text = self.elapsedTime(dateValue: String(st))
                            
                        }
                    }
                    return cell
                }
            }
        }
    }
    
    func elapsedTime (dateValue:String) -> String
    {
        let time: TimeInterval = Double(dateValue)!/1000
        
        let showDate = NSDate(timeIntervalSince1970: time)
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        inputFormatter.timeZone = TimeZone.current
        
        let resultString = inputFormatter.string(from: showDate as Date)
        return resultString
    }
    
    
    func getTransactionThorughPhoneNumber(isProgress:Bool){
        
        if isProgress{
            SVProgressHUD.show()
        }
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kgetAddressDetailByPhoneNumber)
        let param = ["phone_number":number]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let statements = json.value(forKey: "transactions")as? NSArray{
                            self.arrayOfTransaction.removeAllObjects()
                            for dic in statements{
                                self.arrayOfTransaction.add(dic)
                            }
                        }
                        
                        SVProgressHUD.dismiss()
                        self.lblNoDataFound.isHidden = true
                        self.tblView.reloadData()
                        let indexPath = NSIndexPath(row: self.arrayOfTransaction.count - 1, section: 0)
                        self.tblView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
                        
                    }else{
                        SVProgressHUD.dismiss()
                        self.lblNoDataFound.isHidden = false
                        self.lblNoDataFound.text = json.value(forKey: MSG) as? String
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
                        self.getTransactionThorughPhoneNumber(isProgress: true)
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    
    func getTransactionThorughAddress(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kGetAddressDetails)
        let param = ["address":address]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let statements = json.value(forKey: "transactions")as? NSArray{
                            self.self.arrayOfTransaction.removeAllObjects()
                            for dic in statements{
                                self.arrayOfTransaction.add(dic)
                            }
                        }
                        SVProgressHUD.dismiss()
                        self.lblNoDataFound.isHidden = true
                        self.tblView.reloadData()
                    }else{
                        SVProgressHUD.dismiss()
                        self.tblView.isHidden = false
                        self.lblNoDataFound.isHidden = false
                        self.lblNoDataFound.text = json.value(forKey: MSG) as? String
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
                        self.getTransactionThorughPhoneNumber(isProgress: true)
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    
    func getFeeCharts(){
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kGetFeeCharts)
        
        print(url)
        
        manager.get(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                SVProgressHUD.dismiss()
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let statements = json.value(forKey: "fee_chart")as? NSArray{
                            self.arrayOfFeeCharts.removeAllObjects()
                            for dic in statements{
                                self.arrayOfFeeCharts.add(dic)
                            }
                            print(self.arrayOfFeeCharts)
                        }
                    }
                }
            } catch {
                alert(title: "Server didnt get any responding", msg: "Please try again")
                print("error getting string: \(error)")
            }
            
        }, failure: { (operation, error) in
            if InternetReachability.isConnectedToNetwork(){
                giveMeFailure(error: error as NSError, completionHandler: {
                    isTokedUpdated in
                    if isTokedUpdated == true{
                        self.getFeeCharts()
                    }
                })
            }else{
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }

    func updateUserAddress(){
        view.endEditing(true)
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kUpdateUserAddressName)
        let param = ["address":self.txtNumber.text!,"btc_name":self.txtName.text!]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                SVProgressHUD.dismiss()
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        SVProgressHUD.dismiss()
                        self.delegate.refreshUserAddress()
                        self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
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
                        self.updateUserAddress()
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
    }
    
    func saveUserAddressName(){
        view.endEditing(true)
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kSaveUserAdress)
        let param = ["address":self.txtNumber.text!,"btc_name":self.txtName.text!]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let statements = json.value(forKey: "transactions")as? NSArray{
                            for dic in statements{
                                self.arrayOfTransaction.add(dic)
                            }
                            self.tblView.reloadData()
                        }
                        SVProgressHUD.dismiss()
                    }
                    SVProgressHUD.dismiss()
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
                        self.saveUserAddressName()
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
    }
    
    func sendMoneyOnNumber(otpValue:String){
        view.endEditing(true)
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        var bitCoinVal = 0.0
        if self.isValue == 0{
            bitCoinVal = Double(self.txtEnterAmount.text!)!
        }else{
            let val1 = Float(self.txtEnterAmount.text!)! / Float(buyPrice)
            let formatter1 = NumberFormatter()
            formatter1.maximumFractionDigits = 9
            formatter1.roundingMode = .up
            let twoDecimalPlaces = String(format: "%.8f", val1)
         //   let str1 = formatter1.string(from: NSNumber(value: twoDecimalPlaces))
            bitCoinVal = Double(twoDecimalPlaces)!
        }
        
        let url = kBaseUrl.appending(kSendMoneyOnNumber)
        let param = ["receiver_number":self.txtNumber.text!,"send_amount":"\(bitCoinVal)","otp":otpValue]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        self.txtEnterAmount.text = ""
                        
                        self.view.makeToast(json[MSG]as! String, duration: 2.0, position: .bottom)
                        
                        if let response_code = json.value(forKey: "response_code") as? Int{
                            if response_code == 612{
                                
                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC")as! VerifyCodeVC
                                nextVC.isFromSend = true
                                nextVC.isFromSendWithoutOTP = false
                                nextVC.isPhoneNumber = true
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
                                    
                                    self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
                                    self.getTransactionThorughPhoneNumber(isProgress: false)
                                   
                                }
                            }
                        }
                        
                        SVProgressHUD.dismiss()
                    }else{
                        SVProgressHUD.dismiss()
                        self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
                    }
                }
            } catch {
                SVProgressHUD.dismiss()
                alert(title: "Server didnt get any responding", msg: "Please try again")
                print("error getting string: \(error.localizedDescription)")
            }
            
        }, failure: { (operation, error) in
            if InternetReachability.isConnectedToNetwork(){
                giveMeFailure(error: error as NSError, completionHandler: {
                    isTokedUpdated in
                    if isTokedUpdated == true{
                        self.sendMoneyOnNumber(otpValue: otpValue)
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
    }
    
    func sendMoneyOnAddress(otpValue:String){
        view.endEditing(true)
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        var bitCoinVal = 0.0
        if self.isValue == 0{
            bitCoinVal = Double(self.txtEnterAmount.text!)!
        }else{
            let val1 = Float(self.txtEnterAmount.text!)! / Float(buyPrice)
            let formatter1 = NumberFormatter()
            formatter1.maximumFractionDigits = 9
            formatter1.roundingMode = .up
            let twoDecimalPlaces = String(format: "%.8f", val1)
            //   let str1 = formatter1.string(from: NSNumber(value: twoDecimalPlaces))
            bitCoinVal = Double(twoDecimalPlaces)!
        }
        
        
        var feesRate = ""
        for i in 0..<self.arrayOfFeeCharts.count{
            let json = self.arrayOfFeeCharts.object(at: i)as! NSDictionary
            
            let rate_from = json.value(forKey: "rate_from")as! Double
            let rate_to = json.value(forKey: "rate_to")as! Double
            let fee = json.value(forKey: "fee")as! Double
            
            let lastJson = self.arrayOfFeeCharts.lastObject as! NSDictionary
            let lastVal = lastJson.value(forKey: "rate_to")as! Double
            let lastfee = lastJson.value(forKey: "fee")as! Double
            
            
            if bitCoinVal >= Double(rate_from) && bitCoinVal <= Double(rate_to){
                feesRate = String(fee)
                break
            }
            
            if bitCoinVal >= Double(lastVal){
                feesRate = String(lastfee)
            }
            
        }
        
        
        let url = kBaseUrl.appending(kSendMoneyOnAddress)
        let param = ["receiver_address":self.txtNumber.text!,"send_amount":"\(bitCoinVal)","otp":otpValue,"fees":"\(feesRate)"]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        self.view.makeToast(json[MSG]as! String, duration: 2.0, position: .bottom)
                        
                        self.txtEnterAmount.text = ""
                        if let response_code = json.value(forKey: "response_code") as? Int{
                            if response_code == 612{
                                
                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC")as! VerifyCodeVC
                                nextVC.isFromSend = true
                                nextVC.isFromSendWithoutOTP = false
                                nextVC.isPhoneNumber = false
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
                                    
                                    self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
                                    self.getTransactionThorughAddress()
                                    
                                }
                            }
                        }
                        
                        SVProgressHUD.dismiss()
                    }else{
                        SVProgressHUD.dismiss()
                        self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
                    }
                }
            } catch {
                SVProgressHUD.dismiss()
                alert(title: "Server didnt get any responding", msg: "Please try again")
                print("error getting string: \(error.localizedDescription)")
            }
            
        }, failure: { (operation, error) in
            if InternetReachability.isConnectedToNetwork(){
                giveMeFailure(error: error as NSError, completionHandler: {
                    isTokedUpdated in
                    if isTokedUpdated == true{
                        self.sendMoneyOnNumber(otpValue: otpValue)
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
