//
//  FavoriteView.swift
//  RecipeFinder
//
//  Created by Angad Kumar on 6/24/25.
//



import SwiftUI

struct FavoriteView: View {
    
    @Binding var presentSideMenu: Bool
    
    var body: some View {
        VStack{
            HStack{
                Button{
                    presentSideMenu.toggle()
                } label: {
                    Image(systemName: "line.horizontal.3")
                        .font(.system(size: 28))
                }
                Spacer()
            }
            
            Spacer()
            Text("Favorite View")
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
