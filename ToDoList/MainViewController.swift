//
//  ViewController.swift
//  ToDoList
//
//  Created by Виктория Федосова on 19.04.2022.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDataSource {
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self,
                    forCellReuseIdentifier: "cell")
        return table
    }()
    
    var item = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ("Cегодня: \(Date().formatted(.dateTime.month(.wide).year().day()))")
        table.dataSource = self
        navigationItem.rightBarButtonItem  = UIBarButtonItem (barButtonSystemItem: .add,
                                                              target: self,
                                                              action: #selector(didTapAdd))
        view.addSubview(table)
        
    }
    ///загружаем на экран тейблвью и ставим разер под размер экрана
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
         print(item)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            item = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
    }
  
    /// отвечается за окошка ввода текста
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "Новая задача",
                                      message: "Введите новую задачу!",
                                      preferredStyle: .alert)
    
        alert.addTextField{ field in
            field.placeholder = "... "
        }
        alert.addAction(UIAlertAction(title: "Выход", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Готово", style: .default, handler: { [weak self]
            (_) in //когда нажата кнопка done переходим к сохранению
            if let field = alert.textFields?.first { ///разворачиваем  textfield
                if let text = field.text, !text.isEmpty { //проверяем не пустой ли
                    DispatchQueue.main.async {
                        var currentItem = UserDefaults.standard.stringArray(forKey: "item") ?? []
                        UserDefaults.standard.setValue(currentItem,
                                                       forKey: "item") ///save enter in array
                        self?.saveTask(title: text)
                        self?.table.reloadData()
                    }
                }
            }
        }))
        present(alert, animated: true)
    }
    
    private func saveTask(title: String ) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task",
                                                      in: context) else {return}
        let taskObject = Task(entity: entity, insertInto: context)
        taskObject.task = title
        
        do {
            try context.save()
            item.append(taskObject)
            
        } catch let error as NSError {
            print(error)
        }
         
    }
    
    func loadAllNotes() -> [Task] {
        do {
            item = try context.fetch(Task.fetchRequest())
        } catch {
            print(error.localizedDescription)
        }
        return item
    }
    
    // 2. регестрируем колличество ячеек по размеру массива элементов
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return item.count
    }
    // 3. регестрируем прототип ячейки
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = item[indexPath.row]

        cell.textLabel?.text = task.task//загрузка я ческий значений на последней позиции
        return cell
    }
    
    func tableView(_ tableView: UITableView,
         editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete ///
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            item.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            guard let entity = NSEntityDescription.entity(forEntityName: "Task",
                                                        in: context) else {return}
            let data = loadAllNotes()[indexPath.row]
            context.delete(data)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
            tableView.endUpdates()
        }
        return
    }
    
    
}

