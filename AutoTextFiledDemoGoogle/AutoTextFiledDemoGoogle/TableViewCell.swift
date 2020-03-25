//
//  TableViewCell.swift
//  AutoTextFiledDemoGoogle
//
//  Created by apple on 11/23/19.
//  Copyright © 2019 Zerones. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var lblLocation: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
