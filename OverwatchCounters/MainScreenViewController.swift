//
//  MainScreenViewController.swift
//  OverwatchCounters
//
//  Created by Markim Shaw on 7/3/17.
//  Copyright © 2017 Markim Shaw. All rights reserved.
//

import UIKit
import CoreData

class MainScreenViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var fetchController: NSFetchedResultsController<HeroMO>!
  var imageCache: NSCache<NSString, NSData>!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    self.imageCache = NSCache()

    self.initializeFetchController()
    
  }
  
  fileprivate func initializeFetchController() {
    let fetchRequest = NSFetchRequest<HeroMO>(entityName: "Hero")
    let ascending = NSSortDescriptor(key: "name", ascending: true)
    fetchRequest.sortDescriptors = [ascending]
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    self.fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    self.fetchController.delegate = self
    do {
      try self.fetchController.performFetch()
    } catch {
      
    }
    
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let heroCell = sender as? HeroTableViewCell, let indexPath = self.tableView.indexPath(for: heroCell) {
      let heroObject = fetchController.object(at: indexPath)
      let destination = segue.destination as! HeroDetailViewController
      destination.sharedImageCache = self.imageCache
      destination.hero = heroObject
      
    }
  }
  
}

extension MainScreenViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90.0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let hero = self.fetchController.object(at: indexPath)
    let heroStrengths = hero.strengths as! [String]
    let heroWeaknesses = hero.weaknesses as! [String]
    
    print("Hi, I'm \(hero.name!)!\n These are my strengths: \(heroStrengths)\nThese are my weaknesses: \(heroWeaknesses)")
    
  }
}

extension MainScreenViewController: NSFetchedResultsControllerDelegate {
  
}

extension MainScreenViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let heroCell = tableView.dequeueReusableCell(withIdentifier: "hero_cell", for: indexPath) as! HeroTableViewCell
    let hero = self.fetchController.object(at: indexPath)
    
    heroCell.name.text = hero.name ?? "no name"

    heroCell.prepareForReuse()
    
    guard let imageString = hero.image,
          let url = URL(string: imageString),
          let heroName = hero.name
      else { return UITableViewCell() }
    
    if imageCache.object(forKey: heroName as NSString) == nil {
      
      let session = URLSession.shared
      let task = session.dataTask(with: url, completionHandler: {
        data, response, error in
        
        guard let data = data else { return }
        
        self.imageCache.setObject(data as NSData, forKey: heroName as NSString)
        
        let image = UIImage(data: data)
        
        DispatchQueue.main.async {
          
          heroCell.heroImage.image = image
        }
      })
      task.resume()
    } else {
      let image = UIImage(data: imageCache.object(forKey: heroName as NSString) as! Data)
      heroCell.heroImage.image = image
    }
    
    guard let x = hero.rowPosition?.x, let y = hero.rowPosition?.y, let width = hero.rowPosition?.width, let height = hero.rowPosition?.height else { return  UITableViewCell() }
    heroCell.heroImage.frame = CGRect(x: x, y: y, width: width, height: height)
    heroCell.name.textColor = .white

    return heroCell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sections = fetchController.sections else { return 0 }
    let sectionInfo = sections[section]
    return sectionInfo.numberOfObjects
  }
}
