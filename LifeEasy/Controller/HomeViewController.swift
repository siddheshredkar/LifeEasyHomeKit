//
//  MainViewController.swift
//  LifeEasy
//
//  Created by Siddhesh Redkar on 09/07/20.
//  Copyright © 2020 Siddhesh Redkar. All rights reserved.
//

import UIKit
import HomeKit




class HomeViewController: UIViewController,addHome {
    
    
    
    
    
    var homes: [HMHome] = []
    let homeManager = HMHomeManager()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        homeManager.delegate = self
    }
    
    
    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavBar()
        
        addHomes(homeManager.homes)
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    //MARK:SetupCollectionView
    
    func setupCollectionView(){
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        
        let itemSpacing:CGFloat = 4
        let itemsInOneLine:CGFloat = 1
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        let width = (UIScreen.main.bounds.size.width - 24) - itemSpacing * CGFloat(itemsInOneLine - 1) //collectionView.frame.width is the not same as  UIScreen.main.bounds.size.width here so we minus 24 for easch side 10 leading and trailing.
        flowLayout.itemSize = CGSize(width: floor(width/itemsInOneLine), height: 200)
        flowLayout.minimumInteritemSpacing = itemSpacing
        flowLayout.minimumLineSpacing = itemSpacing
        self.homeCollectionView.collectionViewLayout = flowLayout
    }
    
    
    
    //MARK:SetupNavBar
    
    func setupNavBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Homes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:#imageLiteral(resourceName: "add-2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(newHome(sender:)))
    }
    
    
    
    func didAddHome(homeName: String, roomName: String) {
        self.homeManager.addHome(withName: homeName) { [weak self] home, error in
            guard let self = self else {
                return
            }
            if let error = error {
                print("Failed to add home: \(error.localizedDescription)")
            }
            if let discoveredHome = home {
                discoveredHome.addRoom(withName: roomName) { _, error  in
                    if let error = error {
                        print("Failed to add room: \(error.localizedDescription)")
                    } else {
                        self.homes.append(discoveredHome)
                        self.homeCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    
    
    
    @objc func newHome(sender: UIBarButtonItem) {
        let vc = navigationController?.storyboard?.instantiateViewController(withIdentifier: "CreateHomeViewController") as! CreateHomeViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    
    
    
    func addHomes(_ homes: [HMHome]) {
        self.homes.removeAll()
        for home in homes {
            self.homes.append(home)
        }
        homeCollectionView.reloadData()
    }
    
    
}


extension HomeViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCell
        cell.home = homes[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let target = navigationController?.storyboard?.instantiateViewController(withIdentifier: "RoomViewController") as! RoomViewController
        target.homeIndex = indexPath.row
        navigationController?.pushViewController(target, animated: true)
    }
    
}


extension HomeViewController: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        addHomes(manager.homes)
    }
}
