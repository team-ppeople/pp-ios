//
//  PhotoPickerViewModel.swift
//  pp
//
//  Created by 임재현 on 5/5/24.
//

import Foundation
import UIKit
import _PhotosUI_SwiftUI

protocol PhotoPickerViewModel: ObservableObject {
    var uiImages: [UIImage] { get set }
    var selectedPhotos: [PhotosPickerItem] { get set }
    var profileImage: UIImage? { get set }
    func addSelectedPhotos()
    func addSelectedProfile()

}
extension PhotoPickerViewModel {
    var profileImage: UIImage? {
        get { nil }
        set { }
    }
    
    func addSelectedProfile() {

    }
}
