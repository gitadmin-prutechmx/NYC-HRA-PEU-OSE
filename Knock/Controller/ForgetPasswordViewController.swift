//
//  ForgetPasswordViewController.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 7/3/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class ForgetPasswordViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var webVwForget: UIWebView!
    
    override func viewWillAppear(_ animated: Bool)
    {
        //self.navigationController?.navigationBarHidden = false
            self.StyleNavBar()
        
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
//        
//        
//        self.navigationController?.navigationBar.tintColor = UIColor.white
//        
//        
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
//        imageView.contentMode = .scaleAspectFit
//        
//        
//        let image = UIImage(named: "MTXLogoWhite")
//        imageView.image = image
//        self.navigationItem.titleView = imageView
//        
//        
//        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ExitSurvey.png"), style: .plain, target: self, action: #selector(ForgetPasswordViewController.backBtnPressed))
//        self.navigationItem.leftBarButtonItem  = leftBarButtonItem
//http://apple.com
        webVwForget.delegate = self
        
        if let url = URL(string:"http://dev-nyserda-dev.cs43.force.com/Core_Forgot_Password_Page1")
        {
            let request = URLRequest(url: url)
            webVwForget.loadRequest(request)
        }
    }
    
    func StyleNavBar()
    {
        self.navigationController?.isNavigationBarHidden = true
        let newNavBar = UINavigationBar (frame: CGRect(x: 0.0, y: 0.0, width:self.view.bounds.width, height: 64.0))
        
        newNavBar.barStyle = UIBarStyle.black
        newNavBar.tintColor = UIColor.white
        newNavBar.barTintColor =  UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        let newBackbtn = UIButton (frame: CGRect(x:4.0, y: 28.0, width: 90, height: 20))
        
        //newBackbtn.setImage(UIImage.init(named: "ForwardIcon"), for:UIControlState.normal)
        newBackbtn.setTitle("Back", for: .normal)
       newBackbtn.addTarget(self, action: #selector(ForgetPasswordViewController.navigateToLoginView(_:)), for: .touchUpInside)
        
        let titleLabel = UILabel(frame: CGRect(x:0, y:20.0, width:self.view.frame.size.width, height:40))
        titleLabel.text = "FORGOT PASSWORD"
        titleLabel.textColor = UIColor.white
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.init(name: "System", size: 18.0)
        
        
        
        //abutton.setTitle("Test Button", forState: UIControlState.Normal)
        
        
        newNavBar.addSubview(titleLabel)
        newNavBar .addSubview(newBackbtn)
        
        
        self.view .addSubview(newNavBar)
        
        
    }
    
    func navigateToLoginView(_ sender: AnyObject?)
    {
//        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "loginIdentfier") as? LoginViewController
//        self.navigationController?.pushViewController(viewController!, animated: true)
        self.navigationController!.popViewController(animated: true)
      
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
