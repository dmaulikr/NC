//
//  TransactionsVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

class TransactionsVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var lblNoStatementsAvailable: UILabel!
    @IBOutlet weak var topView: UIView!
    
    
    @IBOutlet weak var tblView: UITableView!
    var arrayOfTransaction = NSMutableArray()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "DEPOSIT AND WITHDRAW"
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
        
        self.getStatement(type: "/30")
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
        button.addTarget(self, action: #selector(TransactionsVC.openDrawer), for: UIControlEvents.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfTransaction.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let json = self.arrayOfTransaction.object(at: indexPath.row)as! NSDictionary
        print(json)
        
        if let lblDate = cell.viewWithTag(1)as? UILabel{
            if let transaction_date = json.value(forKey: "transaction_date")as? Int{
                lblDate.text = self.getDate(dateString: String(transaction_date) )
            }
        }
        
        if let lblDescription = cell.viewWithTag(2)as? UILabel , let lblbitcoinqty = cell.viewWithTag(3)as? UILabel{
            if let transaction_type_dw = json.value(forKey: "transaction_type_dw")as? Int, let transaction_amount = json.value(forKey: "transaction_amount")as? Double{
                
                if transaction_type_dw != 0{
                    if let order_id = json.value(forKey: "order_id")as? String{
                        if transaction_type_dw == 1{
                            lblDescription.text = "Deposit\nOrder no. :\(order_id)"
                        }else{
                            lblDescription.text = "Withdraw\nOrder no. :\(order_id)"
                        }
                    }
                    lblbitcoinqty.text = "\(transaction_amount)"
                }
            }
        }
        
        return cell
    }
    
    func getDate(dateString:String) -> String {
        
        let time: TimeInterval = Double(dateString)!/1000
        
        let showDate = NSDate(timeIntervalSince1970: time)
        let inputFormatter = DateFormatter()
        inputFormatter.dateStyle = DateFormatter.Style.medium
        inputFormatter.timeZone = TimeZone.current
        
        let resultString = inputFormatter.string(from: showDate as Date)
        return resultString
    }
    
    func getStatement(type:String){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kListStatement).appending(type)
        let param = ["offset":"0","limit":"100"]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{

                        if let statements = json.value(forKey: "statements")as? NSArray{
                            for dic in statements{
                                
                                if let transaction_type_dw = (dic as AnyObject).value(forKey: "transaction_type_dw")as? Int{
                                    if transaction_type_dw != 0 {
                                        self.arrayOfTransaction.add(dic as! NSDictionary)
                                    print(self.arrayOfTransaction)
                                    }
                                }
                                
                              /*  if let transaction_type = (dic as AnyObject).value(forKey: "transaction_type")as? Int{
                                    if transaction_type != 0 {
                                        self.arrayOfTransaction.add(dic as! NSDictionary)
                                    print(self.arrayOfTransaction)
                                    }
                                }*/
                            }
                        }
                        
                        if self.arrayOfTransaction.count == 0{
                            self.tblView.isHidden = true
                            self.topView.isHidden = true
                            self.lblNoStatementsAvailable.isHidden = false
                            SVProgressHUD.dismiss()
                        }else{
                            self.tblView.isHidden = false
                            self.topView.isHidden = false
                            self.lblNoStatementsAvailable.isHidden = true
                            SVProgressHUD.dismiss()
                            self.tblView.reloadData()
                        }
                    }
                    SVProgressHUD.dismiss()
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
