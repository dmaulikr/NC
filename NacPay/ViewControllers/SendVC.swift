//
//  SendVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import AddressBook
import AFNetworking
import SVProgressHUD

class SendVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    
    @IBOutlet weak var lblContactBottomLine: UILabel!
    @IBOutlet weak var lblSendBottomLine: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var txtSearch: UITextField!

    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var btnSaveAddress: UIButton!
    
    var arrayOfContact = NSMutableArray()
    var arrayOfSearchContact = NSMutableArray()
    var isContactSearch = false

    var arrayOfAddresses = NSMutableArray()
    var arrayOfSearchAddresses = NSMutableArray()
    var isAddressSearch = false
    
    var isOnContact = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "SEND TO BITCOIN ADDRESS"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //hide back button of navigation bar
        self.navigationItem.setHidesBackButton(false, animated: true)
        
        //set RightBar button icon
        self.setRightIcon()
        
        btnSaveAddress.layer.borderWidth = 0.5
        btnSaveAddress.layer.cornerRadius = 15
        btnSaveAddress.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        //set corner radious to textField view
        setCornerRadiouToView(viewName:self.searchView)
        
        //set textField Placeholder color
        setTextFieldPlaceHolderColor(txtName: self.txtSearch, placeHolderText: "Search contact")
        
        //fetch contact from AddressBook
        if let isContactvalue = UserDefaults.standard.value(forKey: "isContact") as? Bool{
            print(isContactvalue)
        }else{
            fetchContacts()
        }
        
        //get pending address
        self.getPendingAddress()
        
        //set delegate
        self.txtSearch.delegate = self
        
        // Register to receive notification for deposit cancel
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "saveAddress"), object: nil)
        

        // Do any additional setup after loading the view.
    }
    
    // handle notification
    @objc func showSpinningWheel(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let str = dict["msg"] as? String{
                self.view.makeToast(str, duration: 2.0, position: .bottom)
                self.getPendingAddress()
            }
        }
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
        button.addTarget(self, action: #selector(HomeVC.openDrawer), for: UIControlEvents.touchUpInside)
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
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isOnContact{
            if self.isContactSearch{
                return self.arrayOfSearchContact.count
            }else{
               return self.arrayOfContact.count
            }
        }else{
            if self.isAddressSearch{
                return self.arrayOfSearchAddresses.count
            }else{
               return self.arrayOfAddresses.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isOnContact{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
            
            var json = NSDictionary()
            
            if self.isContactSearch{
                json = self.arrayOfSearchContact.object(at: indexPath.row) as! NSDictionary
            }else{
                json = self.arrayOfContact.object(at: indexPath.row) as! NSDictionary
            }
            
            if let lblName = cell.viewWithTag(1)as? UILabel{
                lblName.text = json.value(forKey: "name")as? String
            }
            
            if let lblNumber = cell.viewWithTag(2)as? UILabel{
                lblNumber.text = self.getPhoneStr(from: json.value(forKey: "number")as! String)
            }
            
            return cell
            
        }else{
            
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
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isOnContact{
            var json = NSDictionary()
            if self.isContactSearch{
                json = self.arrayOfSearchContact.object(at: indexPath.row) as! NSDictionary
            }else{
                json = self.arrayOfContact.object(at: indexPath.row) as! NSDictionary
            }
            
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SendReceiveTransactionVC")as! SendReceiveTransactionVC
            nextVC.name = json.value(forKey: "name")as! String
            nextVC.number = self.getPhoneStr(from: json.value(forKey: "number")as! String)
            nextVC.isFrom = "Phone"
            navigationController?.pushViewController(nextVC, animated: true)
            
        }else{
            
            var json = NSDictionary()
            if self.isAddressSearch{
                json = self.arrayOfSearchAddresses.object(at: indexPath.row) as! NSDictionary
            }else{
                json = self.arrayOfAddresses.object(at: indexPath.row) as! NSDictionary
            }
            
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SendReceiveTransactionVC")as! SendReceiveTransactionVC
            nextVC.name = json.value(forKey: "btc_name")as! String
            nextVC.address = json.value(forKey: "btc_address")as! String
            nextVC.isFrom = "Address"
            navigationController?.pushViewController(nextVC, animated: true)
        }
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if self.isOnContact{
            if newString == ""{
                self.isContactSearch = false
                self.tblView.reloadData()
            }else{
                self.isContactSearch = true
                self.arrayOfSearchContact.removeAllObjects()
                
                for i in 0..<self.arrayOfContact.count
                {
                    let name = (self.arrayOfContact[i] as AnyObject).value(forKey: "name")as! String
                    
                    if (name as AnyObject).lowercased.range(of: newString.lowercased())  != nil
                    {
                        self.arrayOfSearchContact.add(self.arrayOfContact[i])
                    }
                }
                
                tblView.reloadData()
            }
        }else{
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
        }
       
        return true
    }
    
    
    
    @IBAction func buttonCopyAddress(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tblView)
        var indexPath = self.tblView.indexPathForRow(at: buttonPosition)!
        let json = self.arrayOfAddresses.object(at: indexPath.row)as! NSDictionary
        let btc_address = json.value(forKey: "btc_address")as! String
        UIPasteboard.general.string = btc_address
        self.view.makeToast("Address copied to clipboard", duration: 2.0, position: .bottom)
    }
    
    
    @IBAction func buttonHandlerTabBar(_ sender: UIButton) {
        if sender.tag == 1{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC")as! HomeVC
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
    
    
    @IBAction func buttonContacts(_ sender: UIButton) {
        self.btnSaveAddress.isHidden = true
        self.lblContactBottomLine.backgroundColor = UIColor.init(hexString: "FFD700")
        self.lblSendBottomLine.backgroundColor = UIColor.clear
        setTextFieldPlaceHolderColor(txtName: self.txtSearch, placeHolderText: "Search contact")
        self.isOnContact = true
        self.tblView.reloadData()
    }
    
    @IBAction func buttonSend(_ sender: UIButton) {
        
        if let isVerified = UserDefaults.standard.value(forKey: IS_VERIFIED)as? Int{
            if isVerified == 1{
                self.btnSaveAddress.isHidden = false
            }
        }
        
        self.lblContactBottomLine.backgroundColor = UIColor.clear
        self.lblSendBottomLine.backgroundColor = UIColor.init(hexString: "FFD700")
        setTextFieldPlaceHolderColor(txtName: self.txtSearch, placeHolderText: "Search bitcoin address")
        self.isOnContact = false
        self.tblView.reloadData()
    }
    
    @IBAction func buttonSaveAddress(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SendBitcoinVC")as! SendBitcoinVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    

    func fetchContacts(){
        var error: Unmanaged<CFError>?
        let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        
        if ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.notDetermined {
            ABAddressBookRequestAccessWithCompletion(addressBook,  {
                (granted, error) in
                print(granted)
                if !granted{
                    UserDefaults.standard.set(false, forKey: "isContact")
                }
                self.populate(from: addressBook)
            })
        }else if ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.authorized{
            self.populate(from: addressBook)
        }
    }
    
    func populate(from addressBook: ABAddressBook) {
        
        if let people = ABAddressBookCopyArrayOfAllPeople(addressBook)?.takeRetainedValue() {
            // now do something with the array of people
            
            for record:ABRecord in people as [ABRecord] {
                
                var cname = ""
                var cnumber = ""
                
                //get name
                if let name = ABRecordCopyCompositeName(record)?.takeRetainedValue(){
                    cname = name as String
                }else{
                    cname = "Not found!!"
                }
                
                //get phone number
                let phones : ABMultiValue = ABRecordCopyValue(record,kABPersonPhoneProperty).takeUnretainedValue() as ABMultiValue
                let FirstPhoneNumber = ABMultiValueCopyValueAtIndex(phones, 0)
                
                if let d = FirstPhoneNumber?.takeUnretainedValue() as? String{
                    cnumber = d
                }else{
                    cnumber = "Not found!!"
                }
                
                
                var dic = [String:String]()
                dic["name"] = cname
                dic["number"] = cnumber
                
                self.arrayOfContact.add(dic)
                
            }
            DispatchQueue.main.async(execute: {
                self.tblView.reloadData()
            })
        }
        
    }
    
    func getPhoneStr(from PhoneStr : String) -> String {
        let redunantCharacters = [" ","(","-",")"]
        var finalPhoneString = PhoneStr
        redunantCharacters.forEach({
            character in
            finalPhoneString = finalPhoneString.replacingOccurrences(of: character, with: "")
        })
        return  finalPhoneString.removingWhitespaces()
    }
    
    
    func getPendingAddress(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kGetUserAddressBook)
        
        print(url)
        
        manager.post(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        if let statements = json.value(forKey: "address_list")as? NSArray{
                            self.arrayOfAddresses.removeAllObjects()
                            for dic in statements{
                                self.arrayOfAddresses.add(dic)
                            }
                        }
                        
                        self.tblView.reloadData()
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
                        self.getPendingAddress()
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
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
