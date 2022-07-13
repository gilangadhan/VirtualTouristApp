//
//  LocaleProvider.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 12/07/22.
//

import CoreData
import UIKit

final class LocaleProvider: NSObject {
  private override init() { }

  static let sharedInstance: LocaleProvider = LocaleProvider()

  let newTaskContext: NSManagedObjectContext = {
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

    let taskContext = container.newBackgroundContext()
    taskContext.undoManager = nil

    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return taskContext
  }()
}

extension LocaleProvider {

  func getAllLocations(completion: @escaping(_ locations: [LocationEntity]) -> Void) {

    newTaskContext.perform {
      let fetchRequest = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
      do {
        let results = try self.newTaskContext.fetch(fetchRequest)
        completion(results)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }
  }

  func getAllAlbum(
    by location: LocationEntity,
    completion: @escaping(_ albums: [AlbumEntity]) -> Void
  ) {
    newTaskContext.performAndWait {
      let fetchRequest = NSFetchRequest<AlbumEntity>(entityName: "AlbumEntity")
      fetchRequest.predicate = NSPredicate(format: "location == %@", location)
      do {
        let albums = try self.newTaskContext.fetch(fetchRequest)
        completion(albums)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }
  }

  func addAlbum(
    location: LocationEntity,
    albumModel: AlbumModel,
    completion: @escaping() -> Void
  ) {
    newTaskContext.performAndWait {
      if let entity = NSEntityDescription.entity(forEntityName: "AlbumEntity", in: self.newTaskContext) {
        let album = NSManagedObject(entity: entity, insertInto: self.newTaskContext)
        album.setValue(albumModel.id, forKeyPath: "idAlbum")
        album.setValue(albumModel.owner, forKeyPath: "owner")
        album.setValue(albumModel.secret, forKeyPath: "secret")
        album.setValue(albumModel.server, forKeyPath: "server")
        album.setValue(albumModel.farm, forKey: "farm")
        album.setValue(albumModel.title, forKeyPath: "title")
        album.setValue(albumModel.ispublic, forKeyPath: "ispublic")
        album.setValue(albumModel.isfriend, forKeyPath: "isfriend")
        album.setValue(albumModel.isfamily, forKeyPath: "isfamily")
        album.setValue(albumModel.image, forKeyPath: "image")
        album.setValue(location, forKey: "location")
        do {
          try self.newTaskContext.save()
          completion()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
      }
    }
  }

  func addLocation(
    longitude: Double,
    latitude: Double,
    completion: @escaping(_ idLocation: Int) -> Void
  ) {
    if latitude != 0.0, longitude != 0.0 {
      newTaskContext.performAndWait {
        if let entity = NSEntityDescription.entity(forEntityName: "LocationEntity", in: self.newTaskContext) {
          let location = NSManagedObject(entity: entity, insertInto: self.newTaskContext)
          self.getMaxLocationId(with: self.newTaskContext) { id in
            let idLocation = id+1
            location.setValue(idLocation, forKeyPath: "idLocation")
            location.setValue(latitude, forKeyPath: "latitude")
            location.setValue(longitude, forKeyPath: "longitude")
            location.setValue(Date(), forKeyPath: "creationDate")

            do {
              try self.newTaskContext.save()
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
    completion: @escaping(_ location: LocationEntity) -> Void
  ) {
    newTaskContext.performAndWait {
      let fetchRequest = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
      fetchRequest.predicate = NSPredicate(format: "idLocation == %@", idLocation)
      fetchRequest.fetchLimit = 1
      do {
        let lastLocation = try self.newTaskContext.fetch(fetchRequest)
        if let location = lastLocation.first {
          completion(location)
        } else {
          print("Could get LocationEntity by idLocation.")
        }
      } catch {
        print(error.localizedDescription)
      }
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

}
