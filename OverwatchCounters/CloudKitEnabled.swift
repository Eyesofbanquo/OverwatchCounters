//
//  CloudKitEnabled.swift
//  OverwatchCounters
//
//  Created by Markim Shaw on 7/22/17.
//  Copyright © 2017 Markim Shaw. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreData

protocol CloudKitEnabled: class {
  var recordName: String { get set }
  var activityView: UIActivityIndicatorView! { get set }
}

extension CloudKitEnabled where Self: UIViewController {
  func cloudKitConnect() {
    let container = CKContainer.default()
    let db = container.publicCloudDatabase
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: recordName, predicate: predicate)
    
    self.activityView.startAnimating()
    
    db.perform(query, inZoneWith: nil, completionHandler: {
      records, error in
      
      if error != nil {
        //Display an alert saying you must enable iCloud account + cloud drive
        print(error!)
        let alert = UIAlertController(title: "iCloud failure", message: "This app uses iCloud to retrieve Overwatch hero information. Please enable iCloud and iCloud Drive then press OK to continue.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: {
          action in
          self.dismiss(animated: true, completion: nil)
        })
        let action2 = UIAlertAction(title: "Ok", style: .default, handler: {
          action in
          self.cloudKitConnect()
          return
        })
        alert.addAction(action)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
        return
      }
      
      guard let heroes = records else { return }
      
      DispatchQueue.global(qos: .background).async {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = context.persistentStoreCoordinator
        
        var hs: [HeroMO] = []
        
        moc.perform {
          for hero in heroes {
            let h = HeroMO(context: context)
            h.name = hero.object(forKey: "name") as? String
            h.image = (hero.object(forKey: "image") as! CKAsset).fileURL.absoluteString as? String
            let rowPosition = Position(context: context)
            let rp = hero.object(forKey: "rowPosition") as! [Double]
            rowPosition.x = rp[0]
            rowPosition.y = rp[1]
            rowPosition.width = rp[2]
            rowPosition.height = rp[3]
            
            let circlePosition = Position(context: context)
            let cp = hero.object(forKey: "circlePosition") as! [Double]
            circlePosition.x = cp[0]
            circlePosition.y = cp[1]
            circlePosition.width = cp[2]
            circlePosition.height = cp[3]
            
            h.rowPosition = rowPosition
            //h.circlePosition = rowPosition
            h.circlePosition = circlePosition
            
            let colors = hero.object(forKey: "colors") as! [String]
            var convertedColors = [UIColor]()
            for c in colors {
              convertedColors.append(UIColor(hexString: c)!)
            }
            h.colors = convertedColors as! NSArray
            
            if hero.object(forKey: "strengths") == nil {
              h.strengths = nil
            } else {
              h.strengths = hero.object(forKey: "strengths") as! NSArray
            }
            
            if hero.object(forKey: "weaknesses") == nil {
              h.weaknesses = nil
            } else {
              h.weaknesses = hero.object(forKey: "weaknesses") as! NSArray
            }
            hs.append(h)
          }
          
          do {
            //Using any Managed Object Context will allow this information to only persist during the lifetime of this app
            //Using the MOC from the App Delegate will allow this information to persist much longer
            try moc.save()
            
            DispatchQueue.main.async {
              //Stop the actiivty animation
              self.activityView.stopAnimating()
              
              let destinationStoryboard = UIStoryboard(name: "MainScreen", bundle: nil)
              //let destination = destinationStoryboard.instantiateViewController(withIdentifier: "MainScreen") as! MainScreenViewController
              let destination = destinationStoryboard.instantiateViewController(withIdentifier: "NavigationMainScreen") as! UINavigationController
              let vc = destination.viewControllers[0] as! MainScreenViewController
              vc.heroes = hs
              
              self.present(destination, animated: true, completion: nil)
            }
          } catch {
            
          }
          
        }
        
      }
    })
  }
}
