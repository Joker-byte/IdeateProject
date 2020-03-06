//
//  IdeaTeItem.swift
//  IdeateProject
//
//  Created by Gianluca Dubioso on 06/03/2020.
//  Copyright © 2020 Gianluca. All rights reserved.
//

import CloudKit



struct IdeateItem : Codable {

    var title:String
    var completed:Bool
    var createdAt:Date
    var itemIdentifier:UUID
    
    func saveItem() {
        DataManager.save(self, with: "\(itemIdentifier.uuidString)")
    }
    
    func deleteItem() {
        DataManager.delete(itemIdentifier.uuidString)
    }
    
    mutating func markAsCompleted(){
        self.completed = true
        DataManager.save(self, with: "\(itemIdentifier.uuidString)")
    }

}




