//
//  ReceiveVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

class ReceiveVC: UIViewController,UITableViewDelegate,UITableViewDataSource,ReceiveBitcoinVCDelegate,SendReceiveTransactionVCDelegate,UITextFieldDelegate {
    
    
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnBid: UIButton!
    @IBOutlet weak var tblView: UITableView!
    
    var arrayOfAddresses = NSMutableArray()
    var arrayOfSearchAddresses = NSMutableArray()
    var isAddressSearch = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "RECEIVE TO BITCOIN ADDRESS"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //hide back button of navigation bar
        self.navigationItem.setHidesBackButton(false , animated: true)
        
        btnBid.layer.borderWidth = 0.5
        btnBid.layer.cornerRadius = 15
        btnBid.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        //set RightBar button icon
        self.setRightIcon()
        
        //set corner radious to textField view
        setCornerRadiouToView(viewName:self.searchView)
        
        //set textField Placeholder color
        setTextFieldPlaceHolderColor(txtName: self.txtSearch, placeHolderText: "Search bitcoin address")
        
        self.txtSearch.delegate = self
        
        //get user address
        self.getUserAddress()
        
        if let isVerified = UserDefaults.standard.value(forKey: IS_VERIFIED)as? Int{
            if isVerified == 1{
                self.btnBid.isHidden = false
            }else{
                self.btnBid.isHidden = true
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
        button.addTarget(self, action: #selector(ReceiveVC.openDrawer), for: UIControlEvents.touchUpInside)
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
    

    @IBAction func buttonHandlerTabBar(_ sender: UIButton) {
        if sender.tag == 1{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC")as! HomeVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }else if sender.tag == 2{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SendVC")as! SendVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }else if sender.tag == 4{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "BidVC")as! BidVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }else if sender.tag == 5{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "AskVC")as! AskVC
            self.navigationController?.pushViewController(nextVC, animated: false)
        }
    }
    
    @IBAction func buttonCopyAddress(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tblView)
        var indexPath = self.tblView.indexPathForRow(at: buttonPosition)!
        let json = self.arrayOfAddresses.object(at: indexPath.row)as! NSDictionary
        let btc_address = json.value(forKey: "btc_address")as! String
        UIPasteboard.general.string = btc_address
        self.view.makeToast("Address copied to clipboard", duration: 2.0, position: .bottom)
    }
    
    @IBAction func buttonBid(_ sender: UIButton) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ReceiveBitcoinVC")as! ReceiveBitcoinVC
        nextVC.delegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isAddressSearch{
            return self.arrayOfSearchAddresses.count
        }else{
            return self.arrayOfAddresses.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath)
        
        var json = NSDictionary()
        
        if self.isAddressSearch{
            json = self.arrayOfSearchAddresses.object(at: indexPath.row) as! NSDictionary
        }else{
            json = self.arrayOfAddresses.object(at: indexPath.row) as! NSDictionary
        }
        
        if let lblName = cell.viewWithTag(3)as? UILabel{
            if let btc_name = json.value(forKey: "btc_name")as? String{
                lblName.text = btc_name
            }
        }
        
        if let lblAddress = cell.viewWithTag(4)as? UILabel{
            if let btc_address = json.value(forKey: "btc_address")as? String{
                lblAddress.text = btc_address
            }
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var json = NSDictionary()
        if self.isAddressSearch{
            json = self.arrayOfSearchAddresses.object(at: indexPath.row) as! NSDictionary
        }else{
            json = self.arrayOfAddresses.object(at: indexPath.row) as! NSDictionary
        }
        
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SendReceiveTransactionVC")as! SendReceiveTransactionVC
        nextVC.name = json.value(forKey: "btc_name")as! String
        nextVC.address = json.value(forKey: "btc_address")as! String
        nextVC.is_primary = String(json.value(forKey: "is_primary")as! Int)
        nextVC.isFrom = "Receive"
        nextVC.delegate = self
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if newString == ""{
            self.isAddressSearch = false
            self.tblView.reloadData()
        }else{
            self.isAddressSearch = true
            self.arrayOfSearchAddresses.removeAllObjects()
            
            for i in 0..<self.arrayOfAddresses.count
            {
                let name = (self.arrayOfAddresses[i] as AnyObject).value(forKey: "btc_name")as! String
                
                if (name as AnyObject).lowercased.range(of: newString.lowercased())  != nil
                {
                    self.arrayOfSearchAddresses.add(self.arrayOfAddresses[i])
                }
            }
            
            tblView.reloadData()
        }
        
        return true
    }
    
    func refreshAddresses(msg:String){
        self.view.makeToast(msg, duration: 2.0, position: .bottom)
        self.getUserAddress()
    }
    
    func getUserAddress(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kGetUserAddresses)
        
        print(url)
        
        manager.post(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let statements = json.value(forKey: "addresses")as? NSArray{
                            self.arrayOfAddresses.removeAllObjects()
                            for dic in statements{
                                self.arrayOfAddresses.add(dic)
                            }
                        }
                        SVProgressHUD.dismiss()
                        self.tblView.reloadData()
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
                        self.getUserAddress()
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    
    func refreshUserAddress(){
        self.getUserAddress()
    }

}
