//
//  SendBitcoinVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import DYQRCodeDecoder
import SVProgressHUD
import AFNetworking

class SendBitcoinVC: UIViewController {
    
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var addressView: UIView!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnPaste: UIButton!
    @IBOutlet weak var btnScan: UIButton!
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "SEND TO BITCOIN ADDRESS"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        btnSave.layer.borderWidth = 0.5
        btnSave.layer.cornerRadius = 15
        btnSave.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        btnPaste.layer.borderWidth = 0.5
        btnPaste.layer.cornerRadius = 15
        btnPaste.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        btnScan.layer.borderWidth = 0.5
        btnScan.layer.cornerRadius = 15
        btnScan.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //set RightBar button icon
        self.setRightIcon()
        
        //set corner radious to textField view
        setCornerRadiouToView(viewName:self.nameView)
        setCornerRadiouToView(viewName:self.addressView)
        
        //set textField Placeholder color
        setTextFieldPlaceHolderColor(txtName: self.txtName, placeHolderText: "Name")
        setTextFieldPlaceHolderColor(txtName: self.txtAddress, placeHolderText: "Paste bitcoin address or scane qr code")
        
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
        button.addTarget(self, action: #selector(SendBitcoinVC.openDrawer), for: UIControlEvents.touchUpInside)
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
    
    @IBAction func buttonSave(_ sender: Any) {
        if self.txtName.text!.isEmpty{
            self.view.makeToast("Please enter valid name", duration: 2.0, position: .bottom)
        }else if self.txtAddress.text!.isEmpty{
            self.view.makeToast("Please enter valid address", duration: 2.0, position: .bottom)
        }else{
            self.saveUserAddressBook()
        }
    }

    @IBAction func buttonPaste(_ sender: Any) {
        if let myString = UIPasteboard.general.string {
            self.txtAddress.text = myString
        }
    }
    
    @IBAction func buttonScane(_ sender: Any) {
        DispatchQueue.main.async {
            let vc = DYQRCodeDecoderViewController { (success, result) in
                if success{
                    var str = result?.replacingOccurrences(of: "bitcoin:", with: "")
                    if (str?.contains("?"))!{
                        let tt = str?.components(separatedBy: "?")
                        str = tt?[0]
                    }
                    self.txtAddress.text = str
                }else{
                    self.view.makeToast("Failed to read QRCode, please try again", duration: 2.0, position: .bottom)
                }
            }
            
            let objNav = UINavigationController(rootViewController: vc!)
            self.present(objNav, animated: true, completion: nil)
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
    
    
    func saveUserAddressBook(){
        
        self.view.endEditing(true)
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(kSaveUserAddressBook)
        let param = ["address": self.txtAddress.text!, "btc_name":self.txtName.text!]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        
                        SVProgressHUD.dismiss()
                        
                        // post a notification
                        let dic = ["msg": json.value(forKey: MSG) as! String]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "saveAddress"), object: nil, userInfo: dic)
                        
                        _ = self.navigationController?.popViewController(animated: true)

                        
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
