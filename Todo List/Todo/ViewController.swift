//
//  ViewController.swift
//  Todo
//
//  Created by Xincun Li on 02/24/2016.
//  Copyright (c) 2016 Xincun Li. All rights reserved.
//

import UIKit

var todosArray: [TodoModel] = []
var filteredTodos: [TodoModel] = []

class ViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    //var resultSearchController = UISearchController(searchResultsController: nil)
    var resultSearchController: UISearchController!
    
    // MARK - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.active {
            return filteredTodos.count
        }else{
            return todosArray.count
        }
    }
    
    // Display the cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Must use 'self' here because searchResultsTableView needs to reuse the same cell in self.tableView
        let cell = self.tableView.dequeueReusableCellWithIdentifier("todoCell")! as UITableViewCell
        var todo : TodoModel
        
        if self.resultSearchController.active {
            todo = filteredTodos[indexPath.row] as TodoModel
        }else{
            todo = todosArray[indexPath.row] as TodoModel
        }
        
        
        let image = cell.viewWithTag(101) as! UIImageView
        let title = cell.viewWithTag(102) as! UILabel
        let date = cell.viewWithTag(103) as! UILabel
        
        image.image = UIImage(named: todo.image)
        title.text = todo.title
        date.text = DBOperate.stringFromDate(todo.date)
        return cell
        
    }
    
    // MARK - UITableViewDelegate
    // Delete the cell
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            DBOperate.deleteData(todosArray[indexPath.row])
            todosArray.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    // Edit mode
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
    }
    
    // Move the cell
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.editing
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let todo = todosArray.removeAtIndex(sourceIndexPath.row)
        todosArray.insert(todo, atIndex: destinationIndexPath.row)
    }
    
    
    // Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditTodo" {
            let vc = segue.destinationViewController as! DetailViewController
            // var indexPath = tableView.indexPathForCell(sender as UITableViewCell)
            let indexPath = tableView.indexPathForSelectedRow
            if let index = indexPath {
                vc.todo = todosArray[index.row]
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text?.lowercaseString
        
        filteredTodos = todosArray.filter({ (todo) -> Bool in
            let searchtodo: TodoModel = todo
            
            return searchtodo.title.lowercaseString.containsString(searchString!)
        })
        self.tableView.reloadData()
    }
    
    // MARK - Storyboard stuff
    // Unwind
    @IBAction func close(segue: UIStoryboardSegue) {
        print("closed!")
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Initialize data from Sqlite db
        DBOperate.loadData()
        
        navigationItem.leftBarButtonItem = editButtonItem()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.resultSearchController = ({
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.sizeToFit()
            searchController.searchBar.delegate = self
//            searchController.searchBar.barStyle = UIBarStyle.Black
//            searchController.searchBar.barTintColor = UIColor.whiteColor()
//            searchController.searchBar.backgroundColor = UIColor.clearColor()
            searchController.hidesNavigationBarDuringPresentation = true //prevent search bar from moving
            return searchController
        })()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

