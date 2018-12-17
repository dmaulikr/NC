//
//  VerifyCompleteVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit

class VerifyCompleteVC: UIViewController {
    
    
    @IBOutlet weak var lblPhoneNumber: UILabel!
    
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl1Height: NSLayoutConstraint!
    @IBOutlet weak var lbl2Height: NSLayoutConstraint!
    @IBOutlet weak var btnSetupPin: UIButton!
    @IBOutlet weak var lblSetupPin: UILabel!
    @IBOutlet weak var lbl3TopSpace: NSLayoutConstraint!
    @IBOutlet weak var btnSetupPinWidth: NSLayoutConstraint!
        
    var phoneNumber = String()
    var isPinSet = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation title
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        lblTitle.text  = "PHONE NUMBER VERIFIED"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.init(hexString: "FFD700")
        lblTitle.font = UIFont.init(name: "Lato-Medium", size: 14)
        self.navigationItem.titleView = lblTitle
        
        //show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1348470002, green: 0.1348470002, blue: 0.1348470002, alpha: 1)
        
        //hide back button of navigation bar
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        //set phoneNumber to lbl
        self.lblPhoneNumber.text = self.phoneNumber
        
        btnSetupPin.layer.cornerRadius = 10
        btnSetupPin.layer.borderWidth = 1
        btnSetupPin.layer.borderColor = UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0, alpha: 1.0).cgColor
        
        
        DispatchQueue.main.async { 
            if self.isPinSet == 1{
                self.lbl1.isHidden = true
                self.lbl2.isHidden = true
                self.lbl1Height.constant = 0
                self.lbl2Height.constant = 0
                self.lblSetupPin.isHidden = true
                self.lbl3TopSpace.constant = 0
                self.btnSetupPin.setTitle("NEXT", for: .normal)
                //self.btnSetupPinWidth.constant = 100
            }
        }
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func buttonSetupAccountPIN(_ sender: UIButton) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
        nextVC.phoneNumber = self.phoneNumber
        nextVC.isPinSet = self.isPinSet
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
}
