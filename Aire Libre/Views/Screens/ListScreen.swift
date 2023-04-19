//
//  ListView.swift
//  Aire Libre
//
//  Created by Marcio Duarte on 2023-01-20.
//

import SwiftUI
import Combine

struct ListScreen: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Binding private var selectedSensor: AQIData?
    
    init() {
        _selectedSensor = .constant(nil)
    }
    
    init(selectedSensor: Binding<AQIData?>) {
        _selectedSensor = selectedSensor
    }
    
    var body: some View {
        favoritesView
            .navigationTitle(Localizables.favorites)
            .navigationDestination(for: Screens.self) { screen in
                switch screen {
                case .map(let source):
                    MapScreen(selectedSourceId: source)
                case .list:
                    ListScreen()
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    NavigationLink(value: Screens.map(source: nil)) {
                        Text("Ver mapa")
                    }
                }
            }
            #endif
            .refreshable {
                appViewModel.loadAQI()
            }
    }
    
    @ViewBuilder
    private var favoritesView: some View {
        if appViewModel.favorites.isEmpty {
            emptyFavoritesView
        } else {
            populatedFavoritesView
        }
    }
    
    @ViewBuilder
    private var emptyFavoritesView: some View {
        VStack(spacing: 8) {
            Text("No hay favoritos")
        }
    }
    
    @ViewBuilder
    private var populatedFavoritesView: some View {
        List(selection: $selectedSensor) {
            ForEach(appViewModel.favorites, id: \.self) { data in
                #if os(macOS)
                    SensorInfo(sensorName: data.description,
                               aqiIndex: data.quality.index,
                               favorited: .constant(data.isFavoriteSensor),
                               showFavoriteIcon: false)
                #else
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        NavigationLink(value: Screens.map(source: data.source)) {
                            SensorInfo(sensorName: data.description,
                                       aqiIndex: data.quality.index,
                                       favorited: .constant(data.isFavoriteSensor),
                                       showFavoriteIcon: false)
                        }
                    } else {
                        SensorInfo(sensorName: data.description,
                                   aqiIndex: data.quality.index,
                                   favorited: .constant(data.isFavoriteSensor),
                                   showFavoriteIcon: false)
                    }
                #endif
            }
            .onDelete { offsets in
                offsets.forEach { index in
                    let aqi = appViewModel.favorites[index]
                    appViewModel
                        .update(newValue: aqi.copy(isFavoriteSensor: false))
                }
            }
        }
        #if os(macOS)
        .onDeleteCommand(perform: {
            if let selectedSensor {
                appViewModel.update(newValue: selectedSensor.copy(isFavoriteSensor: false))
            }
        })
        #endif
    }
}

struct ListScreen_Previews: PreviewProvider {
    static var previews: some View {
        ListScreen()
            .environmentObject(Samples.appViewModel)
            .onAppear {
                Samples.appViewModel.loadAQI()
            }
    }
}