//
//  DataManager.swift
//  WishList
//
//  Created by 이유진 on 4/18/24.
//

import Foundation
import CoreData
import UIKit

class DataManager {
    static let shared = DataManager()
    
    var persistentContainer: NSPersistentContainer?
    var currentProduct: RemoteProduct?
    var products: [Product] = []
    
    private init() {
        self.persistentContainer = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
}

