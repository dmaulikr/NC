//
//  MyAddressVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD
import QRCode
import Toast_Swift

class MyAddressVC: UIViewController {
    
    
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var QRCodeImage: UIImageView!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var stackUnverfied: UIStackView!
    @IBOutlet weak var lblUnderLine: UILabel!
    @IBOutlet weak var btnCheckStatus: UIButton!
    
    var address = ""
    
    let yourAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 13),
        NSAttributedStringKey.foregroundColor : UIColor.yellow,
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "MY ADDRESSES"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        let attributeString = NSMutableAttributedString(string: "Check status",
                                                        attributes: yourAttributes)
        btnCheckStatus.setAttributedTitle(attributeString, for: .normal)
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //hide back button of navigation bar
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        //set RightBar button icon
        self.setRightIcon()
        
        btnCopy.layer.cornerRadius = 10
        btnCopy.layer.borderWidth = 0.5
        btnCopy.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        if let isVal = UserDefaults.standard.value(forKey: IS_VERIFIED) as? Int{
            if isVal == 1{
                self.getAddresses()
                stackUnverfied.isHidden = true
               // lblUnderLine.isHidden = true
            }else{
                self.QRCodeImage.isHidden = true
                self.btnCopy.isHidden = true
               // self.lblAddress.isHidden = false
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCheckStatusClicked(_ sender: Any) {
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
        button.addTarget(self, action: #selector(MyAddressVC.openDrawer), for: UIControlEvents.touchUpInside)
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
    
    
    
    @IBAction func buttonCopy(_ sender: UIButton) {
        UIPasteboard.general.string = self.address
        self.view.makeToast("Address copied to clipboard", duration: 2.0, position: .bottom)
    }
    
    
    
    
    
    func getAddresses(){
        
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
                        
                        if let addresses = json["addresses"]as? NSArray{
                            if let dic = addresses.object(at: 0)as? NSDictionary{
                                if let address = dic.value(forKey: "btc_address")as? String{
                                    self.lblAddress.text = "My Primary address:\n \(address)"
                                    self.address = address
                                    
                                    self.QRCodeImage.isHidden = false
                                    self.btnCopy.isHidden = false
                                    self.lblAddress.isHidden = false
                                    
                                    self.QRCodeImage.image = {
                                        var qrCode = QRCode(address)
                                        qrCode?.size = self.QRCodeImage.bounds.size
                                        qrCode?.errorCorrection = .High
                                        return qrCode?.image
                                    }()
                                }
                            }
                        }
                        
                        SVProgressHUD.dismiss()
                        
                    }else{
                         SVProgressHUD.dismiss()
                        alert(title: "", msg: json.value(forKey: MSG)as! String)
                        self.QRCodeImage.isHidden = true
                        self.btnCopy.isHidden = true
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
                        self.getAddresses()
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
