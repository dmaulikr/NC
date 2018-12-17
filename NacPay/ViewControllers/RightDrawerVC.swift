//
//  RightDrawerVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

class RightDrawerVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMobileNumber: UILabel!
    
    
    
    
    
    
    var arrayOFNames = ["DASHBOARD","MY ADDRESS","VERIFICATION","STATEMENT","TRANSACTIONS","SETTING","SUPPORT","ABOUT US","LOGOUT"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = true
        
        //hide empty cell from tblView
        self.tblView.tableFooterView = UIView()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let account_holder_name = UserDefaults.standard.value(forKey: NAME)as? String{
            self.lblUserName.text = account_holder_name
        }
        
        if let phone_number = UserDefaults.standard.value(forKey: PHONE_NUMBER)as? String{
            self.lblMobileNumber.text = phone_number
        }
        
        if let profile_image_url = UserDefaults.standard.value(forKey: PROFILE_IMAGE_URL)as? String{
            let url = URL(string: profile_image_url)
            profileImage.sd_setImage(with: url) { (image, error, imageCacheType, imageUrl) in }
            profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2
            profileImage.layer.borderWidth = 3
            profileImage.layer.borderColor = UIColor.white.cgColor
            profileImage.clipsToBounds = true
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonEditProfile(_ sender: Any) {
        let centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        let centerNavController = UINavigationController(rootViewController: centerViewController)
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer!.centerViewController = centerNavController
        appDelegate.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
    }
    
    //MARK: tblView delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOFNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let name = cell.viewWithTag(3)as? UILabel{
            name.text = self.arrayOFNames[indexPath.row]
        }
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 4{
            if let img = cell.viewWithTag(2)as? UIImageView{
                img.image = UIImage(named: self.arrayOFNames[indexPath.row])
            }
        }else{
            if let img = cell.viewWithTag(1)as? UIImageView{
                img.image = UIImage(named: self.arrayOFNames[indexPath.row])
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var centerViewController = UIViewController()
        
        if indexPath.row == 0{
            centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            let centerNavController = UINavigationController(rootViewController: centerViewController)
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.centerContainer!.centerViewController = centerNavController
            appDelegate.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
        }else if indexPath.row == 1{
            centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyAddressVC") as! MyAddressVC
            let centerNavController = UINavigationController(rootViewController: centerViewController)
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.centerContainer!.centerViewController = centerNavController
            appDelegate.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
        }else if indexPath.row == 2{
            centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "AccountVerificationVC") as! AccountVerificationVC
            let centerNavController = UINavigationController(rootViewController: centerViewController)
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.centerContainer!.centerViewController = centerNavController
            appDelegate.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
        }else if indexPath.row == 3{
            centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "AccountStatementVC") as! AccountStatementVC
            let centerNavController = UINavigationController(rootViewController: centerViewController)
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.centerContainer!.centerViewController = centerNavController
            appDelegate.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
        }else if indexPath.row == 4{
            centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "TransactionsVC") as! TransactionsVC
            let centerNavController = UINavigationController(rootViewController: centerViewController)
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.centerContainer!.centerViewController = centerNavController
            appDelegate.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
        }else if indexPath.row == 5{
            centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
            let centerNavController = UINavigationController(rootViewController: centerViewController)
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.centerContainer!.centerViewController = centerNavController
            appDelegate.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
        }else if indexPath.row == 6{
            centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "SupportVC") as! SupportVC
            let centerNavController = UINavigationController(rootViewController: centerViewController)
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.centerContainer!.centerViewController = centerNavController
            appDelegate.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
        }else if indexPath.row == 7{
            centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            let centerNavController = UINavigationController(rootViewController: centerViewController)
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.centerContainer!.centerViewController = centerNavController
            appDelegate.centerContainer!.toggle(MMDrawerSide.right, animated: true, completion: nil)
        }else{
            DispatchQueue.main.async(execute: { 
                self.logout()
            })
        }
        
    }

    
    
    func logout(){
        // use the feature only available in iOS 9
        let alert = UIAlertController(title: "", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "CANCEL", style: .destructive, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            if Platform.isSimulator {
                self.clearAllData()
            }else{
                self.logoutAPI()
            }
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)

    }
    
    
    
    
    func logoutAPI(){
        
        if InternetReachability.isConnectedToNetwork(){
            
            SVProgressHUD.show()
            
            let manager = sessionManager()
            
            let url = kBaseUrl.appending(kLogout)
           // let
            let param = ["device_token":"\(UserDefaults.standard.value(forKey: "deviceToken")!)"]
            
            print(url)
            print(param)
            
            manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
                
                do{
                    let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                    
                    print(json)
                    
                    SVProgressHUD.dismiss()
                    self.clearAllData()
                    
                    
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
                            self.logoutAPI()
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
    
    func clearAllData(){
        //clear value from preference
        UserDefaults.standard.removeObject(forKey: IS_LOGIN)
        UserDefaults.standard.removeObject(forKey: ACCESS_TOKEN)
        UserDefaults.standard.removeObject(forKey: TOKEN_TYPE)
        UserDefaults.standard.removeObject(forKey: ACCOUNT_HOLDER_NAME)
        UserDefaults.standard.removeObject(forKey: ACCOUNT_NUMBER)
        UserDefaults.standard.removeObject(forKey: BALANCE_BTC)
        UserDefaults.standard.removeObject(forKey: BALANCE_RS)
        UserDefaults.standard.removeObject(forKey: BANK_NAME)
        UserDefaults.standard.removeObject(forKey: BIRTHDATE)
        UserDefaults.standard.removeObject(forKey: BRANCH_NAME)
        UserDefaults.standard.removeObject(forKey: EMAIL)
        UserDefaults.standard.removeObject(forKey: FIRSTNAME)
        UserDefaults.standard.removeObject(forKey: FROZEN_BTC)
        UserDefaults.standard.removeObject(forKey: GENDER)
        UserDefaults.standard.removeObject(forKey: IFSC_CODE)
        UserDefaults.standard.removeObject(forKey: IS_ACTIVE)
        UserDefaults.standard.removeObject(forKey: IS_EMAIL_VERIFIED)
        UserDefaults.standard.removeObject(forKey: IS_PHONE_VERIFIED)
        UserDefaults.standard.removeObject(forKey: IS_VERIFIED)
        UserDefaults.standard.removeObject(forKey: LASTNAME)
        UserDefaults.standard.removeObject(forKey: LOCK_BTC)
        UserDefaults.standard.removeObject(forKey: LOCK_RS)
        UserDefaults.standard.removeObject(forKey: NAME)
        UserDefaults.standard.removeObject(forKey: PAN_CARD_NUMBER)
        UserDefaults.standard.removeObject(forKey: PAN_CARD_PHOTO)
        UserDefaults.standard.removeObject(forKey: PHONE_NUMBER)
        UserDefaults.standard.removeObject(forKey: PIN_TRIES)
        UserDefaults.standard.removeObject(forKey: PROFILE_IMAGE)
        UserDefaults.standard.removeObject(forKey: PROFILE_IMAGE_URL)
        UserDefaults.standard.removeObject(forKey: WITHDRAW_RS)
        UserDefaults.standard.removeObject(forKey: OTHER_ID_PROOF_NO)
        UserDefaults.standard.removeObject(forKey: OTHER_ID_PROOF_NO_PHOTO)
        UserDefaults.standard.removeObject(forKey: OTHER_ID_PROOF_NO_PHOTO_2)
        UserDefaults.standard.removeObject(forKey: OTHER_ID_PROOF_NO_PHOTO_2_URL)
        
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDel.DrawerSettings()
    }
    
    
    
    
    
    
    
    
    

}
