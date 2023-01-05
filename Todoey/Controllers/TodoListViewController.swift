import UIKit
import CoreData
class TodoListViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemList = [Item]()
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadItems()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()){
        do {
            if let safeContext = context {
                itemList = try safeContext.fetch(request)
            }
        } catch {
            print("error fetching data from context")
        }
        tableView.reloadData()
    }
    
    func saveItems() {
        do {
            if let safeContext = context {
                try safeContext.save()
                print("saving...")
            }
        } catch {
            print("Error saving context")
        }
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let item = textfield.text {
                if let safeContext = self.context {
                    let newItem = Item(context: safeContext)
                    newItem.title = item
                    newItem.done = false
                    self.itemList.append(newItem)
                    self.saveItems()
                }
            }
        }
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Create new Item"
            textfield = alertTextfield
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
//MARK: - Search Bar Methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let safeText = searchBar.text {
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", safeText)
            request.sortDescriptors  = [NSSortDescriptor(key: "title", ascending: true)]
            loadItems(with: request)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

//MARK: - TableView Delegate/DataSource

extension TodoListViewController {
    
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
        //        if let safeContext = context{
        //            context?.delete(itemList[indexPath.row])
        //            itemList.remove(at: indexPath.row)
        //        }
        itemList[indexPath.row].done = !itemList[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
