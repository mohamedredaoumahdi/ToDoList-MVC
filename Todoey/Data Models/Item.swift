//
//  Item.swift
//  Todoey
//
//  Created by mohamed reda oumahdi on 03/11/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date? = Date()
    @objc dynamic var dueDate: Date? = nil
    @objc dynamic var priorityLevel: Int = 1 // 1=Low, 2=Medium, 3=High
    @objc dynamic var timeEstimate: Int = 0 // Time estimate in minutes
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
