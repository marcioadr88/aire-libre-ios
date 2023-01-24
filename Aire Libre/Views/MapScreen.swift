//
//  MapView.swift
//  Aire Libre
//
//  Created by Marcio Duarte on 2023-01-20.
//

import SwiftUI
import MapKit

struct MapScreen: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    @State private var selectedData: AQIData?
    
    @State var region = MKCoordinateRegion(center: AppConstants.asuncionCoordinates,
                                           span: AppConstants.defaultSpan)
    
    var body: some View {
        ZStack {
            Map(
                coordinateRegion: .constant(region),
                showsUserLocation: true,
                userTrackingMode: .constant(.follow),
                annotationItems: appViewModel.aqiData
            ) { item in
                MapAnnotation(coordinate: item.coordinates) {
                    AQIAnnotationView(aqiData: item)
                        .onTapGesture {
                            withAnimation {
                                selectedData = item
                            }
                        }
                }
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                if let selectedData,
                   let aqiDataBinding = Binding<AQIData>($selectedData)  {
                    SensorInfo(sensorName: selectedData.description,
                               aqiIndex: selectedData.quality.index,
                               favorited: aqiDataBinding.isFavoriteSensor)
                    .padding()
                    .transition(.move(edge: .bottom))
                    .onChange(of: aqiDataBinding.isFavoriteSensor.wrappedValue) { newValue in
                        //update view model with the updated selectedData values
                        guard let updatedSelectedData = self.selectedData else {
                            return
                        }
                        
                        appViewModel.update(newValue: updatedSelectedData)
                    }
                }
            }
        }
        .onAppear {
            appViewModel.loadAQI()
        }
    }
}

struct MapScreen_Previews: PreviewProvider {
    static var previews: some View {
        MapScreen()
            .environmentObject(
                AppViewModel(repository: Samples.successfulAireLibreRepository)
            )
    }
}