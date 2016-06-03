//
//  TodoModel.swift
//  Todo
//  Created by Xincun Li on 02/24/2016.
//  Copyright (c) 2016 Xincun Li. All rights reserved.
//

import Foundation

class TodoModel : NSObject{
    var id: String
    var image: String
    var title: String
    var date: NSDate
    
    init (id: String, image: String, title: String, date: NSDate) {
        self.id = id
        self.image = image
        self.title = title
        self.date = date
    }
}

/*
struct TodoModel{
    var id: String
    var image: String
    var title: String
    var date: NSDate
}
*/