//
//  CourseTableViewCell.swift
//  Apollo
//
//  Created by QUANG HUNG on 08/Oct/2021.
//

import UIKit

class CourseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblCourse: UILabel!
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var lblTeacher: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
