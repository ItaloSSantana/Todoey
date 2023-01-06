//
//  Item.swift
//  Todoey
//
//  Created by Italo on 05/01/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var creation = Date()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
