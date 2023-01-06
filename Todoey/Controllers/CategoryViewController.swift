import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    let realm = try? Realm()
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        print(Realm.Configuration.defaultConfiguration.fileURL)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
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
