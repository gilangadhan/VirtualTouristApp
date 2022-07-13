//
//  NetworkProvider.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 13/07/22.
//

import Foundation

class NetworkProvider {
  func getAllPhotos(
    latitude: Double,
    longitude: Double,
    completion: @escaping(Result<[Photo], Error>) -> Void
  ) {
    let url = URL(string: "\(Endpoints.Request.getPhotoByLocation.url)&lat=\(latitude)&lon=\(longitude)")
    let request = URLRequest(url: url!)

    let task = URLSession.shared.dataTask(with: request) { maybeData, maybeResponse, maybeError in
      if maybeError != nil {
        completion(.failure(URLError.addressUnreachable(url!)))
      } else if let data = maybeData, let response = maybeResponse as? HTTPURLResponse, response.statusCode == 200 {
        let decoder = JSONDecoder()
        do {
          let result = try decoder.decode(FlickrResponses.self, from: data)
          if result.stat != "ok", result.photos.photo.count == 0 {
            completion(.failure(URLError.invalidResponse))
          } else {
            completion(.success(result.photos.photo))
          }
        } catch {
          completion(.failure(URLError.invalidResponse))
        }
      } else {
        completion(.failure(URLError.invalidResponse))
      }
    }
    task.resume()
  }
}

enum URLError: LocalizedError {

  case invalidResponse
  case noInternet
  case logoutFailed
  case addressUnreachable(URL)
  case credentialIncorrect
  case invalidInput

  var errorDescription: String? {
    switch self {
    case .invalidResponse: return "The server responded with garbage."
    case .addressUnreachable(let url): return "\(url.absoluteString) is unreachable."
    case .logoutFailed: return "Can't remove cache from login."
    case .noInternet: return "The Internet connection is offline, please try again later."
    case .credentialIncorrect: return "The credentials were incorrect, please check your email or/and your password."
    case .invalidInput: return "Please not use special character."
    }
  }
}

struct API {
  static let baseUrl = "https://www.flickr.com/services/rest/"
  static let methodName = "flickr.photos.search"
  static let APIKey = "4f2b2b13f23144ac2de734eb257b7c5c"
  static let format = "json&nojsoncallback=1"
  static let radius = 10
}

protocol Endpoint {
  var url: String { get }
}

enum Endpoints {
  enum Request: Endpoint {
    case getPhotoByLocation

    public var url: String {
      switch self {
      case .getPhotoByLocation:
        return "\(API.baseUrl)?method=\(API.methodName)&format=\(API.format)&api_key=\(API.APIKey)&radius=\(API.radius)"
      }
    }
  }
}

struct FlickrResponses: Codable {
    let photos: Photos
    let stat: String
}

struct Photos: Codable {
    let page, pages, perpage, total: Int
    let photo: [Photo]
}

struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}
