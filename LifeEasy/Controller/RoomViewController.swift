//
//  HomeViewController.swift
//  LifeEasy
//
//  Created by Siddhesh Redkar on 08/07/20.
//  Copyright © 2020 Siddhesh Redkar. All rights reserved.
//

import UIKit
import HomeKit

class RoomViewController: UIViewController,addRoom{
    
    
    
    var homeIndex = Int()
    
    let homeManager = HMHomeManager()
    var activeHome: HMHome?
    var activeRoom: HMRoom?
    var rooms: [HMRoom] = []
    
    
    @IBOutlet weak var roomCollectionView: UICollectionView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavBar()
        homeManager.delegate = self
        
        
        
        roomCollectionView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    
    //MARK:SetupCollectionView
    
    func setupCollectionView(){
        roomCollectionView.delegate = self
        roomCollectionView.dataSource = self
        
        let itemSpacing:CGFloat = 4
        let itemsInOneLine:CGFloat = 2
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        let width = (UIScreen.main.bounds.size.width - 24) - itemSpacing * CGFloat(itemsInOneLine - 1) //collectionView.frame.width is the not same as  UIScreen.main.bounds.size.width here so we minus 24 for easch side 10 leading and trailing.
        flowLayout.itemSize = CGSize(width: floor(width/itemsInOneLine), height: floor(width/itemsInOneLine))
        flowLayout.minimumInteritemSpacing = itemSpacing
        flowLayout.minimumLineSpacing = itemSpacing
        self.roomCollectionView.collectionViewLayout = flowLayout
    }
    
    //MARK:SetupNavBar
    
    func setupNavBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Rooms"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:#imageLiteral(resourceName: "add-2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(newRoom(sender:)))
        
    }
    
    
}


extension RoomViewController:UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rooms.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomCell", for: indexPath) as! RoomCell
        cell.room = rooms[indexPath.row]
        return cell
    }
    
    
    
    
}

extension RoomViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        
        
        if let room = rooms[indexPath.row] as HMRoom? {
            
            let vc = navigationController?.storyboard?.instantiateViewController(withIdentifier: "AccessoryViewController") as! AccessoryViewController
            vc.room = room
            vc.roomIndex = indexPath.row
            vc.homeIndex = homeIndex
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}

// MARK: Actions
extension RoomViewController {
    @objc fileprivate func addPressed() {
        
    }
}

// MARK: Setup
extension RoomViewController {
    
    
    
    @objc func newRoom(sender: UIBarButtonItem) {
        let vc = navigationController?.storyboard?.instantiateViewController(withIdentifier: "CreateRoomViewController") as! CreateRoomViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    
    
    
    func didAddRoom(roomName: String) {
        let homes = self.homeManager.homes
        
        guard let selectedHome = homes[self.homeIndex] as HMHome? else {
            print("Something went wrong when attemting to create home.")
            return
        }
        
        selectedHome.addRoom(withName: roomName) { _, error  in
            if let error = error {
                print("Failed to add room: \(error.localizedDescription)")
            } else {
                self.updatePrimaryHome(with: selectedHome)
                self.updateController(with: selectedHome)
                
            }
        }
        
        
    }
    
    
    
}

// MARK: Helpers
extension RoomViewController {
    fileprivate func updateController(with home: HMHome) {
        
        guard let rooms = home.rooms as [HMRoom]? else { return }
        self.rooms = rooms
        roomCollectionView.reloadData()
        
    }
    
    fileprivate func addRoom(to home: HMHome) {
        home.addRoom(withName: "Presentation Room") { room, error in
            guard error == nil else { return print("Couldn't create room. Error: \(String(describing: error?.localizedDescription))") }
            self.updateController(with: home)
        }
    }
    
    fileprivate func updatePrimaryHome(with home: HMHome) {
        homeManager.updatePrimaryHome(home) { error in
            guard error == nil else { return print("Couldn't update primary home. Error: \(String(describing: error?.localizedDescription))") }
        }
        
    }
}

extension RoomViewController: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        let homes = manager.homes
        
        guard let selectedHome = homes[homeIndex] as HMHome? else {
            print("Something went wrong when attemting to create home.")
            return
        }
        
        activeHome = selectedHome
        updateController(with: selectedHome)
        
        
    }
}



