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

class SplashScreenViewController: UIViewController, CloudKitEnabled {
  
  static var storyboardID: String = "SplashScreen"
  var recordName: String = "Hero"
  var activityView: UIActivityIndicatorView!
  
  @IBOutlet weak var leftLoadCircle: CircleView!
  @IBOutlet weak var midLoadCircle: CircleView!
  @IBOutlet weak var rightLoadCircle: CircleView!
  var loadingCircles: [CircleView] {
    return [leftLoadCircle, midLoadCircle, rightLoadCircle]
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()

    self.activityView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    self.activityView.translatesAutoresizingMaskIntoConstraints = false
    
    cloudKitConnect()
    
  }
  
  fileprivate func cloudKitInit() {
    let container = CKContainer.default()
    container.accountStatus(completionHandler: {
      status, error in
      
      if case CKAccountStatus.available = status {
        self.cloudKitConnect()
      } else {
        //self.dismiss
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
    
    //Add the activity view to the screen
    self.view.addSubview(self.activityView)
    self.activityView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.activityView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    
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
