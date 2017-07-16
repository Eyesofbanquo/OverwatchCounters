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
    
    self.strengthStackView = bottomContainerView.subviews[0].subviews[0] as! UIStackView
    self.weaknessStackView = bottomContainerView.subviews[0].subviews[0] as! UIStackView
    
    Measure.run {
      initialization()
    }
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    

    self.strengthStackView.layoutIfNeeded()
    self.weaknessStackView.layoutIfNeeded()
    self.setCircleVisibility()
    
    for v in topContainerView.subviews {
      if v is UIImageView {
        heroImageView = v as! UIImageView
        Measure.run(description: "Loading images") {
          setHeroFeaturedImage()
        }
      }
    }
    
    Measure.run(description: "Setting up circle images") {
      self.setCircleImages()
    }
  }
  
  fileprivate func initialization() {
    guard let heroName = self.hero?.name else { return }
    self.title = heroName
    
    detailInformation["strengths"] = []
    detailInformation["weaknesses"] = []
    
    managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    self.loadStrengthsWeaknesses()
  }
  
  /// Sets the image for the top view container
  fileprivate func setHeroFeaturedImage() {
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
  
  /// Set which circles in the stack view are visible
  fileprivate func setCircleVisibility() {
   
    /*guard let hero = hero,
          let strArray = hero.strengths as? [String],
          let weakArray = hero.weaknesses as? [String]
      else { return }*/
    let hero = self.hero!
    var strArray: [String]
    var weakArray: [String]
    
    if hero.strengths == nil {
      strArray = []
      let frameWithinStackView = self.strengthStackView.frame
      let convertedFrame = self.view.convert(frameWithinStackView, from: self.strengthStackView.superview!)
      let view = UIView(frame: convertedFrame)
      view.backgroundColor = .red
      self.view.addSubview(view)
      //self.view.insertSubview(view, aboveSubview: self.strengthStackView)
    } else {
      strArray = hero.strengths as! [String]
    }
    
    if hero.weaknesses == nil {
      weakArray = []
      let frameWithinStackView = self.weaknessStackView.frame
      let convertedFrame = self.view.convert(frameWithinStackView, from: self.weaknessStackView.superview!)
      let view = UIView(frame: convertedFrame)
      view.backgroundColor = .blue
      self.view.addSubview(view)
    } else {
      weakArray = hero.weaknesses as! [String]
    }
    
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
    //loadCircleImages(weaknessArray, weaknessStackView)
  }
  
  func loadCircleImages(from array: [HeroMO], for stackView: UIStackView) {
    for (index, hero) in array.enumerated() {
      guard let name = hero.name as NSString?,
            let position = hero.circlePosition,
            let imageCache = self.sharedImageCache
      else { return }
      
      let circle = stackView.arrangedSubviews[index] as! HeroCircleView
      //circle.layoutIfNeeded()
      circle.heroLabel.text = name as String
      
      var image: UIImage?
      //If the image data exists them load it from the cache. If not then download the image with URLSession.shared
      if checkIfImageDataExists(name: name) {
        image = UIImage(data: imageCache.object(forKey: name)! as Data)
        circle.imageView.frame.size = image!.size
        circle.imageView.image = image
        circle.imageView.frame = CGRect(x: position.x, y: position.y, width: position.width, height: position.height)
        
      } else {
        let heroURL = URL(string: array[index].image!)
        let task = URLSession.shared.dataTask(with: heroURL!, completionHandler: {
          data, response, error in
          
          guard let data = data,
                let image = UIImage(data: data)
          else { return }
          
          
          DispatchQueue.main.async {
            circle.imageView.frame.size = image.size
            circle.imageView.image = image
            circle.imageView.frame = CGRect(x: position.x, y: position.y, width: position.width, height: position.height)
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

}
