//
//  CreateHomeViewController.swift
//  LifeEasy
//
//  Created by Siddhesh Redkar on 09/07/20.
//  Copyright © 2020 Siddhesh Redkar. All rights reserved.
//

import UIKit

protocol addHome {
    func didAddHome(homeName:String,roomName:String)
}

class CreateHomeViewController: UIViewController {
    
    @IBOutlet weak var homeNameTf: UITextField!
    @IBOutlet weak var roomNameTf: UITextField!
    
    
    @IBOutlet weak var AddBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    var delegate: addHome? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AddBtn.layer.cornerRadius = 15
        cancelBtn.layer.cornerRadius = 15
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor.lightGray.cgColor
        
        AddBtn.addTarget(self, action: #selector(createPress(_:)), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }
    
    
    @objc func createPress(_ sender: UIButton) {
        
        if self.delegate != nil && self.homeNameTf.text != nil && self.roomNameTf.text != nil {
            guard let homeName = self.homeNameTf.text else { return print("enter home name") }
            guard let roomName = self.roomNameTf.text else { return print("enter room name") }
            
            self.delegate?.didAddHome(homeName: homeName, roomName: roomName)
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    @objc func dismissVC(){
        dismiss(animated: true, completion: nil)
    }
    
    
}
