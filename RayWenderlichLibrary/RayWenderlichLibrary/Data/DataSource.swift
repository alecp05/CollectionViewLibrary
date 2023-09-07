//
//  DataSource.swift
//  RayWenderlichLibrary
//
//  Created by Alec on 07.09.23.
//  Copyright © 2023 Ray Wenderlich. All rights reserved.
//

import Foundation

// /////////////////////////////////////////////////////////////////////////
// MARK: - DataSource -
// /////////////////////////////////////////////////////////////////////////

class DataSource {
    
    // /////////////////////////////////////////////////////////////////////////
    // MARK: - Properties
    
    static let shared = DataSource()
    
    var tutorials: [TutorialCollection]
    
    private let decoder = PropertyListDecoder()
    
    private init() {
        guard let url = Bundle.main.url(forResource: "Tutorials", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let tutorials = try? decoder.decode([TutorialCollection].self, from: data) else {
            self.tutorials = []
            return
        }
        
        self.tutorials = tutorials
    }
}
