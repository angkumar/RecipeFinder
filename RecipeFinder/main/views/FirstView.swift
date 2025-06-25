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
            ChatUI()
                .tabItem {
                    Label("Recipe Finder", systemImage: "bubble.left")
                }
            
        }
    }
}

#Preview {
    FirstView()
}
