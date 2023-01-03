import UIKit
import CoreData
class TodoListViewController: UITableViewController {
    var itemList = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
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
    
 //   MARK - ADD NEW ITEMS
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()

        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let item = textfield.text {
                let newItem = Item(context: self.context)

                newItem.title = item
                newItem.done = false
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
        let request: NSFetchRequest<Item> = Item.fetchRequest()
            do {
           itemList = try context.fetch(request)
            } catch {
                print("error fetching data from context")
            }
        }
    
    func saveItems() {
        do {
            try context.save()
                print("saving...")
            
        } catch {
            print("Error saving context")
        }
        tableView.reloadData()
    }
}



