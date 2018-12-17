//
//  ReceiveBitcoinVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import SVProgressHUD
import AFNetworking

protocol ReceiveBitcoinVCDelegate {
    func refreshAddresses(msg:String)
}

class ReceiveBitcoinVC: UIViewController {
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var addressView: UIView!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    
    var delegate:ReceiveBitcoinVCDelegate!
    
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
        
        //set RightBar button icon
        self.setRightIcon()
        
        //set corner radious to textField view
        setCornerRadiouToView(viewName:self.nameView)
        setCornerRadiouToView(viewName:self.addressView)
        
        btnSave.layer.borderWidth = 0.5
        btnSave.layer.cornerRadius = 15
        btnSave.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        //set textField Placeholder color
        setTextFieldPlaceHolderColor(txtName: self.txtName, placeHolderText: "Name")
        setTextFieldPlaceHolderColor(txtName: self.txtAddress, placeHolderText: "Paste bitcoin address or scane qr code")
        
        //get user address
        self.getPendingAddress()
        
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
        button.addTarget(self, action: #selector(ReceiveBitcoinVC.openDrawer), for: UIControlEvents.touchUpInside)
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

    
    @IBAction func buttonScane(_ sender: UIButton) {
        if self.txtName.text!.isEmpty{
            self.view.makeToast("Please enter valid name", duration: 2.0, position: .bottom)
        }else if self.txtAddress.text!.isEmpty{
            self.view.makeToast("Please enter valid address", duration: 2.0, position: .bottom)
        }else{
            self.saveUserAddressBook()
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
    
    
    func getPendingAddress(){
        view.endEditing(true)
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kGetPendingAddress)
        
        print(url)
        
        manager.post(url, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                SVProgressHUD.dismiss()
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        if let address = json.value(forKey: "address")as? String{
                            self.txtAddress.text = address
                            SVProgressHUD.dismiss()
                        }
                    }else{
                        self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
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
    
    func saveUserAddressBook(){
        
        self.view.endEditing(true)
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kSaveUserAdress)
        let param = ["address": self.txtAddress.text!, "btc_name":self.txtName.text!]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                SVProgressHUD.dismiss()
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        //self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
                        self.delegate.refreshAddresses(msg: json.value(forKey: MSG) as! String)
                        _ = self.navigationController?.popViewController(animated: true)
                        SVProgressHUD.dismiss()
                    }else{
                        self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
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
                        self.saveUserAddressBook()
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
