//
//  DepositeWithdrawReceiptVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD


class DepositeWithdrawReceiptVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    @IBOutlet weak var lblRupees: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    
    
    @IBOutlet weak var lblDepositeWithdrawRequest: UILabel!
    @IBOutlet weak var lblDepositeWithdrawAmount: UILabel!
    @IBOutlet weak var lblDepositeWithdrawDetail: UILabel!
    @IBOutlet weak var lblOrderAmount: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    
    @IBOutlet weak var lblPaymentRefHeight: NSLayoutConstraint!
    @IBOutlet weak var lblPaymentRefTopSpace: NSLayoutConstraint!
    @IBOutlet weak var lblNotesHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblLockedForBid: UILabel!
    
    @IBOutlet weak var btnReference: UIButton!
    
    var isFromDeposite = false
    
    var isFromDepositeAndWithdrawVC = false
    
    var arrayOfData = NSArray()
    
    var isImageSelected = false
    var userProfile = UIImageView()
    
    @IBOutlet weak var txtReference: UITextField!
    @IBOutlet weak var referenceView: UIView!
    @IBOutlet weak var txtReferenceView: UIView!
    
    @IBOutlet weak var lbl1LeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var lbl2LeadingSpace: NSLayoutConstraint!
    
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnCancel1: UIButton!
    @IBOutlet weak var btnInvoice: UIButton!
    
    @IBOutlet weak var btnScan: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  =  self.isFromDeposite == true ? "RS BANK DEPOSIT" : "RS BANK WITHDRAW"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //set RightBar button icon
        self.setRightIcon()
        
        //set corner radious to txtReferenceView
        self.txtReferenceView.layer.cornerRadius = 3
        self.txtReferenceView.layer.borderWidth = 1
        self.txtReferenceView.layer.borderColor = UIColor.init(hexString: " D3D3D3").cgColor
        self.txtReferenceView.clipsToBounds = true
        
        //set textField Placeholder color
        setTextFieldPlaceHolderColor(txtName: self.txtReference, placeHolderText: "Enter payment reference number")
        
        
        if UIScreen.main.bounds.width != 320{
            self.lbl1LeadingSpace.constant = 55
            self.lbl2LeadingSpace.constant = 55
        }
        
        btnOK.layer.cornerRadius = 10
        btnOK.layer.borderWidth = 1
        btnOK.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        btnScan.layer.cornerRadius = 10
        btnScan.layer.borderWidth = 1
        btnScan.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        btnCancel.layer.cornerRadius = 10
        btnCancel.layer.borderWidth = 1
        btnCancel.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        btnCancel1.layer.cornerRadius = 10
        btnCancel1.layer.borderWidth = 1
        btnCancel1.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        btnInvoice.layer.cornerRadius = 10
        btnInvoice.layer.borderWidth = 1
        btnInvoice.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        
        if let lock_rs = UserDefaults.standard.value(forKey: LOCK_RS)as? String{
            self.lblLockedForBid.text = "₹ \(lock_rs) (locked for bid orders)"
        }else{
            if let lock_rs = UserDefaults.standard.value(forKey: LOCK_RS)as? Int{
                self.lblLockedForBid.text = "₹ \(lock_rs) (locked for bid orders)"
            }
            
        }
        
        //setup reference button
        if self.isFromDeposite{
            
            if let json = self.arrayOfData.object(at: 0)as? NSDictionary{
                
                if let payment_mode = json.value(forKey: "payment_mode")as? Int{
                    if payment_mode == 1{
                        if let transaction_reference = json.value(forKey: "transaction_reference")as? String{
                            if transaction_reference == "N/A"{
                                self.btnReference.isHidden = false
                            }else{
                                self.btnReference.isHidden = true
                            }
                        }
                        self.lblNote.text = "You have submitted Rs deposit order. To enable us to process your order, please enter your RTGS, NEFT or IMPS payment reference number by tapping the payment reference button below."
                        self.lblDepositeWithdrawRequest.text = "Rs. Bank Deposit Request"
                        self.lblDepositeWithdrawDetail.text = "Your INR deposit request details:"
                        
                    }else{
                        
                        self.btnReference.isHidden = false
                        self.lblNote.text = "You have submitted Rs deposit order. To enable us to process your order, please enter your RTGS, NEFT or IMPS payment reference number by tapping the payment reference button below."
                        self.lblDepositeWithdrawRequest.text = "Rs. PayUMoney Deposit"
                        self.lblDepositeWithdrawDetail.text = "Your INR deposit request details:"
                        
                    }
                }
                
                
                if let transaction_amount = json.value(forKey: "transaction_amount")as? Int{
                    self.lblAmount.text = "₹ \(transaction_amount)"
                    self.lblDepositeWithdrawAmount.text = "₹ \(transaction_amount)"
                }
                if let order_id = json.value(forKey: "order_id")as? String{
                    self.lblOrderAmount.text = order_id
                }
                if let balanceValue = UserDefaults.standard.value(forKey: BALANCE_RS)as? String{
                    self.lblRupees.text = "₹ \(balanceValue)"
                }
            }
            
        }else{
            
            self.lblPaymentRefHeight.constant = 0
            self.lblPaymentRefTopSpace.constant = 0
            self.lblNotesHeight.constant = 35
            
            self.btnReference.isHidden = true
            self.lblNote.text = "You have submitted Rs withdraw order. We are processing your order."
            self.lblDepositeWithdrawRequest.text = "RS Withdraw Request"
            self.lblDepositeWithdrawDetail.text = "Your INR withdraw request details:"
            
            if let json = self.arrayOfData.object(at: 0)as? NSDictionary{
                if let transaction_amount = json.value(forKey: "transaction_amount")as? Int{
                    self.lblAmount.text = "₹ \(transaction_amount)"
                    self.lblDepositeWithdrawAmount.text = "₹ \(transaction_amount)"
                }
                if let order_id = json.value(forKey: "order_id")as? String{
                    self.lblOrderAmount.text = order_id
                }
                if let balanceValue = UserDefaults.standard.value(forKey: BALANCE_RS)as? String{
                    self.lblRupees.text = "₹ \(balanceValue)"
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
        button.addTarget(self, action: #selector(DepositeWithdrawReceiptVC.openDrawer), for: UIControlEvents.touchUpInside)
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
        
        
        if self.isFromDepositeAndWithdrawVC {
            
            //create a left button for Logout
            let leftButton: UIButton = UIButton(type: .custom)
            //add function for button
            leftButton.addTarget(self, action: #selector(DepositeWithdrawReceiptVC.moveToHome), for: UIControlEvents.touchUpInside)
            leftButton.setImage(UIImage(named: "back"), for: UIControlState())
            //set frame
            if #available(iOS 9.0, *) {
                let widthConstraint = leftButton.widthAnchor.constraint(equalToConstant: 19)
                let heightConstraint = leftButton.heightAnchor.constraint(equalToConstant: 19)
                heightConstraint.isActive = true
                widthConstraint.isActive = true
            }
            
            let leftBarButton = UIBarButtonItem(customView: leftButton)
            //assign button to navigationbar
            self.navigationItem.leftBarButtonItem = leftBarButton
            
            
        }
    }
    
    @objc func openDrawer(){
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
    }
    
    @objc func moveToHome(){
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    //====================end function for setRightIcons======================

    
    @IBAction func buttonInvoice(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DepositeWithdrawInvoiceVC")as! DepositeWithdrawInvoiceVC
        nextVC.isFromDeposite = self.isFromDeposite
        nextVC.arrayOfData = self.arrayOfData
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func buttonCancel(_ sender: Any) {
        DispatchQueue.main.async(execute: {
            // use the feature only available in iOS 9
            let alert = UIAlertController(title: "Cancel \(self.isFromDeposite == true ? "Deposit" : "Withdraw")", message: "Are you sure you want to cancel?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "NO", style: .destructive, handler: nil)
            let okAction = UIAlertAction(title: "YES", style: .default) { (action) in
               self.cancelDepositeAndWithdraw()
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        })
    }
   
    @IBAction func buttonReference(_ sender: Any) {
        self.referenceView.isHidden = false
        self.referenceView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    @IBAction func buttonScan(_ sender: Any) {
        view.endEditing(true)
        
        // Create the AlertController and add its actions like button in ActionSheet
        let actionSheetController = UIAlertController(title: "", message: "Choose Ticket", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Gallery", style: .default) { action -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            OperationQueue.main.addOperation({
                self.present(imagePicker, animated: true, completion: nil)
            })
        }
        actionSheetController.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                OperationQueue.main.addOperation({
                    self.present(imagePicker, animated: true, completion: nil)
                })
                
            }else
            {
                let alert = UIAlertView(title: "Warning", message: "You don't have camera", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
        actionSheetController.addAction(deleteActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.userProfile.image = pickedImage
            self.isImageSelected = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonOK(_ sender: Any) {
        view.endEditing(true)
        if self.txtReference.text!.isEmpty{
            self.view.makeToast("Please enter valid reference number", duration: 2.0, position: .bottom)
        }else{
            self.updateRefNumber()
        }
    }
    
    @IBAction func buttonRefCancel(_ sender: Any) {
        self.referenceView.isHidden = true
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
    
    func cancelDepositeAndWithdraw(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        let url = kBaseUrl.appending(self.isFromDeposite == true ? kCancelDeposite : kCancelWithdraw)
        let param = ["orderId":self.lblOrderAmount.text!]
        
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
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deposite"), object: nil, userInfo: dic)
                        
                        _ = self.navigationController?.popToRootViewController(animated: true)
                        
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
                        self.cancelDepositeAndWithdraw()
                    }
                })
            }else{
                SVProgressHUD.dismiss()
                alert(title: "", msg: "The Internet connection appears to be offline.")
                print(error.localizedDescription)
            }
        })
        
    }
    
    
    func updateRefNumber(){
        
        SVProgressHUD.show()
        
        let manager = sessionManager()
        
        var base64 = ""
        var ext = ""
        if self.isImageSelected{
            let imageData = UIImageJPEGRepresentation(userProfile.image!,0)
            base64 = (imageData?.base64EncodedString())!
            ext = "png"
        }
        
        
        let url = kBaseUrl.appending(kUpdateReferenceNumber)
        let param = ["orderId":self.lblOrderAmount.text!,"refNum":self.txtReference.text!,"base64Data":base64,"extension":ext]
        
       // print(url)
       // print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
                if let status = json.value(forKey: STATUS) as? Int{
                    if status == 1{
                        SVProgressHUD.dismiss()
                        self.txtReference.text = ""
                        self.isImageSelected = false
                        self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
                        self.referenceView.isHidden = true
                        self.btnReference.isHidden = true
                    }else{
                        SVProgressHUD.dismiss()
                        self.txtReference.text = ""
                        self.isImageSelected = false
                        self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
                        self.referenceView.isHidden = true
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
                        self.updateRefNumber()
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
