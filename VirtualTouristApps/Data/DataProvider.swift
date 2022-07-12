//
//  DataProvider.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 12/07/22.
//

import CoreData
import UIKit

class DataProvider {
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "VirtualTouristApps")

    container.loadPersistentStores { _, error in
      guard error == nil else {
        fatalError("Unresolved error \(error!)")
      }
    }
    container.viewContext.automaticallyMergesChangesFromParent = false
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    container.viewContext.shouldDeleteInaccessibleFaults = true
    container.viewContext.undoManager = nil

    return container
  }()

  private func newTaskContext() -> NSManagedObjectContext {
    let taskContext = persistentContainer.newBackgroundContext()
    taskContext.undoManager = nil

    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return taskContext
  }


  func getAllLocations(completion: @escaping(_ locations: [LocationEntity]) -> Void) {
    let taskContext = newTaskContext()
    taskContext.perform {
      let fetchRequest = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
      do {
        let results = try taskContext.fetch(fetchRequest)
        completion(results)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }
  }

  func addLocation(
    longitude: Double,
    latitude: Double,
    completion: @escaping(_ idLocation: Int) -> Void
  ) {
    let taskContext = newTaskContext()
    if latitude != 0.0, longitude != 0.0 {
      taskContext.performAndWait {
        if let entity = NSEntityDescription.entity(forEntityName: "LocationEntity", in: taskContext) {
          let location = NSManagedObject(entity: entity, insertInto: taskContext)
          self.getMaxLocationId { id in
            let idLocation = id+1
            location.setValue(idLocation, forKeyPath: "idLocation")
            location.setValue(latitude, forKeyPath: "latitude")
            location.setValue(longitude, forKeyPath: "longitude")
            location.setValue(Date(), forKeyPath: "creationDate")

            do {
              try taskContext.save()
              completion(idLocation)
            } catch let error as NSError {
              print("Could not save. \(error), \(error.userInfo)")
            }
          }
        }
      }
    }
  }

  func getMaxLocationId(completion: @escaping(_ maxId: Int) -> Void) {
    let taskContext = newTaskContext()
    taskContext.performAndWait {
      let fetchRequest = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
      let sortDescriptor = NSSortDescriptor(key: "idLocation", ascending: false)
      fetchRequest.sortDescriptors = [sortDescriptor]
      fetchRequest.fetchLimit = 1
      do {
        let lastLocation = try taskContext.fetch(fetchRequest)
        if let location = lastLocation.first, let lastId = location.value(forKeyPath: "idLocation") as? Int {
          completion(lastId)
        } else {
          completion(0)
        }
      } catch {
        print(error.localizedDescription)
      }
    }
  }

}
