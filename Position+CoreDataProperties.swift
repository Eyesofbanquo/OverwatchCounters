//
//  Position+CoreDataProperties.swift
//  
//
//  Created by Markim Shaw on 7/11/17.
//
//

import Foundation
import CoreData


extension Position {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Position> {
        return NSFetchRequest<Position>(entityName: "Position")
    }

    @NSManaged public var height: Double
    @NSManaged public var width: Double
    @NSManaged public var x: Double
    @NSManaged public var y: Double

}
