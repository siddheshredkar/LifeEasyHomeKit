//
//  AccessoryViewController.swift
//  LifeEasy
//
//  Created by Siddhesh Redkar on 08/07/20.
//  Copyright © 2020 Siddhesh Redkar. All rights reserved.
//

import UIKit
import HomeKit




class AccessoryViewController:UIViewController{
    
    
    var accessories: [HMAccessory] = []
    var room: HMRoom?
    var roomIndex = Int()
    var homeIndex = Int()
    
    @IBOutlet weak var accessoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupCollectionView()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadAccessories()
    }
    
    
    //MARK:SetupCollectionView
    
    func setupCollectionView(){
        accessoryCollectionView.delegate = self
        accessoryCollectionView.dataSource = self
        
        let itemSpacing:CGFloat = 4
        let itemsInOneLine:CGFloat = 3
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        let width = (UIScreen.main.bounds.size.width - 24) - itemSpacing * CGFloat(itemsInOneLine - 1) //collectionView.frame.width is the not same as  UIScreen.main.bounds.size.width here so we minus 24 for easch side 10 leading and trailing.
        flowLayout.itemSize = CGSize(width: floor(width/itemsInOneLine), height: floor(width/itemsInOneLine))
        flowLayout.minimumInteritemSpacing = itemSpacing
        flowLayout.minimumLineSpacing = itemSpacing
        self.accessoryCollectionView.collectionViewLayout = flowLayout
    }
    
    
    
    
    
    //MARK:SetupNavBar
    
    func setupNavBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "\(room?.name ?? "") Accessories"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:#imageLiteral(resourceName: "add-2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(addPressed(sender:)))
        
    }
    
    
    func loadAccessories() {
        guard let homeAccessories = room?.accessories else {
            return
        }
        
        for accessory in homeAccessories {
            if let characteristic = accessory.find(serviceType: HMServiceTypeLightbulb, characteristicType: HMCharacteristicMetadataFormatBool) {
                
                accessories.append(accessory)
                accessory.delegate = self
                characteristic.enableNotification(true) { error in
                    if error != nil {
                        print("Something went wrong when enabling notification for a chracteristic.")
                    }
                }
            }
        }
        
        accessoryCollectionView.reloadData()
    }
    
    
}



// MARK: Actions
extension AccessoryViewController {
    @objc fileprivate func addPressed(sender: UIBarButtonItem) {
        let vc = navigationController?.storyboard?.instantiateViewController(withIdentifier: "DiscoveryViewController") as! DiscoveryViewController
        vc.homeindex = homeIndex
        vc.roomIndex = roomIndex
        vc.modalPresentationStyle = .overFullScreen
        
        present(vc, animated: true, completion: nil)
    }
}


extension AccessoryViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accessories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccessoryCell", for: indexPath) as! AccessoryCell
        cell.accessory = accessories[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let accessory = accessories[indexPath.row]
        
        guard let characteristic = accessory.find(serviceType: HMServiceTypeLightbulb, characteristicType: HMCharacteristicMetadataFormatBool) else {
            return
        }
        
        if let toggleState = characteristic.value {
            characteristic.writeValue(NSNumber(value: toggleState as! Bool ? false : true)) { error in
                if error != nil {
                    print("Something went wrong when attempting to update the service characteristic.")
                }
                collectionView.reloadData()
            }
        }else{
            
            
        }
        
    }
    
    
}


extension AccessoryViewController: HMAccessoryDelegate {
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        accessoryCollectionView.reloadData()
    }
}



extension HMAccessory {
    func find(serviceType: String, characteristicType: String) -> HMCharacteristic? {
        return services.lazy
            .filter { $0.serviceType == serviceType }
            .flatMap { $0.characteristics }
            .first { $0.metadata?.format == characteristicType }
    }
}

