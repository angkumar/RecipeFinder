//
//  FirstView.swift
//  RecipeFinder
//
//  Created by Angad Kumar on 6/24/25.
//

import SwiftUI

struct FirstView: View {
    var body: some View {
        TabView {
            home()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
        }
    }
}

#Preview {
    FirstView()
}
