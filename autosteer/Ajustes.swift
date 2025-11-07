//
//  Ajustes.swift
//  autosteer
//
//  Created by David Rodríguez Fernández on 20/11/24.
//


import Foundation
import SwiftUI

struct Ajustes: View {
    let formatterInt: NumberFormatter = {
           let formatter = NumberFormatter()
           formatter.numberStyle = .decimal
           return formatter
       }()
    
    struct NumberFormatters {
        static var threeFractionDigits: Formatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            formatter.maximumFractionDigits = 3
            return formatter
        }
    }
    
  @AppStorage("reconectaGPS") var reconectaGPS = false
  @AppStorage("conectadoGPS") var conectadoGPS = false

  @AppStorage("anchoApero") var anchoApero = 222
  @AppStorage("gpsServer") var gpsServer = "localhost"
  @AppStorage("gpsPort") var gpsPort = 9001
  @AppStorage("alturaCamara") var alturaCamara = 200
  
  var body: some View {
    VStack {
        HStack(){
            Text("Ancho Apero (cm):")
            TextField("", value: $anchoApero, formatter: formatterInt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .fontWeight(.bold)
                .background(.clear)
                .lineLimit(1)
                //.dynamicTypeSize(.accessibility5)
                //.multilineTextAlignment(/*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
        }
        HStack(){
            Text("hostname GPS:")
            TextField("", text: $gpsServer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .fontWeight(.bold)
                .background(.clear)
                .lineLimit(1)
                //.dynamicTypeSize(.accessibility5)
                //.multilineTextAlignment(/*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
        }.background(conectadoGPS ? Color(UIColor.green) : Color(UIColor.red))
        HStack(){
            Text("Port GPS:")
            TextField("", value: $gpsPort, formatter: formatterInt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .fontWeight(.bold)
                .background(.clear)
                .lineLimit(1)
                //.dynamicTypeSize(.accessibility5)
                //.multilineTextAlignment(/*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                
        }.background(conectadoGPS ? Color(UIColor.green) : Color(UIColor.red))
        
        HStack(){
            Text("Altura camara (m):")
            TextField("", value: $alturaCamara, formatter: formatterInt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .fontWeight(.bold)
                .background(.clear)
                .lineLimit(1)
        }
        
    /*
            Toggle(
                "Mostrar Distancia Restante",
                systemImage: "ruler",
                isOn: $distanciaRestante
          )
    */
            /*
     Toggle(
                "Silenciar sonidos",
                systemImage: "speaker.slash",
                isOn: $silenciarSonidos
          )
    */
    }
    .padding(.horizontal, 4.0)
  }
}
struct Ajustes_Previews: PreviewProvider {
    static var previews: some View {
        Ajustes()
    }
}
