//
//  PhotoPickerViewModel.swift
//  pp
//
//  Created by 임재현 on 5/5/24.
//

import Foundation
import UIKit

protocol PhotoPickerViewModel: ObservableObject {
    var uiImages: [UIImage] { get }
    func addSelectedPhotos()
}
