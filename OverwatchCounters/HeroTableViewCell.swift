//
//  HeroTableViewCell.swift
//  OverwatchCounters
//
//  Created by Markim Shaw on 7/3/17.
//  Copyright © 2017 Markim Shaw. All rights reserved.
//

import UIKit

class HeroTableViewCell: UITableViewCell {
  
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var heroImage: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  /*func loadImage(_ hero: HeroMO){
    let session = URLSession.shared
    let task = session.dataTask(with: URL(string:hero.image!)!, completionHandler: {
      data, response, error in
      let image = UIImage(data: data!)
      DispatchQueue.main.async {
        self.heroImage.image = image
      }
    })
    task.resume()
  }*/
  
  override func prepareForReuse() {
    self.heroImage.image = nil
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
