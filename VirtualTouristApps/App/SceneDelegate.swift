//
//  SceneDelegate.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 10/07/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  private lazy var dataProvider: LocaleProvider = { return LocaleProvider() }()

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
//    if !UserDefaults.standard.bool(forKey: "first") {
//      dataProvider.addAlbumDummy {
//        UserDefaults.standard.set(true, forKey: "first")
//      }
//    }
  }

}
