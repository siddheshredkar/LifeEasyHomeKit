//
//  HomeCell.swift
//  LifeEasy
//
//  Created by Siddhesh Redkar on 08/07/20.
//  Copyright © 2020 Siddhesh Redkar. All rights reserved.
//

import UIKit
import HomeKit

class HomeCell: UICollectionViewCell {
  
  @IBOutlet private weak var label: UILabel!
  
  var home: HMHome? {
    didSet {
      if let home = home {
        label.text = home.name
      }
    }
  }
}
