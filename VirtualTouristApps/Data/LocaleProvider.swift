//
//  LocaleProvider.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 12/07/22.
//

import CoreData
import UIKit

class LocaleProvider {
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

  func getAllAlbum(
    by idLocation: String,
    completion: @escaping(_ location: LocationEntity, _ albums: [AlbumEntity]) -> Void
  ) {
    let taskContext = newTaskContext()
    taskContext.perform {
      self.getLocation(by: idLocation, with: taskContext) { location in
        let fetchRequest = NSFetchRequest<AlbumEntity>(entityName: "AlbumEntity")
        fetchRequest.predicate = NSPredicate(format: "location == %@", location)
        do {
          let albums = try taskContext.fetch(fetchRequest)
          completion(location, albums)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
      }
    }
  }

  func addAlbum(
    idLocation: String,
    image: Data,
    completion: @escaping() -> Void
  ) {
    let taskContext = newTaskContext()
    taskContext.performAndWait {
      getLocation(by: idLocation, with: taskContext) { location in
        if let entity = NSEntityDescription.entity(forEntityName: "AlbumEntity", in: taskContext) {
          let album = NSManagedObject(entity: entity, insertInto: taskContext)
          self.getMaxAlbumId(by: location, with: taskContext) { maxId in
            let idAlbum = maxId+1
            album.setValue(idAlbum, forKeyPath: "idAlbum")
            album.setValue(image, forKeyPath: "image")
            album.setValue(Date(), forKeyPath: "dateDownload")
            album.setValue(location, forKey: "location")
            do {
              try taskContext.save()
              completion()
            } catch let error as NSError {
              print("Could not save. \(error), \(error.userInfo)")
            }
          }
        }
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
          self.getMaxLocationId(with: taskContext) { id in
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

  func getLocation(
    by idLocation: String,
    with taskContext: NSManagedObjectContext,
    completion: @escaping(_ location: LocationEntity) -> Void
  ) {
    let fetchRequest = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
    fetchRequest.predicate = NSPredicate(format: "idLocation == %@", idLocation)
    fetchRequest.fetchLimit = 1
    do {
      let lastLocation = try taskContext.fetch(fetchRequest)
      if let location = lastLocation.first {
        completion(location)
      } else {
        print("Could get LocationEntity by idLocation.")
      }
    } catch {
      print(error.localizedDescription)
    }
  }

  func getMaxLocationId(
    with taskContext: NSManagedObjectContext,
    completion: @escaping(_ maxId: Int) -> Void
  ) {
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

  func getMaxAlbumId(
    by location: LocationEntity,
    with taskContext: NSManagedObjectContext,
    completion: @escaping(_ maxId: Int) -> Void
  ) {
    let fetchRequest = NSFetchRequest<AlbumEntity>(entityName: "AlbumEntity")
    let sortDescriptor = NSSortDescriptor(key: "idAlbum", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    fetchRequest.fetchLimit = 1
    do {
      let lastAlbum = try taskContext.fetch(fetchRequest)
      if let album = lastAlbum.first, let lastId = album.value(forKeyPath: "idAlbum") as? Int {
        completion(lastId)
      } else {
        completion(0)
      }
    } catch {
      print(error.localizedDescription)
    }
  }

  func addAlbumDummy(completion: @escaping() -> Void) {
    for album in albumDummies {
      if let image = album.image {
        self.addAlbum(idLocation: "1", image: image) {
          completion()
        }
      }
    }
  }

}
