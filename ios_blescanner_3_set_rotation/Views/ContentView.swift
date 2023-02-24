//
//  ContentView.swift
//  ios_blescanner_3_set_rotation
//
//  Created by Kacper Cichosz on 06/02/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: DukeAdvScannerViewModel
    var body: some View {
        VStack {
            if !self.viewModel.advertisementArray.isEmpty {
                Text("Time to find 3 Sets: \(self.viewModel.timeToFindThreeSets())")
                List() {
                    ForEach(self.viewModel.advertisementArray) { element in
                        Text("\(element.id). \(element.name), \(element.timestamp), \(element.set),\(element.timeInterval)")
                    }
                }
            }
            Button("Connect to DUKE Adv") {
                self.viewModel.startScanning()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: DukeAdvScannerViewModel())
    }
}
