//
//  IntroductionVC.swift
//  NacPay
//
//  Created by Maulik Desai on 8/11/17.
//  Copyright © 2017 Maulik Desai. All rights reserved.
//

import UIKit
import SVProgressHUD
import AFNetworking


class IntroductionVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var btnSkip: UIButton!
    
     var arrayOfNames:NSMutableArray=["Introduction1","Introduction2","Introduction3","Introduction4","Introduction5","Introduction6"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide navigation bar
        self.navigationController?.isNavigationBarHidden = true
        
        if UserDefaults.standard.value(forKey: IS_LOGIN) != nil{
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupPINVC")as! SetupPINVC
            nextVC.isLogin = true
            self.navigationController?.pushViewController(nextVC, animated: false)
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: CollectionView Method
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
        
        let images = cell.viewWithTag(1) as! UIImageView
        images.image=UIImage(named: arrayOfNames[indexPath.row] as! String)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.row
        if indexPath.row == 5{
            self.btnSkip.setTitle("Done", for: .normal)
        }else{
            self.btnSkip.setTitle("Skip", for: .normal)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    

    @IBAction func buttonSkip(_ sender: UIButton) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyPhoneVC")as! VerifyPhoneVC
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    

}
