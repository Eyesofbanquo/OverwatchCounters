//
//  MainScreenViewController.swift
//  OverwatchCounters
//
//  Created by Markim Shaw on 7/3/17.
//  Copyright © 2017 Markim Shaw. All rights reserved.
//

import UIKit
import ChameleonFramework
import CoreData
import Kingfisher

class MainScreenViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var fetchController: NSFetchedResultsController<HeroMO>!
  var imageCache: NSCache<NSString, UIImage>!
  var previousIndexPath: IndexPath!
  
  var heroes: [HeroMO]?
  var sortedHeroes: [HeroMO]!
  var loadingNextView: Bool = false
    
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setStatusBarStyle(UIStatusBarStyleContrast)
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.separatorStyle = .none
    //self.tableView.prefetchDataSource = self
    
//    self.imageCache = NSCache()

//    self.initializeFetchController()
    self.sortedHeroes = self.heroes!.sorted(by: {
      return $0.0.name! < $0.1.name!
    })
    
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
  
  /*override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }*/
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let heroCell = sender as? HeroTableViewCell, let indexPath = self.tableView.indexPath(for: heroCell) {
//      let heroObject = fetchController.object(at: indexPath)
      let heroObject = sortedHeroes[indexPath.row]
      let destination = segue.destination as! HeroDetailViewController
      //destination.sharedImageCache = self.imageCache
      destination.hero = heroObject      
    }
  }
  
  @IBAction func unwindSegue(segue: UIStoryboardSegue) {
    self.loadingNextView = false
  }
  
}

extension MainScreenViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90.0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! HeroTableViewCell
    let hero = self.sortedHeroes[indexPath.row]
    let colors = hero.colors as! [UIColor]
    //cell.backgroundColor = colors[1]
    tableView.deselectRow(at: indexPath, animated: false)
    self.loadingNextView = true
    
  }
}

extension MainScreenViewController: NSFetchedResultsControllerDelegate {
  
}

extension MainScreenViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let heroCell = tableView.dequeueReusableCell(withIdentifier: "hero_cell", for: indexPath) as! HeroTableViewCell
//    let hero = self.fetchController.object(at: indexPath)
//    let hero = self.heroes!.sorted(by: {
//      return $0.0.name! < $0.1.name!
//    })[indexPath.row]
    let hero = sortedHeroes[indexPath.row]
    
    let colors = hero.colors as! [UIColor]
    
    heroCell.prepareForReuse()
    heroCell.name.text = hero.name ?? "no name"
    heroCell.backgroundColor = colors[0]
    
    guard let imageString = hero.image,
          let url = URL(string: imageString),
          let heroName = hero.name
      else { return UITableViewCell() }
    
//    if imageCache.object(forKey: heroName as NSString) == nil {
//      self.downloader.download(URLRequest(url: url), completion: {
//        response in
//        if let image = response.result.value {
//          heroCell.heroImage.image = image
//          
//          self.imageCache.setObject(response.result.value!, forKey: heroName as NSString)
//          //self.cache.add(image, withIdentifier: heroName)
//        }
//      })
//      //heroCell.heroImage.
//      //self.imageCache.setObject(heroCell.heroImage.image!, forKey: heroName as NSString)
//    } else {
//      heroCell.heroImage.image = imageCache.object(forKey: heroName as NSString)!
//    }
    heroCell.heroImage.kf.setImage(with: url)
    
    
    /*if imageCache.object(forKey: heroName as NSString) == nil {
      
      let session = URLSession.shared
      let task = session.dataTask(with: url, completionHandler: {
        data, response, error in
        
        guard let data = data else { return }
        
        
        let image = UIImage(data: data)
        self.imageCache.setObject(image!, forKey: heroName as NSString)

        
        DispatchQueue.main.async {
          heroCell.heroImage.image = image
        }
      })
      task.resume()
    } else {
      DispatchQueue.global().async {
        let image = self.imageCache.object(forKey: heroName as NSString)!
        DispatchQueue.main.async {
          heroCell.heroImage.image = image
        }
      }
    }*/
    
    guard let x = hero.rowPosition?.x, let y = hero.rowPosition?.y, let width = hero.rowPosition?.width, let height = hero.rowPosition?.height else { return  UITableViewCell() }
    heroCell.heroImage.frame = CGRect(x: x, y: y, width: width, height: height)
    heroCell.name.textColor = .white

    return heroCell
  }
  
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! HeroTableViewCell
    cell.heroImage.kf.cancelDownloadTask()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    guard let sections = fetchController.sections else { return 0 }
//    let sectionInfo = sections[section]
//    return sectionInfo.numberOfObjects
    return self.heroes!.count
  }

}

extension MainScreenViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if self.loadingNextView {
      return
    }
    guard let indexPath = self.tableView.indexPathForRow(at: scrollView.contentOffset)
      else { return }
    if self.previousIndexPath == nil {
      self.previousIndexPath = indexPath
//      let cell = self.fetchController.object(at: indexPath)
      let cell = self.sortedHeroes[indexPath.row]
      let colors = cell.colors as! [UIColor]
      self.navigationController?.navigationBar.barTintColor = colors[2]
      self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: ContrastColorOf(colors[2], returnFlat: true)]
    }
    
    if self.previousIndexPath.item == indexPath.item {
      return
    } else {
      self.previousIndexPath = indexPath
//      let cell = self.fetchController.object(at: indexPath)
      let cell = self.sortedHeroes[indexPath.row]
      let colors = cell.colors as! [UIColor]
      self.navigationController?.navigationBar.barTintColor = colors[2]
      self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: ContrastColorOf(colors[2], returnFlat: true)]
    }
  }
}
