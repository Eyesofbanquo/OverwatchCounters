//
//  DataController.swift
//  OverwatchCounters
//
//  Created by Markim Shaw on 7/2/17.
//  Copyright © 2017 Markim Shaw. All rights reserved.
//

import Foundation
import CoreData

class DataController: NSObject {
  
  var available: Bool = false

  private(set) var managedContext: NSManagedObjectContext!
  
  init(completionHandler: @escaping () -> ()?) {
    super.init()
    
    let container: NSPersistentContainer = NSPersistentContainer(name: "OWCounters")
    
    DispatchQueue.global(qos: .background).async {
      [weak self] in
      container.loadPersistentStores(completionHandler: {
         description, error in
        
        DispatchQueue.main.async {
          self?.available = true
          self?.managedContext = container.viewContext
          completionHandler()
        }
        
      })
    }
    
  }
}
