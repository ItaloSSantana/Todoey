import UIKit
class TodoListViewController: UITableViewController {
    let userDefaults = UserDefaults.standard
    var itemList = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadArray()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemList[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        itemList[indexPath.row].done = !itemList[indexPath.row].done
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - ADD NEW ITEMS
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let item = textfield.text {
                let newItem = Item()
                newItem.title = item
                self.itemList.append(newItem)
                self.userDefaults.setValue(self.itemList, forKey: "ToDoListArray")
                self.tableView.reloadData()
            }
        }
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Create new Item"
            textfield = alertTextfield
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loadArray() {
        let newItem = Item()
        newItem.title = "Buy Apples"
        itemList.append(newItem)
//        if let safeItemList = userDefaults.array(forKey: "ToDoListArray") as? [String] {
//            itemList = safeItemList
//        }
    }
    
}

	
