//
//  CategoryInputViewController.swift
//  taskapp2
//
//  Created by 落合克彦 on 2021/06/02.
//

import UIKit
import RealmSwift

class CategoryInputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBAction func addCategory(_ sender: Any) {
        self.registCategory()
    }
    
    let realm = try! Realm()
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "categoryId", ascending: true)
    var category: Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Cellに値を設定する.
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.categoryName
        cell.detailTextLabel?.text = category.categoryId.description

        return cell
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.categoryArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func registCategory(){
        
        let category = Category()
        let allCategorys = realm.objects(Category.self)
        if allCategorys.count != 0 {
            category.categoryId = allCategorys.max(ofProperty: "categoryId")! + 1
        }
        category.categoryName = self.categoryTextField.text!
        
        try! realm.write {
            self.realm.add(category, update: .modified)
        }
        tableView.reloadData()
    }

}
