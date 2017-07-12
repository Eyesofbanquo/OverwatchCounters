//
//  SplashScreenViewController.swift
//  OverwatchCounters
//
//  Created by Markim Shaw on 6/21/17.
//  Copyright © 2017 Markim Shaw. All rights reserved.
//

import UIKit
import ChameleonFramework
import CloudKit
import CoreData

class SplashScreenViewController: UIViewController {
  
  static var storyboardID: String = "SplashScreen"
  
  @IBOutlet weak var leftLoadCircle: CircleView!
  @IBOutlet weak var midLoadCircle: CircleView!
  @IBOutlet weak var rightLoadCircle: CircleView!
  var loadingCircles: [CircleView] {
    return [leftLoadCircle, midLoadCircle, rightLoadCircle]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    //killSwitch()
    cloudKitConnect()
    
  }
  
  fileprivate func cloudKitConnect() {
    let container = CKContainer.default()
    let db = container.publicCloudDatabase
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: "Hero", predicate: predicate)
    
    
    db.perform(query, inZoneWith: nil, completionHandler: {
      records, error in
      
      if error != nil {
        print("Something terribly wrong has happened")
        return
      }
      
      guard let heroes = records else { return }
      
      DispatchQueue.global(qos: .background).async {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = context.persistentStoreCoordinator
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
            h.circlePosition = rowPosition
            
            if let heroStrengths = hero.object(forKey: "strengths") as? [String], let heroWeaknesses = hero.object(forKey: "weaknesses") as? [String] {
              h.strengths = heroStrengths as NSArray
              h.weaknesses = heroWeaknesses as NSArray
            }
           
          }
          
          do {
            //Using any Managed Object Context will allow this information to only persist during the lifetime of this app
            //Using the MOC from the App Delegate will allow this information to persist much longer
            try moc.save()
            
            DispatchQueue.main.async {
              let destinationStoryboard = UIStoryboard(name: "MainScreen", bundle: nil)
              //let destination = destinationStoryboard.instantiateViewController(withIdentifier: "MainScreen") as! MainScreenViewController
              let destination = destinationStoryboard.instantiateViewController(withIdentifier: "NavigationMainScreen") as! UINavigationController
              self.present(destination, animated: true, completion: nil)
            }
          } catch {
            
          }
          
        }
        
      }
    })
    
  }
  
  fileprivate func killSwitch() {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<HeroMO>(entityName: "Hero")
    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
    
    do {
      try context.execute(batchDeleteRequest)
    } catch {
      fatalError()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    /*let animation = CABasicAnimation(keyPath: "opacity")
    animation.fromValue = 1.0
    animation.toValue = 0.5
    animation.duration = 0.4
    animation.repeatCount = Float.infinity
    loadingCircles[0].layer.add(animation, forKey: "blinking")*/
    
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
}
