//
//  Injection.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 13/07/22.
//

import Foundation

final class Injection: NSObject {

  func provideRepository() -> VirtualToursitRepository {
    let locale = LocaleProvider.sharedInstance
    let network = NetworkProvider.sharedInstance

    return VirtualToursitRepository.sharedInstance(locale, network)
  }
}
