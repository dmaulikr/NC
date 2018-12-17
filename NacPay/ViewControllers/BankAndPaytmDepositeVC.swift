//
//  BankAndPaytmDepositeVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SVProgressHUD
import AFNetworking

class BankAndPaytmDepositeVC: UIViewController {
    
    
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblDepositAmount: UILabel!
    @IBOutlet weak var txtBankName: UITextField!
    @IBOutlet weak var viewBanks: UIView!
    @IBOutlet weak var btnDeposit: UIButton!
    @IBOutlet weak var lblLocked: UILabel!
    
    var depositAmount = ""
    var selectedBankID = ""
    
    var selectedPayUMoneyID = ""
    var type = ""
    var isFromDepositeAndWithdrawVC = false
    var arrayOfBankName:[String] = []
    var arrayOfBankNameID:[String] = []
    var arrayOfBankNameID1 = [Int]()
    
    enum PaymentDetails : String{
        case merchantID  = "5977867"
        case merchantKey = "8CKwSlWP"
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "RS BANK DEPOSIT"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = ""
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButtonItem
        
        //set RightBar button icon
        self.setRightIcon()
        
        btnDeposit.layer.cornerRadius = 10
        btnDeposit.layer.borderWidth = 1
        btnDeposit.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        if let balanceValue = UserDefaults.standard.value(forKey: BALANCE_RS)as? String{
            self.lblBalance.text = "₹ \(balanceValue)"
        }
        
        if let lock_rs = UserDefaults.standard.value(forKey: LOCK_RS)as? String{
            self.lblLocked.text = "₹ \(lock_rs) (locked for bid orders)"
        }else{
            if let lock_rs = UserDefaults.standard.value(forKey: LOCK_RS)as? Int{
                self.lblLocked.text = "₹ \(lock_rs) (locked for bid orders)"
            }
        }
        
        self.lblDepositAmount.text = "₹ \(self.depositAmount)"
        
        if type == "Bank"{
            self.getBankDetails()
        }else{
            viewBanks.isHidden = true
          //  self.getPaytmDetails()
        }


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        button.addTarget(self, action: #selector(BankAndPaytmDepositeVC.openDrawer), for: UIControlEvents.touchUpInside)
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
    

    @IBAction func buttonSelectBank(_ sender: UIButton) {
        
        ActionSheetStringPicker.show(withTitle: "Select Bank", rows:arrayOfBankName
            , initialSelection: 0, doneBlock: {
                picker, values, indexes in
                
                self.txtBankName.text = "\(indexes!)"
                self.selectedBankID = self.arrayOfBankNameID[values]
                
                return
        }, cancel: { ActionMultipleStringCancelBlock in return
            
        }, origin: sender)
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
    
    
    @IBAction func buttonDeposit(_ sender: Any) {
        if self.type == "Bank"{
            self.createBankDeposit()
        }else{
           self.createPayUDeposit()
        }
    }
    
    func createPayUDeposit(){
        
        let txnParam:PUMTxnParam = PUMTxnParam()
        
        let number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String
        let emailId = UserDefaults.standard.value(forKey: EMAIL)as? String
        let fName = UserDefaults.standard.value(forKey: FIRSTNAME)as? String
        
        //Set the parameters
        txnParam.phone = number
        txnParam.email = emailId
        txnParam.amount = self.depositAmount
        txnParam.environment = PUMEnvironment.production
        txnParam.firstname = fName
        txnParam.key = PaymentDetails.merchantKey.rawValue
        txnParam.merchantid = PaymentDetails.merchantID.rawValue
        //  transactionid should be came from backend
        // dynamicly creating transactionid for demo purpose only
     //   let uuid = UUID().uuidString
      //  let transaction = uuid.sha512()
        let transactionid = (NSDate().timeIntervalSince1970)*1000
        //  let transactionid = (transaction as NSString).substring(to: 20)
        txnParam.txnID = String(Int(transactionid))
       // txnParam.txnID = Double(transactionid)
      //  txnParam.txnID = "txnID123"
        // url which will show when transaction succeed
        txnParam.surl = "https://www.payumoney.com/mobileapp/payumoney/success.php"
        // url which will show when transaction failed
        txnParam.furl = "https://www.payumoney.com/mobileapp/payumoney/failure.php"
        // Product info which user going to buy
        txnParam.productInfo = "Naccoin Deposit"
        // User define parameter
        txnParam.udf1 = ""
        txnParam.udf2 = ""
        txnParam.udf3 = ""
        txnParam.udf4 = ""
        txnParam.udf5 = ""
        txnParam.udf6 = ""
        txnParam.udf7 = ""
        txnParam.udf8 = ""
        txnParam.udf9 = ""
        txnParam.udf10 = ""
        
        let hashValue = String.localizedStringWithFormat("%@|%@|%@|%@|%@||||||||||",txnParam.txnID!,txnParam.amount!,txnParam.productInfo!,txnParam.firstname!,txnParam.email!)
        
        
        //API FOR HASH
        
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kcalculateHash)
        print(url)
        let param = ["userData":hashValue]
        print(param)
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let hex = json.value(forKey: "hexString") as? String{
                            
                            txnParam.hashValue = hex
                            PlugNPlay.presentPaymentViewController(withTxnParams: txnParam, on: self) { (paymentResponse, error, extraParam) in
                                
//                                if ((error) != nil){
//
//                                }else{
                                    let response = paymentResponse! as NSDictionary
                                    if let result = response.value(forKey: "result") as? NSDictionary{
                                        print(result)
                                        if let status = result.value(forKey: STATUS) as? String{
                                            if status == "success"{
                                                
                                                self.createPayUMoneyDeposit()
                                            }
                                       // }
                                    }
                                }
                            }
                        } }
                }
            } catch {
                SVProgressHUD.dismiss()
                
                print("error getting string: \(error)")
            }
        })
        
        
        
        // let hash = self.sha1(string: hashValue)
        /*
         let hash1 = "\(PaymentDetails.merchantKey.rawValue)|\(txnParam.txnID!)|\(txnParam.amount!)|\(txnParam.productInfo!)|\(txnParam.firstname!)|\(txnParam.email!)|"
         let hash2 = "\(txnParam.phone!)|\(txnParam.surl!)|\(txnParam.furl!)|\(lastname)|\(serviceprovider)|"
         let hash3 = "|||||\(PaymentDetails.salt.rawValue)"
         let completeHash = "\(hash1)\(hash2)\(hash3)"
         */
        
            
        
    }
    
    @objc func hashAPI() {
       
        
    }
 
    
    func getBankDetails(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kBankDetails)
        print(url)
        
        manager.get(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{

                        if let banks = json.value(forKey: "banks")as? NSArray{
                            for dic in banks{
                                let json = dic as! NSDictionary
                                if let bank_name = json.value(forKey: "bank_name")as? String{
                                    self.arrayOfBankName.append(bank_name)
                                }
                                if let bank_id = json.value(forKey: "_id")as? String{
                                    self.arrayOfBankNameID.append("\(bank_id)")
                                }
                                
                            }
                            
                            self.txtBankName.text = self.arrayOfBankName[0]
                            self.selectedBankID = self.arrayOfBankNameID[0]
                            SVProgressHUD.dismiss()
                        }
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
                        self.getBankDetails()
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    
    func getPayUMoneyDetails(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kpayUMoneyDetails)
        print(url)
        
        manager.get(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let banks = json.value(forKey: "paytm_numbers")as? NSArray{
                            for dic in banks{
                                let json = dic as! NSDictionary
                                if let paytm_number = json.value(forKey: "paytm_number")as? String{
                                    self.arrayOfBankName.append(paytm_number)
                                }
                                if let paytm_id = json.value(forKey: "paytm_id")as? Int{
                                    self.arrayOfBankNameID.append("\(paytm_id)")
                                }
                            }
                            
                            self.txtBankName.text = self.arrayOfBankName[0]
                            self.selectedBankID = self.arrayOfBankNameID[0]
                            SVProgressHUD.dismiss()
                        }
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
                        self.getPayUMoneyDetails()
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    
    func createBankDeposit(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kCreateDeposit)

        let param = ["bankId":self.selectedBankID,"txnAmount":self.depositAmount] //as [String : Any]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    SVProgressHUD.dismiss()
                    if status == 1{
                        self.getPendingDeposit(completionHandler: { (isSuccess, response) in
                            if isSuccess{
                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DepositeWithdrawReceiptVC")as! DepositeWithdrawReceiptVC
                                nextVC.isFromDeposite = true
                                nextVC.isFromDepositeAndWithdrawVC = true
                                nextVC.arrayOfData = response
                                self.navigationController?.pushViewController(nextVC, animated: true)
                            }
                        })
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
                        self.createBankDeposit()
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    
    func createPayUMoneyDeposit(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kCreatePayumoneyDeposite)
        
        let transactionid = (NSDate().timeIntervalSince1970)*1000
        //  let transactionid = (transaction as NSString).substring(to: 20)
       // txnParam.txnID = String(Int(transactionid))
        
        let param = ["payUMoneyId":String(Int(transactionid)),"txnAmount":self.depositAmount]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        SVProgressHUD.dismiss()
                        self.view.makeToast(json[MSG]as? String, duration: 2.0, position: .bottom)
                        self.navigationController?.popViewController(animated: true)
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
                        self.createBankDeposit()
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    
    func getPendingDeposit(completionHandler:@escaping (Bool,NSArray) -> ()){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kGetPendingDeposite)
        
        print(url)
        
        manager.post(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
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
                                SVProgressHUD.dismiss()
                                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DepositeWithdrawReceiptVC")as! DepositeWithdrawReceiptVC
                                nextVC.isFromDeposite = true
                                nextVC.arrayOfData = response
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
}

extension String {
    
    func sha512() -> String {
        let data = self.data(using: .utf8)!
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        data.withUnsafeBytes({
            _ = CC_SHA512($0, CC_LONG(data.count), &digest)
        })
        return digest.map({ String(format: "%02hhx", $0) }).joined(separator: "")
    }
    
}

