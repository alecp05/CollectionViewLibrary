//
//  BadgeSupplementaryView.swift
//  RayWenderlichLibrary
//
//  Created by Alec on 08.09.23.
//  Copyright © 2023 Ray Wenderlich. All rights reserved.
//

import UIKit

// /////////////////////////////////////////////////////////////////////////
// MARK: - BadgeSupplementaryView -
// /////////////////////////////////////////////////////////////////////////

final class BadgeSupplementaryView: UICollectionReusableView {
    
    // /////////////////////////////////////////////////////////////////////////
    // MARK: - Properties
    
    static let reuseIdentifier = String(describing:  BadgeSupplementaryView.self)
    
    // /////////////////////////////////////////////////////////////////////////
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        self.backgroundColor = UIColor(named: "rw-green")
        let radius = self.bounds.width / 2.0
        self.layer.cornerRadius = radius
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

