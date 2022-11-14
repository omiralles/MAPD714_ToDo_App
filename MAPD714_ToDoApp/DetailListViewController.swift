//
//  DetailListViewController.swift
//  MAPD714_ToDoApp
//
//  ViewController to show detailed list information.
//  Here you can specify name description and category.
//

import UIKit

class DetailListViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var titleLabel: UITextField!
    @IBOutlet var texDescription: UITextView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerViewH: UIPickerView!
    
    //Category list
    var list = ["Things to do", "Groceries", "Home", "Sopping", "Custom"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Delegate and datasource for pickerViews
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerViewH.delegate = self
        self.pickerViewH.dataSource = self

        //Elements border configuration
        self.pickerView.layer.borderWidth = CGFloat(3)
        self.texDescription.layer.borderWidth = CGFloat(3)
        self.titleLabel.layer.borderWidth = CGFloat(3)
        
        //Demo data
        titleLabel.text = "Mechanic"
        texDescription.text = "Mechanic appointment"
        
        //Button to acces to list tasks
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Tasks", style: .done, target: self, action: #selector(ViewTasks))
    
    }
    
    @objc func ViewTasks() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "taskList") as! TaskListViewController
        
        vc.title = "Task List"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
}
