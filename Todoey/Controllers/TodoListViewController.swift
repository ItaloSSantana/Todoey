import UIKit
class TodoListViewController: UITableViewController {
    var itemList = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
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
        saveItems()
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
                self.saveItems()
                
            }
        }
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Create new Item"
            textfield = alertTextfield
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        if let safeDataFile = dataFilePath{
            let data = try? Data(contentsOf: safeDataFile)
            let decoder = PropertyListDecoder()
            do {
                guard let safeData = data else {return}
                itemList = try decoder.decode([Item].self, from: safeData)
            } catch {
                print("Error decoding")
            }
        }
    }
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemList)
            if let safeDataFile = dataFilePath {
                try data.write(to: safeDataFile)
            }
           
        } catch {
            print("Error")
        }
        tableView.reloadData()
    }
    
}

	
