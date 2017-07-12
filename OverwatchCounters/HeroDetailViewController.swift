//
//  HeroDetailViewController.swift
//  OverwatchCounters
//
//  Created by Markim Shaw on 7/5/17.
//  Copyright © 2017 Markim Shaw. All rights reserved.
//

import UIKit
import CoreData


func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
  return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}

class HeroDetailViewController: UIViewController {
  
  @IBOutlet weak var topContainerView: UIView!
  @IBOutlet weak var bottomContainerView: UIView!
  var strengthStackView: UIStackView!
  var weaknessStackView: UIStackView!

  weak var hero: HeroMO?
  var heroImageView: UIImageView!
  var imageScale: CGFloat = 0.5
  var managedObjectContext: NSManagedObjectContext!
  var detailInformation: [String: [HeroMO]] = [:]
  
  weak var sharedImageCache: NSCache<NSString, NSData>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Measure.run {
      initialization()
    }
    
    strengthStackView = bottomContainerView.subviews[0].subviews[0] as! UIStackView
    weaknessStackView = bottomContainerView.subviews[0].subviews[0] as! UIStackView
    self.setCircles()
    
    for v in topContainerView.subviews {
      if v is UIImageView {
        heroImageView = v as! UIImageView
        Measure.run(description: "Loading images") {
          self.sharedImageCache == nil ? loadHeroImageFromURL() : loadHeroImageFromCoreData()
        }
      }
    }
    
    Measure.run(description: "Setting up circle images") {
      self.setCircleImages()
    }
  }
  
  fileprivate func initialization() {
    guard let heroName = self.hero?.name, let nav = self.navigationController else { return }
    self.title = heroName
    
    detailInformation["strengths"] = []
    detailInformation["weaknesses"] = []
    
    managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    self.loadStrengthsWeaknesses()
  }
  
  fileprivate func loadHeroImageFromCoreData() {
    guard let hero = self.hero, let heroName = hero.name else { return }
    
    let fetchRequest = NSFetchRequest<HeroMO>(entityName: "Hero")
    let predicate = NSPredicate(format: "name == %@", heroName)
    fetchRequest.predicate = predicate
    
    if let heroObject = try? self.managedObjectContext.fetch(fetchRequest), let hero = heroObject.first, let heroName = hero.name as NSString?, let imageCache = self.sharedImageCache, let imageData = imageCache.object(forKey: heroName) as Data?, let image = UIImage(data: imageData) {
      
      self.heroImageView.image = image
      
      self.heroImageView.frame.size = CGSize(width: image.size.width, height: image.size.height) * self.imageScale
      
      self.heroImageView.center = topContainerView.center
    }
  }
  
  /// Download the hero image from the HeroMO object. Using shared cache it may be simpler to just pull the image from the cache.
  fileprivate func loadHeroImageFromURL() {
    
    guard heroImageView != nil, let h = self.hero, let heroImageURL = h.image, let url = URL(string: heroImageURL) else { return }
    let task = URLSession.shared.dataTask(with: url, completionHandler: {
      [weak self] data, response, error in
      
      guard let d = data, let strongSelf = self else { return }
      if let image = UIImage(data: d) {
        DispatchQueue.main.async {
          strongSelf.heroImageView.image = image
          strongSelf.heroImageView.frame.size = CGSize(width: image.size.width, height: image.size.height) * strongSelf.imageScale
          strongSelf.heroImageView.center = strongSelf.topContainerView.center

        }
      }
    })
    task.resume()
  }
  
  /// Load the weaknesses and strengths HeroMO objects from core data using the [String] in the HeroMO object
  func loadStrengthsWeaknesses() {

    if let h = self.hero, let strengths = h.strengths as? [String] {
      for s in strengths {
        let fetch = NSFetchRequest<HeroMO>(entityName: "Hero")
        let predicate = NSPredicate(format: "name == %@", s)
        fetch.predicate = predicate
        
        if let heroes = try? managedObjectContext.fetch(fetch), let hero = heroes.first {
          detailInformation["strengths"]?.append(hero)
        }
      }
    }
    
    if let h = self.hero, let weaknesses = h.weaknesses as? [String] {
      for w in weaknesses {
        let fetch = NSFetchRequest<HeroMO>(entityName: "Hero")
        let predicate = NSPredicate(format: "name == %@", w)
        fetch.predicate = predicate
        
        if let heroes = try? managedObjectContext.fetch(fetch), let hero = heroes.first {
          detailInformation["weaknesses"]?.append(hero)
        }
      }
    }
  }
  
  fileprivate func setCircles() {
   
    guard let hero = hero,
          let strArray = hero.strengths as? [String],
          let weakArray = hero.weaknesses as? [String]
      else { return }
    
    guard strArray.count <= 3, weakArray.count <= 3 else { return }
    
    if strArray.count < 3 {
      let endIndex = strArray.count
      _ = self.strengthStackView.arrangedSubviews[endIndex...2].map {
        $0.alpha = 0.0
      }
    }
    
    if weakArray.count < 3 {
      let endIndex = weakArray.count
      _ = self.strengthStackView.arrangedSubviews[endIndex...2].map {
        $0.alpha = 0.0
      }
    }
  }
  
  fileprivate func setCircleImages() {
    
    guard let strengthArray = self.detailInformation["strengths"], let weaknessArray = self.detailInformation["weaknesses"] else { return }
    
    guard let strengthStackView = self.bottomContainerView.subviews[0].subviews[0] as? UIStackView,
          let weaknessStackView = self.bottomContainerView.subviews[0].subviews[1] as? UIStackView
      else { return }
    
    loadCircleImages(from: strengthArray, for: strengthStackView)
    //embeddedFunction(weaknessArray, weaknessStackView)

//    for (index, value) in strengthArray.enumerated() {
//      guard let name = value.name as NSString?,
//            let imageCache = self.sharedImageCache
//      else { return }
//      
//      let circle = strengthStackView.arrangedSubviews[index] as! HeroCircleView
//      circle.heroLabel.text = name as String
//      
//      var image: UIImage?
//      //If the image data exists them load it from the cache. If not then download the image with URLSession.shared
//      if checkIfImageDataExists(name: name) {
//        image = UIImage(data: imageCache.object(forKey: name)! as Data)
//        circle.imageView.frame.size = image!.size
//        circle.imageView.image = image
//        
//      } else {
//        let heroURL = URL(string: strengthArray[index].image!)
//        let task = URLSession.shared.dataTask(with: heroURL!, completionHandler: {
//          [weak self] data, response, error in
//          
//          guard let strongSelf = self,
//                let data = data
//          else { return }
//          let image = UIImage(data: data)
//          
//          DispatchQueue.main.async {
//            circle.imageView.image = image
//          }
//        })
//        task.resume()
//      }
//      
//      
//    }
  }
  
  func loadCircleImages(from array: [HeroMO], for stackView: UIStackView) {
    for (index, value) in array.enumerated() {
      guard let name = value.name as NSString?,
        let imageCache = self.sharedImageCache
        else { return }
      
      let circle = stackView.arrangedSubviews[index] as! HeroCircleView
      circle.heroLabel.text = name as String
      
      var image: UIImage?
      //If the image data exists them load it from the cache. If not then download the image with URLSession.shared
      if checkIfImageDataExists(name: name) {
        image = UIImage(data: imageCache.object(forKey: name)! as Data)
        circle.imageView.frame.size = image!.size
        circle.imageView.image = image
        
      } else {
        let heroURL = URL(string: array[index].image!)
        let task = URLSession.shared.dataTask(with: heroURL!, completionHandler: {
          [weak self] data, response, error in
          
          guard let strongSelf = self,
            let data = data
            else { return }
          let image = UIImage(data: data)
          
          DispatchQueue.main.async {
            circle.imageView.image = image
          }
        })
        task.resume()
      }
    }
  }
  
  fileprivate func checkIfImageDataExists(name: NSString) -> Bool {
    guard let imageCache = self.sharedImageCache else { return false }
    if imageCache.object(forKey: name) != nil {
      return true
    }
    
    return false
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    if self.sharedImageCache != nil {
      self.sharedImageCache!.removeAllObjects()

    }
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */

}
