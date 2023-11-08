//
//  Category.swift
//  Todoey
//
//  Created by mohamed reda oumahdi on 03/11/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
