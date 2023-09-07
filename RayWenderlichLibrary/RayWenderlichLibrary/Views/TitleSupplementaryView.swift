//
//  TitleSupplementaryView.swift
//  RayWenderlichLibrary
//
//  Created by Alec on 07.09.23.
//  Copyright © 2023 Ray Wenderlich. All rights reserved.
//

import UIKit
import SnapKit

// /////////////////////////////////////////////////////////////////////////
// MARK: - TitleSupplementaryView -
// /////////////////////////////////////////////////////////////////////////

final class TitleSupplementaryView: UICollectionReusableView {
    
    // /////////////////////////////////////////////////////////////////////////
    // MARK: - Properties
    
    static let reuseIdentifier = String(describing: TitleSupplementaryView.self)
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        return label
    }()
    
    // /////////////////////////////////////////////////////////////////////////
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.textLabel)
        self.makeConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        
        self.textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
}
