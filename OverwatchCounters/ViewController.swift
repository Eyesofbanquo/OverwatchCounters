//
//  ViewController.swift
//  OverwatchCounters
//
//  Created by Markim Shaw on 6/21/17.
//  Copyright © 2017 Markim Shaw. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<HeroMO>(entityName: "Hero")
    
    do {
      let results = try context.fetch(fetchRequest)
      for r in results {
        print(r.name)
      }

    } catch {
      
    }
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

