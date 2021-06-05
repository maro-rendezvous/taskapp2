//
//  ViewController.swift
//  taskapp2
//
//  Created by 落合克彦 on 2021/05/30.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBAction func categoryClear(_ sender: Any) {
        categoryTextField.text = ""
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        tableView.reloadData()
    }
    
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    var category: Category!
    
    var pickerView: UIPickerView = UIPickerView()

    var list: [String] = []
    
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // ピッカー設定
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // インプットビュー設定
        categoryTextField.inputView = pickerView
        categoryTextField.inputAccessoryView = toolbar
        
        list.removeAll()
        let allCategorys = realm.objects(Category.self)
        for category in allCategorys {
            list.append(category.categoryId.description + ":" + category.categoryName)
        }
    }
    
    // 決定ボタン押下
    @objc func done() {
        categoryTextField.endEditing(true)
        categoryTextField.text = "\(list[pickerView.selectedRow(inComponent: 0)])"
        let categoryIdArr = self.categoryTextField.text?.components(separatedBy: ":")
        let categoryId = Int(categoryIdArr![0]) ?? 1
        taskArray = taskArray.filter("categoryId == %@", categoryId)
        tableView.reloadData()

    }
    
    // ドラムロールの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // ドラムロールの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    // ドラムロールの各タイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Cellに値を設定する.
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString

        return cell
    }
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil) 
    }
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここから ---
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        } // --- ここまで変更 ---
    }
    
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController

        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }

    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        list.removeAll()
        let allCategorys = realm.objects(Category.self)
        for category in allCategorys {
            list.append(category.categoryId.description + ":" + category.categoryName)
        }
    }
}

