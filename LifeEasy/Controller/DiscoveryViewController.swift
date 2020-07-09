//
//  DiscoveryViewController.swift
//  LifeEasy
//
//  Created by Siddhesh Redkar on 09/07/20.
//  Copyright © 2020 Siddhesh Redkar. All rights reserved.
//

import UIKit
import HomeKit





class DiscoveryViewController: UIViewController {
    let homeManager = HMHomeManager()
    let browser = HMAccessoryBrowser()
    var accessories = [HMAccessory]()
    var timer: Timer?
    
    var homeindex = Int()
    var roomIndex = Int()
    
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var realoadBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        setupCollectionView()
        setupBrowser()
        realoadBtn.addTarget(self, action: #selector(startSearching), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        
    }
    
    
    
    @objc func dismissView(){
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension DiscoveryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accessories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccessoryCell", for: indexPath) as! AccessoryCell
        cell.accessory = accessories[indexPath.row]
        
        return cell
    }
}

extension DiscoveryViewController: UICollectionViewDelegate {
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let home = homeManager.homes[homeindex]  as HMHome? else { return }
        if let room = home.rooms[roomIndex] as HMRoom? {
            let accessory = accessories[indexPath.row] as HMAccessory
            home.addAccessory(accessory) { error in
                guard error == nil else { return print("Couldn't add accessory to home. Error: \(String(describing: error?.localizedDescription))") }
                home.assignAccessory(accessory, to: room) { error in
                    guard error == nil else { return print("Couldn't add accessory to home. Error: \(String(describing: error?.localizedDescription))") }
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    
}

// MARK: Actions
extension DiscoveryViewController {
    
    @objc fileprivate func startSearching() {
        accessories = []
        if let timer = timer {
            timer.invalidate()
        }
        browser.stopSearchingForNewAccessories()
        titleLbl.text = "Nearby Accessories"
        browser.startSearchingForNewAccessories()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(stopSearching), userInfo: nil, repeats: false)
    }
    
    @objc fileprivate func stopSearching() {
        titleLbl.text = "\(accessories.count) device(s) found"
        browser.stopSearchingForNewAccessories()
    }
}

// MARK: Setup
extension DiscoveryViewController {
    
    
    //MARK:SetupCollectionView
    
    
    fileprivate func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let itemSpacing:CGFloat = 4
        let itemsInOneLine:CGFloat = 4
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        let width = (UIScreen.main.bounds.size.width - 24) - itemSpacing * CGFloat(itemsInOneLine - 1) //collectionView.frame.width is the not same as  UIScreen.main.bounds.size.width here so we minus 24 for easch side 10 leading and trailing.
        flowLayout.itemSize = CGSize(width: floor(width/itemsInOneLine), height: floor(width/itemsInOneLine))
        flowLayout.minimumInteritemSpacing = itemSpacing
        flowLayout.minimumLineSpacing = itemSpacing
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    fileprivate func setupBrowser() {
        browser.delegate = self
        startSearching()
    }
}

// MARK: HMAccessoryBrowserDelegate
extension DiscoveryViewController: HMAccessoryBrowserDelegate {
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        accessories.append(accessory)
        collectionView.reloadData()
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        accessories.remove(at: 0)
        collectionView.reloadData()
    }
    
    
}


