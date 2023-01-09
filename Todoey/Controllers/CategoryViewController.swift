import UIKit
import RealmSwift

class CategoryViewController: SwipeTableViewController {
    let realm = try? Realm()
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        print(Realm.Configuration.defaultConfiguration.fileURL)
        loadCategory()
    }

    func loadCategory(){
        categories = realm?.objects(Category.self)
        tableView.reloadData()
    }

    func save(category: Category) {
        do {
            try realm?.write {
                realm?.add(category)
                tableView.reloadData()
            }
                print("saving...")

        } catch {
            print("Error saving context")
        }
    }

    //DELETE DATA FROM SWIPE
    
    override func updateModel(at indexPath: IndexPath){
        if let categoriesToDelete = self.categories?[indexPath.row] {
            do {
                try self.realm?.write {
                    self.realm?.delete(categoriesToDelete)
                }
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()

        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            if let category = textfield.text {
                let newCategory = Category()
                    newCategory.name = category
                    self.save(category: newCategory)
            }
        }

        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Create new Item"
            textfield = alertTextfield
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

//MARK: - TableView Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView,cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Category Added Yet"
        return cell
    }

//MARK: - TableView Delegates

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? TodoListViewController

        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC?.selectedCategory = categories?[indexPath.row]
        }
    }

}
