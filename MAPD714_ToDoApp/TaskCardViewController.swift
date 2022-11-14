//
//  TaskCardViewController.swift
//  MAPD714_ToDoApp
//
//  ViewController to display detailed task information
//  We can especify a name, description a schedule time-hour and
//  mark a task as done or not.
//

import UIKit

class TaskCardViewController: UIViewController {

    @IBOutlet var nameLabel: UITextField!
    @IBOutlet var texDescription: UITextView!
    @IBOutlet weak var scheduleSwitch: UISwitch!
    @IBOutlet weak var doneSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameLabel.layer.borderWidth = CGFloat(3)
        self.texDescription.layer.borderWidth = CGFloat(3)
        self.datePicker.layer.borderWidth = CGFloat(3)
    }
    
}
