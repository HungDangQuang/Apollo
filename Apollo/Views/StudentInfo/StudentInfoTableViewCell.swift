//
//  StudentInfoTableViewCell.swift
//  Apollo
//
//  Created by QUANG HUNG on 11/Oct/2021.
//

import UIKit

class StudentInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
