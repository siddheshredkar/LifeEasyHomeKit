//
//  CreateRoomViewController.swift
//  LifeEasy
//
//  Created by Siddhesh Redkar on 09/07/20.
//  Copyright © 2020 Siddhesh Redkar. All rights reserved.
//

import UIKit

protocol addRoom {
    func didAddRoom(roomName:String)
}

class CreateRoomViewController: UIViewController {
    
    
    @IBOutlet weak var roomNameTf: UITextField!
    
    
    @IBOutlet weak var AddBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    var delegate: addRoom? = nil
    
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
        
        if self.delegate != nil  && self.roomNameTf.text != nil {
            
            guard let roomName = self.roomNameTf.text else { return print("enter room name") }
            
            self.delegate?.didAddRoom(roomName: roomName)
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    @objc func dismissVC(){
        dismiss(animated: true, completion: nil)
    }
    
    
}

