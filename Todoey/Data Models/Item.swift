//
//  Item.swift
//  Todoey
//
//  Created by mohamed reda oumahdi on 03/11/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
}
