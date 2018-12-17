//
//  DepositeWithdrawInvoiceVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit

class DepositeWithdrawInvoiceVC: UIViewController {
    
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblOrderID: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserMobileNumber: UILabel!
    @IBOutlet weak var lblBankName: UILabel!
    @IBOutlet weak var lblAccountHolderName: UILabel!
    @IBOutlet weak var lblAccountNumber: UILabel!
    @IBOutlet weak var lblIFSCCode: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblSendFund: UILabel!
    @IBOutlet weak var lblBankNameTitle: UILabel!
    
    @IBOutlet weak var lblAccountHolderNameheight: NSLayoutConstraint!
    @IBOutlet weak var lblAccountNumberHeight: NSLayoutConstraint!
    @IBOutlet weak var lblIFSCCodeHeight: NSLayoutConstraint!
    @IBOutlet weak var lblAccountHolderNameTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var lblAccountHolderNumberTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var lblIFSCCodeTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var withdrawView: UIView!
    @IBOutlet weak var depositeView: UIView!
    
    
    var isFromDeposite = false
    var arrayOfData = NSArray()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  =  self.isFromDeposite == true ? "RS BANK DEPOSIT INVOICE" : "RS WITHDRAW INVOICE"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //set RightBar button icon
        self.setRightIcon()
        
        
        if let userName = UserDefaults.standard.value(forKey: FIRSTNAME)as? String{
            self.lblUserName.text = userName
        }
        
        if let mobile = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
            self.lblUserMobileNumber.text = mobile
        }
        
        if let name = UserDefaults.standard.value(forKey: BANK_NAME)as? String{
            self.lblBankName.text = name
        }
        
        if let name = UserDefaults.standard.value(forKey: ACCOUNT_HOLDER_NAME)as? String{
            self.lblAccountHolderName.text = name
        }
        
        if let accountNumber = UserDefaults.standard.value(forKey: ACCOUNT_NUMBER)as? String{
            self.lblAccountNumber.text = accountNumber
        }
    
        
        if self.isFromDeposite{
            withdrawView.isHidden = true
            if let json = self.arrayOfData.object(at: 0)as? NSDictionary{
                print(json)
                
                if let payment_mode = json.value(forKey: "payment_mode")as? Int{
                    if payment_mode == 1{
                        
                        if let bank_details = json.value(forKey: "bank_details")as? NSDictionary{
                            if let bank_name = bank_details.value(forKey: "bank_name")as? String{
                                self.lblBankName.text = bank_name
                                self.lblBankNameTitle.text = "Bank name"
                            }
                            if let bank_acc_holder = bank_details.value(forKey: "bank_acc_holder")as? String{
                                self.lblAccountHolderName.text = bank_acc_holder
                            }
                            if let bank_account_no = bank_details.value(forKey: "bank_account_no")as? String{
                                self.lblAccountNumber.text = bank_account_no
                            }
                            if let bank_ifsc = bank_details.value(forKey: "bank_ifsc")as? String{
                                self.lblIFSCCode.text = bank_ifsc
                            }
                        }
                        
                    }else{
                        
                        if let paytm_details = json.value(forKey: "paytm_details")as? NSDictionary{
                            if let paytm_number = paytm_details.value(forKey: "paytm_number")as? String{
                                self.lblBankName.text = paytm_number
                                self.lblBankNameTitle.text = "Paytm number"
                                self.lblSendFund.text = "Please send fund to below Paytm number."
                                
                                self.lblAccountHolderNameheight.constant = 0
                                self.lblAccountNumberHeight.constant = 0
                                self.lblIFSCCodeHeight.constant = 0
                                self.lblAccountHolderNameTitleHeight.constant = 0
                                self.lblAccountHolderNumberTitleHeight.constant = 0
                                self.lblIFSCCodeTitleHeight.constant = 0

                            }
                        }
                    }
                }
                
                if let created_at = json.value(forKey: "created_at")as? String{
                    print(created_at)
                    self.lblDate.text = self.getDate(dateString: created_at)
                }
                
                if let order_id = json.value(forKey: "order_id")as? String{
                    self.lblOrderID.text = order_id
                }
                
                if let statement_status = json.value(forKey: "statement_status")as? Int{
                    if statement_status == 0{
                        self.lblStatus.text = "Pending"
                    }else if statement_status == 1{
                        self.lblStatus.text = "Completed"
                    }else{
                        self.lblStatus.text = "Cancelled"
                    }
                }
                
                if let transaction_amount = json.value(forKey: "transaction_amount")as? Int{
                    self.lblAmount.text = "₹ \(transaction_amount)"
                    self.lblTotal.text = "₹ \(transaction_amount)"
                }
                
            }
            
        }else{
            depositeView.isHidden = true
            if let json = self.arrayOfData.object(at: 0)as? NSDictionary{
                print(json)
                
                if let bank_name = UserDefaults.standard.value(forKey: BANK_NAME)as? String{
                    self.lblBankName.text = bank_name
                }
                if let bank_acc_holder = UserDefaults.standard.value(forKey: ACCOUNT_HOLDER_NAME)as? String{
                    self.lblAccountHolderName.text = bank_acc_holder
                }
                if let bank_account_no = UserDefaults.standard.value(forKey: ACCOUNT_NUMBER)as? String{
                    self.lblAccountNumber.text = bank_account_no
                }
                if let bank_ifsc = UserDefaults.standard.value(forKey: IFSC_CODE)as? String{
                    self.lblIFSCCode.text = bank_ifsc
                }
                
                if let created_at = json.value(forKey: "created_at")as? String{
                    print(created_at)
                   // self.lblDate.text = self.getDate1(dateString: created_at)
                }
                
                if let order_id = json.value(forKey: "order_id")as? String{
                    self.lblOrderID.text = order_id
                }
                
                if let statement_status = json.value(forKey: "statement_status")as? Int{
                    if statement_status == 0{
                        self.lblStatus.text = "Pending"
                    }else if statement_status == 1{
                        self.lblStatus.text = "Completed"
                    }else{
                        self.lblStatus.text = "Cancelled"
                    }
                }
                
                if let transaction_amount = json.value(forKey: "transaction_amount")as? Int{
                    self.lblAmount.text = "₹ \(transaction_amount)"
                    self.lblTotal.text = "₹ \(transaction_amount)"
                }
                
            }
            
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
        button.addTarget(self, action: #selector(DepositeWithdrawInvoiceVC.openDrawer), for: UIControlEvents.touchUpInside)
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
    

    
    
    @IBAction func buttonShare(_ sender: Any) {
        var sharingStirng = ""
        
        if self.isFromDeposite{
            if let json = self.arrayOfData.object(at: 0)as? NSDictionary{
                print(json)
                if let paytm_details = json.value(forKey: "paytm_details")as? NSDictionary{
                    if let paytm_number = paytm_details.value(forKey: "paytm_number")as? String , let transaction_amount = json.value(forKey: "transaction_amount")as? Int , let order_id = json.value(forKey: "order_id")as? String{
                        
                        sharingStirng = "Seller name: Naccoin\nName: Naccoin Technology Pvt Ltd\nPaytm Number: \(paytm_number)\nAmount: \(transaction_amount)₹\nTotal: \(transaction_amount)₹\nOrder no: \(order_id)"
                        
                        let textToShare = [sharingStirng]
                        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                        activityViewController.popoverPresentationController?.sourceView = self.view
                        self.present(activityViewController, animated: true, completion: nil)
                    }
                }
                if let bank_details = json.value(forKey: "bank_details")as? NSDictionary{
                    
                    let bank_name = bank_details.value(forKey: "bank_name")as! String
                    let bank_acc_holder = bank_details.value(forKey: "bank_acc_holder")as! String
                    let bank_account_no = bank_details.value(forKey: "bank_account_no")as! String
                    let bank_ifsc = bank_details.value(forKey: "bank_ifsc")as! String
                    let transaction_amount = json.value(forKey: "transaction_amount")as! Int
                    let order_id = json.value(forKey: "order_id")as! String
                    
                    sharingStirng = "Seller name: Naccoin\nName: Naccoin Technology Pvt Ltd\nBank Name: \(bank_name)\nAccount Holder Name: \(bank_acc_holder)\nAccount Number: \(bank_account_no)\nIFSC Code: \(bank_ifsc)\nAmount: \(transaction_amount)₹\nTotal: \(transaction_amount)₹\nOrder No: \(order_id)"
                    
                    let textToShare = [sharingStirng]
                    let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view
                    self.present(activityViewController, animated: true, completion: nil)
                    
                }
            }
        }else{
            
            if let json = self.arrayOfData.object(at: 0)as? NSDictionary{

                let transaction_amount = json.value(forKey: "transaction_amount")as! Int
                let order_id = json.value(forKey: "order_id")as! String
                
                if let bank_name = UserDefaults.standard.value(forKey: BANK_NAME)as? String , let bank_acc_holder = UserDefaults.standard.value(forKey: ACCOUNT_HOLDER_NAME)as? String , let bank_account_no = UserDefaults.standard.value(forKey: ACCOUNT_NUMBER)as? String , let bank_ifsc = UserDefaults.standard.value(forKey: IFSC_CODE)as? String{
                    
                    sharingStirng = "Seller name: Naccoin\nName: Naccoin Technology Pvt Ltd\nBank Name: \(bank_name)\nAccount Holder Name: \(bank_acc_holder)\nAccount Number: \(bank_account_no)\nIFSC Code: \(bank_ifsc)\nAmount: \(transaction_amount)₹\nTotal: \(transaction_amount)₹\nOrder No: \(order_id)"
                    
                    let textToShare = [sharingStirng]
                    let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view
                    self.present(activityViewController, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    @IBAction func buttonCopy(_ sender: Any) {
        var sharingStirng = ""
        
        if self.isFromDeposite{
            if let json = self.arrayOfData.object(at: 0)as? NSDictionary{
                if let paytm_details = json.value(forKey: "paytm_details")as? NSDictionary{
                    if let paytm_number = paytm_details.value(forKey: "paytm_number")as? String , let transaction_amount = json.value(forKey: "transaction_amount")as? Int , let order_id = json.value(forKey: "order_id")as? String{
                        
                        sharingStirng = "Seller name: Naccoin\nName: Naccoin Technology Pvt Ltd\nPaytm Number: \(paytm_number)\nAmount: \(transaction_amount)₹\nTotal: \(transaction_amount)₹\nOrder no: \(order_id)"
                    }
                }
                if let bank_details = json.value(forKey: "bank_details")as? NSDictionary{
                    
                    let bank_name = bank_details.value(forKey: "bank_name")as! String
                    let bank_acc_holder = bank_details.value(forKey: "bank_acc_holder")as! String
                    let bank_account_no = bank_details.value(forKey: "bank_account_no")as! String
                    let bank_ifsc = bank_details.value(forKey: "bank_ifsc")as! String
                    let transaction_amount = json.value(forKey: "transaction_amount")as! Int
                    let order_id = json.value(forKey: "order_id")as! String
                    
                    sharingStirng = "Seller name: Naccoin\nName: Naccoin Technology Pvt Ltd\nBank Name: \(bank_name)\nAccount Holder Name: \(bank_acc_holder)\nAccount Number: \(bank_account_no)\nIFSC Code: \(bank_ifsc)\nAmount: \(transaction_amount)₹\nTotal: \(transaction_amount)₹\nOrder No: \(order_id)"
                }
            }
        }else{
            if let json = self.arrayOfData.object(at: 0)as? NSDictionary{
                
                let transaction_amount = json.value(forKey: "transaction_amount")as! Int
                let order_id = json.value(forKey: "order_id")as! String
                
                if let bank_name = UserDefaults.standard.value(forKey: BANK_NAME)as? String , let bank_acc_holder = UserDefaults.standard.value(forKey: ACCOUNT_HOLDER_NAME)as? String , let bank_account_no = UserDefaults.standard.value(forKey: ACCOUNT_NUMBER)as? String , let bank_ifsc = UserDefaults.standard.value(forKey: IFSC_CODE)as? String{
                    
                    sharingStirng = "Seller name: Naccoin\nName: Naccoin Technology Pvt Ltd\nBank Name: \(bank_name)\nAccount Holder Name: \(bank_acc_holder)\nAccount Number: \(bank_account_no)\nIFSC Code: \(bank_ifsc)\nAmount: \(transaction_amount)₹\nTotal: \(transaction_amount)₹\nOrder No: \(order_id)"
                }
            }
        }
              
        UIPasteboard.general.string = sharingStirng
        self.view.makeToast("Invoice details copied to clipboard", duration: 2.0, position: .bottom)
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
    
    
    func getDate(dateString:String) -> String {
        let inputFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        inputFormatter.locale = enUSPosixLocale
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        //inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let showDate = inputFormatter.date(from: dateString)
        inputFormatter.dateFormat = "dd-MM-yyyy"
        let resultString = inputFormatter.string(from: showDate!)
        return resultString
    }
    
    //
    func getDate1(dateString:String) -> String {
        let inputFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        inputFormatter.locale = enUSPosixLocale
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        //inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let showDate = inputFormatter.date(from: dateString)
        inputFormatter.dateFormat = "dd-MM-yyyy"
        let resultString = inputFormatter.string(from: showDate!)
        return resultString
    }
    
    
    
    
    
    
    
    
    
    

}
