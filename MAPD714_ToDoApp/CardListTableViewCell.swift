//
//  CardListTableViewCell.swift
//  MAPD714_ToDoApp
//
// Student Name: Carlos Hernandez Galvan
// Student ID: 301290263
//
// Student Name: Oscar Miralles Fernandez
// Student ID: 301250756
//
//  Custom cell to show information category list.
//
//  Personalized cell for to do list tableview


import UIKit

class CardListTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    
    var editListBtnPress: (() -> ())?
    var viewTasksBtnPress: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Edit button function
    @IBAction func EditPressed(_ sender: Any) {
        editListBtnPress?()
    }
    
    //View task button function
    @IBAction func ViewBtnPress(_ sender: Any) {
        viewTasksBtnPress?()
    }
    
}
