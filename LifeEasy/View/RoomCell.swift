//
//  RoomCell.swift
//  LifeEasy
//
//  Created by Siddhesh Redkar on 09/07/20.
//  Copyright © 2020 Siddhesh Redkar. All rights reserved.
//

import Foundation
import UIKit
import HomeKit

class RoomCell: UICollectionViewCell {
    

  @IBOutlet private weak var label: UILabel!
  
  var room: HMRoom? {
    didSet {
      if let room = room {
        label.text = room.name
      }
    }
  }
}
