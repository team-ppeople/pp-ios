//
//  ImageDetailView.swift
//  pp
//
//  Created by 임재현 on 4/14/24.
//
import SwiftUI


struct ImageDetailView: View {
    var image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .navigationTitle("Image Detail")
            .navigationBarTitleDisplayMode(.inline)
    }
}
