import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    var itemList: Results<Item>?
    let realm = try? Realm()
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let colourHex = selectedCategory?.color {
            guard let navBar = navigationController?.navigationBar else {fatalError("nav dont esxist")}
            if let navBarColour = UIColor(hexString: colourHex) {
            navBar.barTintColor = navBarColour
            title = selectedCategory?.name
            searchBar.barTintColor = navBarColour
            navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70.0
        tableView.separatorStyle = .none
      
        searchBar.delegate = self
    }
    
    func loadItems(){
        
        itemList = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemToDelete = itemList?[indexPath.row] {
            do {
                try self.realm?.write {
                    self.realm?.delete(itemToDelete)
                }
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            do {
                try self.realm?.write{
                    if let item = textfield.text {
                        let newItem = Item()
                        newItem.title = item
                        newItem.dateCreated = Date()
                        if let currentCategory = self.selectedCategory {
                            currentCategory.items.append(newItem)
                        }
                    }
                    self.tableView.reloadData()
                }
            } catch {
                print(error)
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
            itemList = itemList?.filter("title CONTAINS[cd] %@", safeText).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
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
        guard let list = itemList?.count else {return 0}
        return list
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = itemList?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let itemCount = itemList?.count {
                if let categoryColor = selectedCategory?.color {
                    if let colour = UIColor(hexString: categoryColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemCount)) {
                        cell.backgroundColor = colour
                        cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
                    }
                }
            }
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added Yet"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = itemList?[indexPath.row] {
            do {
                try realm?.write {
                    item.done = !item.done
                }
            } catch {
                print(error)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
}
