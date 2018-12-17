//
//  VerifyPhoneVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

class VerifyPhoneVC: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var mylabel: UILabel!
    @IBOutlet weak var lblText1: UILabel!
    @IBOutlet weak var lblText2: UILabel!

    @IBOutlet weak var btnAccept: UIButton!
    
    var isCheck = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var myGradient = UIImage(named: "text.png")
        mylabel.textColor = UIColor(patternImage: myGradient ?? UIImage())
        lblText1.textColor = UIColor(patternImage: myGradient ?? UIImage())
        lblText2.textColor = UIColor(patternImage: myGradient ?? UIImage())
        
        
        if UserDefaults.standard.value(forKey: IS_LOGIN) != nil{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
            nextVC.isLogin = true
            self.navigationController?.pushViewController(nextVC, animated: false)
        }
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "VERIFY YOUR PHONE NUMBER"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //hide back button of navigation bar
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        btnAccept.layer.cornerRadius = 10
        btnAccept.layer.borderWidth = 1
        btnAccept.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        //set corner radious to textField view
        setCornerRadiouToView(viewName:self.textFieldView)
        
        //set textField Placeholder color
        setTextFieldPlaceHolderColor(txtName: self.txtPhoneNumber, placeHolderText: "Enter Phone number")
        
        //set delegate of textField
        self.txtPhoneNumber.delegate = self
        
        //open keyboard
        self.txtPhoneNumber.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /*============================================================
     Automatically format phone while typing phone number in the text field
     ============================================================*/
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        //Exclude the characters When user type charaters other than decimal characters
        let components = newString.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
        
        let decimalString = components.joined(separator: "") as NSString
        let decimalStrLength = decimalString.length
        let hasLeadingOne = decimalStrLength > 0 && decimalString.character(at: 0) == (1 as unichar)
        
        if decimalStrLength == 0 || (decimalStrLength > 10 && !hasLeadingOne) || decimalStrLength > 11
        {
            let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
            
            return (newLength > 10) ? false : true
        }
       
        return true
    }
    //=========================================================================/
    
    
    
    @IBAction func buttonAcceptAndContinue(_ sender: UIButton) {
        
        //hide keyboard
        self.view.endEditing(true)
        
        if !self.isCheck{
            self.view.makeToast("Please read all terms and conditions", duration: 2.0, position: .bottom)
        }else{
            if self.txtPhoneNumber.text!.isEmpty{
                alert(title: "", msg: "Enter your phone number")
            }else{
                
                let number = self.txtPhoneNumber.text!
                if number.count < 10{
                    alert(title: "", msg: "Enter valid phone number")
                }else{
                   // self.login(number: "+91\(number)")
                    self.login(number: number)
                }
            }
        }
    }
    
    func login(number:String){
        
        SVProgressHUD.show()
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let serializer = AFJSONRequestSerializer()
        serializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        serializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer = serializer
        
        let url = kBaseUrl.appending(kRegister)
        let param = [PHONE_NUMBER:number]
        
        print(url)
        print(param)
        
        manager.post(url, parameters: param, progress: nil, success: { (operation, responseObject) in
            
            do{
                let json = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers)as! NSDictionary
                
                print(json)
                
           //     let otp_verified = json[IS_PIN_SET]as?Int
                
                if let status = json[STATUS]as? Int{
                    if status == 1{
                        
                        SVProgressHUD.dismiss()
                        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC")as! VerifyCodeVC
                        nextVC.phoneNumber = number
                        UserDefaults.standard.set(number, forKey: PHONE_NUMBER)
                        
                        var otpVal = ""
                        if let otp = json["otp"]as? String{
                            otpVal = otp
                        }
                        
                        nextVC.otp = otpVal
                        self.navigationController?.pushViewController(nextVC, animated: true)
                        
                    }else{
                         SVProgressHUD.dismiss()
                        alert(title: "", msg: json[MSG]as! String)
                    }
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
    
    @IBAction func buttonCheckUncheck(_ sender: Any) {
        if self.isCheck{
            self.isCheck = false
            self.img.image = UIImage.init(named: "checkboxuncheck")
        }else{
            self.isCheck = true
            self.img.image = UIImage.init(named: "checkbox")
        }
    }
    
    
    @IBAction func buttonRead(_ sender: Any) {
        view.endEditing(true)
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TeramsAndConditionVC")as! TeramsAndConditionVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    
    
    
   
}
