//
//  EditProfileVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

class EditProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate {
    
    @IBOutlet weak var txtNameView: UIView!
    @IBOutlet weak var txtEmailView: UIView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var userProfile: UIImageView!
    
    var isFromPin = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 33))
        img.image = UIImage(named: "ic_app_logo")
        img.contentMode = .scaleAspectFit
        self.navigationItem.titleView = img
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //hide back button of navigation bar
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        //set corner radious to textField view
        setCornerRadiouToView(viewName:self.txtNameView)
        setCornerRadiouToView(viewName:self.txtEmailView)
        
        //set textField Placeholder color
        setTextFieldPlaceHolderColor(txtName: self.txtName, placeHolderText: "Name")
        setTextFieldPlaceHolderColor(txtName: self.txtEmail, placeHolderText: "Email")
        
        if !self.isFromPin{
            //set RightBar button icon
            self.setRightIcon()
        }
        
        
        if let firstname = UserDefaults.standard.value(forKey: NAME)as? String{
            self.txtName.text = firstname
        }
        
        
        if let email = UserDefaults.standard.value(forKey: EMAIL)as? String{
            self.txtEmail.text = email
        }
        
        if let profile_image_url = UserDefaults.standard.value(forKey: PROFILE_IMAGE_URL)as? String{
            let url = URL(string: profile_image_url)
            userProfile.sd_setImage(with: url) { (image, error, imageCacheType, imageUrl) in }
            userProfile.layer.cornerRadius = self.userProfile.bounds.width / 2
            userProfile.layer.borderWidth = 1
            userProfile.layer.borderColor = UIColor.white.cgColor
            userProfile.clipsToBounds = true
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
        
    }
    
    @objc func openDrawer(){
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
    }
    //====================end function for setRightIcons======================
    
    
    
    
    
    @IBAction func buttonSelectPhoto(_ sender: Any) {
        //hide keyboard if open
        self.view.endEditing(true)
        
        let actionSheet = UIActionSheet(title:nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Gallery" , "Camera")
        actionSheet.show(in: self.view)
    }
    
    @IBAction func buttonVerify(_ sender: Any) {
        if self.txtName.text!.isEmpty{
            alert(title: "", msg: "Enter name")
        }else if self.txtEmail.text!.isEmpty{
            alert(title: "", msg: "Enter email")
        }else{
            self.uploadUserInfo()
        }
    }
    
    /*===============================================================================
     * Function Purpose: actionSheet delegate function to pick image
     * =============================================================================*/
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        switch (buttonIndex){
            
        case 1:
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            OperationQueue.main.addOperation({
                self.present(imagePicker, animated: true, completion: nil)
            })
            
        case 2:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                imagePicker.allowsEditing = false
                OperationQueue.main.addOperation({
                    self.present(imagePicker, animated: true, completion: nil)
                })
                
                
            }else
            {
                let alert = UIAlertView(title: "Warning", message: "You don't have camera", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        default:
            print("Default")
            //Some code here..
            
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.userProfile.image = pickedImage
            self.userProfile.layer.cornerRadius = self.userProfile.bounds.width / 2
            self.userProfile.layer.borderWidth = 1
            self.userProfile.layer.borderColor = UIColor.white.cgColor
            self.userProfile.clipsToBounds = true
            self.uploadProfile()
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func uploadProfile(){
        
        if InternetReachability.isConnectedToNetwork(){
            
            SVProgressHUD.show()
            view.endEditing(true)
            
            let manager = sessionManager()
            
            let imageData = UIImageJPEGRepresentation(userProfile.image!,0)
            let base64:String = (imageData?.base64EncodedString())!
            
            var olfProfileName = ""
            if UserDefaults.standard.value(forKey: PROFILE_IMAGE) != nil{
                olfProfileName = "\(UserDefaults.standard.value(forKey: PROFILE_IMAGE)!)"
            }else{
                olfProfileName = ""
            }
            
            let url = kBaseUrl.appending(kUpdateProfilePicture)
            let param = ["base64Data":base64,"extension":"png","old_profile_image":olfProfileName]
            
            //print(url)
           // print(param)
            
            manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
                
                do{
                    let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                    
                    print(json)
                    
                    if let status = json.value(forKey: STATUS) as? Int{
                        if status == 1{
                            
                            if let user = json.value(forKey: USER) as? NSDictionary{
                                
                                if let profile_image = user.value(forKey: PROFILE_IMAGE)as? String{
                                    UserDefaults.standard.set(profile_image, forKey: PROFILE_IMAGE)
                                }
                                
                                if let profile_image_url = user.value(forKey: PROFILE_IMAGE_URL)as? String{
                                    UserDefaults.standard.set(profile_image_url, forKey: PROFILE_IMAGE_URL)
                                }
                                
                                SVProgressHUD.dismiss()
                                self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
                            }
                            
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
                            self.uploadProfile()
                        }
                    })
                }else{
                    SVProgressHUD.dismiss()
                    alert(title: "", msg: "The Internet connection appears to be offline.")
                    print(error.localizedDescription)
                }
            })
            
        }else{
            alert(title: "", msg: "The Internet connection appears to be offline.")
        }
    }
    
    
    func uploadUserInfo(){
        
        if InternetReachability.isConnectedToNetwork(){
            
            SVProgressHUD.show()
            view.endEditing(true)
            
            let manager = sessionManager()
            
            let url = kBaseUrl.appending(kUpdateProfile)
            let param = ["email":self.txtEmail.text!,"name":self.txtName.text!]
            
            print(url)
            print(param)
            
            manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
                
                do{
                    let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                    
                    print(json)
                    
                    if let status = json.value(forKey: STATUS) as? Int{
                        if status == 1{
                            SVProgressHUD.dismiss()
                            if self.isFromPin{
                                //setup drawer
                                let appDel = UIApplication.shared.delegate as! AppDelegate
                                appDel.DrawerSettings()
                            }else{
                                
                                if let status = json.value(forKey: STATUS) as? Int{
                                    if status == 1{
                                        
                                        if let user = json.value(forKey: USER) as? NSDictionary{
                                            
                                            if let name = user.value(forKey: NAME)as? String{
                                                UserDefaults.standard.set(name, forKey: NAME)
                                            }
                                            
                                            if let phone_number = user.value(forKey: PHONE_NUMBER)as? String{
                                                UserDefaults.standard.set(phone_number, forKey: PHONE_NUMBER)
                                            }
                                            
                                            if let profile_image = user.value(forKey: PROFILE_IMAGE)as? String{
                                                UserDefaults.standard.set(profile_image, forKey: PROFILE_IMAGE)
                                            }
                                            
                                            if let profile_image_url = user.value(forKey: PROFILE_IMAGE_URL)as? String{
                                                UserDefaults.standard.set(profile_image_url, forKey: PROFILE_IMAGE_URL)
                                            }
                                            
                                            SVProgressHUD.dismiss()
                                            self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
                                        }
                                        
                                    }else{
                                        SVProgressHUD.dismiss()
                                        self.view.makeToast(json.value(forKey: MSG) as! String, duration: 2.0, position: .bottom)
                                    }
                                }
                            }
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
                            self.uploadUserInfo()
                        }
                    })
                }else{
                    SVProgressHUD.dismiss()
                    alert(title: "", msg: "The Internet connection appears to be offline.")
                    print(error.localizedDescription)
                }
            })
            
        }else{
            alert(title: "", msg: "The Internet connection appears to be offline.")
        }
    }
    
    
    
    
    
    
    

    
}
