//
//  DBOperate.swift
//  Todo
//
//  Created by xincun li on 3/8/16.
//  Copyright © 2016 xincun li. All rights reserved.
//

import Foundation
import SQLite

class DBOperate {
    
    static func loadData() {
        do {
            // Connect DB
            let db = try Connection("\(TodoDBParameters.dbPath)/\(TodoDBParameters.dbName)")
            // Create table if it does not exist, and insert default data.
            if !tableExists(db, tableName: TodoDBParameters.tableName) {
                // Create Table if not exist
                try! db.run(TodoDBParameters.todosTable.create { t in
                    t.column(TodoDBParameters.id, primaryKey: true)
                    t.column(TodoDBParameters.image)
                    t.column(TodoDBParameters.title)
                    t.column(TodoDBParameters.date)
                    })
                //Insert default data for demonstrate
                insertDefaultData(db, todosTable: TodoDBParameters.todosTable)
            } else {
                //For Insert Data Test
                //deleteAllData()
                //insertDefaultData(db, todosTable: TodoDBParameters.todosTable)
            }
            for todo in try! db.prepare(TodoDBParameters.todosTable) {
                print("id:\(todo[TodoDBParameters.id]), image: \(todo[TodoDBParameters.image]), title: \(todo[TodoDBParameters.title]), date: \(todo[TodoDBParameters.date])")
                todosArray.append(TodoModel(id: todo[TodoDBParameters.id], image: todo[TodoDBParameters.image], title: todo[TodoDBParameters.title], date: dateFromString(todo[TodoDBParameters.date])))
            }
        }catch {
            print("Database connect failed.")
        }
    }
    
    static func insertDefaultData(db: Connection, todosTable: Table) {
        try! db.run(todosTable.insert(TodoDBParameters.id<-NSUUID().UUIDString, TodoDBParameters.image <- "child-selected",TodoDBParameters.title <- "Go to playground",TodoDBParameters.date <- "03-01-2016 14:00:00"))
        try! db.run(todosTable.insert(TodoDBParameters.id<-NSUUID().UUIDString, TodoDBParameters.image <- "shopping-cart-selected",TodoDBParameters.title <- "Go to shopping",TodoDBParameters.date <- "03-01-2016 14:00:00"))
        try! db.run(todosTable.insert(TodoDBParameters.id<-NSUUID().UUIDString, TodoDBParameters.image <- "phone-selected",TodoDBParameters.title <- "Make a phone call",TodoDBParameters.date <- "03-01-2016 14:00:00"))
        try! db.run(todosTable.insert(TodoDBParameters.id<-NSUUID().UUIDString, TodoDBParameters.image <- "travel-selected",TodoDBParameters.title <- "Travel to Europe",TodoDBParameters.date <- "03-01-2016 14:00:00"))
    }
    
    static func insertData(todo: TodoModel) {        
        do {
            // Connect DB
            let db = try Connection("\(TodoDBParameters.dbPath)/\(TodoDBParameters.dbName)")
            try! db.run(TodoDBParameters.todosTable.insert(TodoDBParameters.id<-todo.id, TodoDBParameters.image <- todo.image, TodoDBParameters.title <- todo.title, TodoDBParameters.date <- stringFromDate(todo.date)))
            
        } catch {
            print("Database connect failed.")
        }
    }
    
    static func updateData(todo: TodoModel) {
        do {
            // Connect DB
            let db = try Connection("\(TodoDBParameters.dbPath)/\(TodoDBParameters.dbName)")
            
            let updateTodo = TodoDBParameters.todosTable.filter(TodoDBParameters.id == todo.id)
            try! db.run(updateTodo.update(TodoDBParameters.image <- todo.image, TodoDBParameters.title <- todo.title, TodoDBParameters.date <- stringFromDate(todo.date)))
            
        } catch {
            print("Database connect failed.")
        }
    }
    
    static func deleteData(todo: TodoModel) {
        do {
            // Connect DB
            let db = try Connection("\(TodoDBParameters.dbPath)/\(TodoDBParameters.dbName)")
            let t = TodoDBParameters.todosTable.filter(TodoDBParameters.id == todo.id)
            try! db.run(t.delete())
        } catch {
            print("Database connect failed.")
        }
    }
    
    
    static func deleteAllData() {
        do {
            // Connect DB
            let db = try Connection("\(TodoDBParameters.dbPath)/\(TodoDBParameters.dbName)")
            try! db.run(TodoDBParameters.todosTable.delete())
        } catch {
            print("Database connect failed.")
        }
    }
    
    static func tableExists(db: Connection, tableName: String) -> Bool {
        let count:Int64 = db.scalar(TodoDBParameters.tableExistSql, tableName
            ) as! Int64
        if count > 0 {
            return true
        } else{
            return false
        }
    }
    
    static func dateFromString(date: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.dateFromString(date)!
    }

    static func stringFromDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.stringFromDate(date)
    }
}


