//
//  CardTaskTableViewCell.swift
//  MAPD714_ToDoApp
//
//  Custom cell view to show the task list in a To Do list.
//

import UIKit

class CardTaskTableViewCell: UITableViewCell {

    @IBOutlet weak var nameTask: UILabel!
    @IBOutlet weak var dayTask: UILabel!
    @IBOutlet weak var hourTask: UILabel!
    @IBOutlet weak var imageTask: UIImageView!
    @IBOutlet weak var descriptionTask: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
