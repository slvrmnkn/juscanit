//
//  ContentView.swift
//  juscanit
//
//  Created by Thomas Aardal on 25/07/2024.
//

import SwiftUI
import CodeScanner
import AVFoundation

struct ContentView: View {
    @State private var isShowingScanner = false
    
    @State private var isShowingResults = false
    
    @State private var isShowingAbout = false
    
    var title = "juscanit"
    
    var body: some View {
        NavigationStack {
            Button("Scan", systemImage: "camera.viewfinder") {
                isShowingScanner = true
            }.controlSize(.large).buttonStyle(.borderedProminent)

            Text("WhatBar scanner")
                .navigationTitle(title)
                .toolbar {
                    Button("About", systemImage: "info.square") {
                        isShowingAbout = true
                    }
                    
                }
                .sheet(isPresented: $isShowingScanner)  {
                    CodeScannerView(codeTypes: [.qr, .ean13, .upce, .ean8, .code39, .code93, .code128, .itf14, .codabar, .gs1DataBar, .dataMatrix, .pdf417, .microQR, .microPDF417, .code39Mod43,.gs1DataBarExpanded, .gs1DataBarLimited], simulatedData: "whatbar.demo.text", completion: handleScan)
                }
                .sheet(isPresented: $isShowingResults) {
                    SheetView()
                }
                .sheet(isPresented: $isShowingAbout) {
                    AboutView()
                }
                
        }
        
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        isShowingResults = true
        
        switch result {
        case .success(let result) :
            let details =   result.string.components(separatedBy: "\n")
            print("Scanned:\n", details)
            print(result.type.rawValue)
            AppData.shared.results = details
            AppData.shared.type = result.type.rawValue
            
        case .failure(let error) :
            let details =  [ error.localizedDescription]
            print("Error:\n", details)
            AppData.shared.results = details
        }
        
    }
}

struct SheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Text("Type: " + AppData.shared.type + "\n\n" +
             "Raw scanned data:\n\n" + AppData.shared.results.description).font(.body.monospaced()).padding()
        Button("Close") {
            dismiss()
        }
        .font(.title2)
        .padding()
        .background(.white)
        .buttonBorderShape(.circle)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Text("Just scans barcodes and shows you what they contain").font(.body.monospaced()).padding()
        Button("Close") {
            dismiss()
        }
        .font(.title2)
        .padding()
        .background(.white)
        .buttonBorderShape(.circle)
    }
}

#Preview {
    ContentView()
}

class AppData {
    static let shared = AppData()
    var results: [String] = [""]
    var type: String = ""
    private init() {}
}
