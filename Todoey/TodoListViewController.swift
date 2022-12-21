import UIKit
class TodoListViewController: UITableViewController {
    let userDefaults = UserDefaults.standard
    var itemList = ["Buy apples", "Buy bananas", "Buy oranges"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadArray()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK - ADD NEW ITEMS
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let item = textfield.text {
                self.itemList.append(item)
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
        if let safeItemList = userDefaults.array(forKey: "ToDoListArray") as? [String] {
            itemList = safeItemList
        }
    }
    
}

	
