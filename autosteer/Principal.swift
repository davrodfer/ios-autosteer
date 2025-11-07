//
//  Principal.swift
//  autosteer
//
//  Created by David Rodríguez Fernández on 20/11/24.
//  https://github.com/jonathanwong/TCPClient/tree/master/Sources/TCPClient
//

import Foundation
import SwiftUI
import NIOCore
import NIOPosix
import MapKit


struct Principal: View {
    @State var besana = Besana()
    @State private var viewDidLoad: Bool = false
    @State private var isPresentingConfirmA: Bool = false
    @State private var isPresentingConfirmB: Bool = false

    @AppStorage("gpsServer") var gpsServer = "localhost"
    @AppStorage("gpsPort") var gpsPort = 9001
    @AppStorage("reconectaGPS") var reconectaGPS = false

    var gpsURL: [String] {[
        gpsServer.description,
        gpsPort.description
    ]}
    
    @AppStorage("Lat") var Lat = 0.0
    @AppStorage("Lon") var Lon = 0.0
    @AppStorage("Alt") var Alt = 0.0
    @AppStorage("anchoApero") var anchoApero = 20.0
    @AppStorage("alturaCamara") var alturaCamara = 200
    
    @State var puntoAnterior = Coordenada(lat:0.0, lon:0.0, alt:0.0)
    //@State var rumboAnterior = 1.1
    
    var datosPosicion: [String] {[
        Lat.description,
        Lon.description,
        Alt.description,
        anchoApero.description
    ]}
    
    @AppStorage("Calidad") var Calidad = "No"
    @AppStorage("Error") var Error = 0.0
    @AppStorage("Ratio") var Ratio = 0.0
    @AppStorage("age") var age = 0.0
    @AppStorage("desvioIzquierda") var desvioIzquierda = 0.5
    @AppStorage("desvioDerecha") var desvioDerecha = 0.1

    @AppStorage("besanaAlat") var besanaAlat = Double.random(in: 0...359)
    @AppStorage("besanaAlon") var besanaAlon = Double.random(in: 0...359)
    @AppStorage("besanaAalt") var besanaAalt = Double.random(in: 0...459)
    @AppStorage("besanaBlat") var besanaBlat = Double.random(in: 0...359)
    @AppStorage("besanaBlon") var besanaBlon = Double.random(in: 0...359)
    @AppStorage("besanaBalt") var besanaBalt = Double.random(in: 0...459)
    
    @State private var center = CLLocationCoordinate2D(
        latitude: 40.4168,
        longitude: -3.7038
    )
    @State private var cameraPosition: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(
                latitude: 40.4168,
                longitude: -3.7038
            ),
            distance: 80,
            heading: 0,
            pitch: 180
        )
    )
    //@State private var trackCoordinates: [CLLocationCoordinate2D] = []
    @State private var lineAB: [CLLocationCoordinate2D] = []
    @State private var currentLineAB: [CLLocationCoordinate2D] = []
    @State private var currentLineABizq: [CLLocationCoordinate2D] = []
    @State private var currentLineABder: [CLLocationCoordinate2D] = []
    // @State private var rectangulos: [[CLLocationCoordinate2D]] = []
    @State private var forma: [CLLocationCoordinate2D] = []
    
    var body: some View {
        ZStack(/*spacing: 0*/) {
            Map(position: $cameraPosition) {
                if forma.count >= 5 {
                    MapPolygon(coordinates: forma)
                        .stroke(.brown, lineWidth: 1)
                        .foregroundStyle(.brown.opacity(100))
                }
                if lineAB.count >= 2 {
                    MapPolyline(coordinates: lineAB)
                    .stroke(.blue, lineWidth: 4)
                    .foregroundStyle(.blue)
                }
                if currentLineAB.count >= 2 {
                    MapPolyline(coordinates: currentLineAB)
                    .stroke(.green, lineWidth: 1)
                    .foregroundStyle(.green)
                    MapPolyline(coordinates: currentLineABizq)
                    .stroke(.green, lineWidth: 1)
                    .foregroundStyle(.green)
                    MapPolyline(coordinates: currentLineABder)
                    .stroke(.green, lineWidth: 1)
                    .foregroundStyle(.green)
                }

                // Current position annotation
                if Lat != 0 || Lon != 0 {
                    Annotation("", coordinate: CLLocationCoordinate2D(latitude: Lat, longitude: Lon)) {
                        Circle().fill(.green).frame(width: 12, height: 12)
                    }
                }
                
            }
            .mapStyle(.hybrid)
            //.frame(height: 280)
            .onAppear {
                lineAB = [
                    CLLocationCoordinate2D(latitude: besanaAlat, longitude: besanaAlon),
                    CLLocationCoordinate2D(latitude: besanaBlat, longitude: besanaBlon)
                ]
                currentLineAB = lineAB
            }
            
            // Existing content below the map
            VStack(){
                HStack(){
                    ProgressView(value: desvioDerecha)
                        .scaleEffect(y: 10)
                        .rotationEffect(Angle(degrees: 180))
                    ProgressView(value: desvioIzquierda)
                        .scaleEffect(y: 10)
                }.padding(15.0)
                HStack{
                    Text("Desvio:")
                    Text(
                        Int(besana.desvio * 100).description + " cm"
                    ).dynamicTypeSize(.accessibility5)
                }
                HStack{
                    Text("Mover:")
                    Text(besana.moverDesvio).dynamicTypeSize(.accessibility2)
                }
                Spacer()
                
                HStack(){
                    HStack(){
                        Text(Calidad)
                    }.background(Calidad == "Fix" ? Color(UIColor.green) :
                                    Calidad == "Float" ? Color(UIColor.yellow) :
                                    Color(UIColor.red))
                    HStack(){
                        Text("Error:")
                        Text(distanciaH(Error))
                        //Text("cm")
                    }.background(Error < 10 ? Color(UIColor.white) :
                                    Error < 30 ? Color(UIColor.yellow) :
                                    Color(UIColor.red))
                    
                    HStack(){
                        HStack(){
                            Text("Ratio:")
                            Text(String(Ratio))
                        }.background(Ratio < 1 ? Color(UIColor.red) :
                                        Ratio < 3 ? Color(UIColor.yellow) :
                                        Color(UIColor.green))
                    }
                    
                }
                HStack{
                    Text("Rumbo:")
                    Text(String(Int(besana.rumbo*10)/10))
                }
                HStack{
                    Text("BESANA Num:")
                    Text(String(besana.nBesana))
                    //Spacer()
                    
                    Text("Dist:")
                    Text(distanciaH(besana.distanciaABesana))

                    Text("Pos:")
                    Text(besana.posicionBesana)
                    
                    Text("Rumb:")
                    Text(besana.rumboBesana )
                }
                HStack(){
                    
                    HStack(){
                        Button("A", systemImage: "bookmark.square.fill", role: .destructive, action: {
                            isPresentingConfirmA = true
                        })
                        .font(.largeTitle)
                        .padding(.all, 5.0)
                        .confirmationDialog("¿Estás seguro?",
                             isPresented: $isPresentingConfirmA) {
                             Button("Cambiar punto A", role: .destructive) {
                                 //print("Cambiando localizacion punto A")
                                 besanaAlat = Lat
                                 besanaAlon = Lon
                                 besanaAalt = Alt
                                 besana.besanaPuntoA(Punto: {Coordenada(lat: besanaAlat, lon: besanaAlon, alt: besanaAalt)}())
                              }
                            }
                        (Text(Image(systemName: "arrowshape.forward")) + Text(String(Int(besana.sentidoAB*10)/10)))
                    }
                    
                    
                    Spacer()
                    Text("Longitud:")
                    Text(distanciaH(besana.longitudBesana))
                    Spacer()

                    HStack{
                        (Text(String(Int(besana.sentidoBA*10)/10)) + Text(Image(systemName: "arrowshape.backward")))

                        Button("B", systemImage: "bookmark.square.fill", role: .destructive, action: {
                            isPresentingConfirmB = true
                        })
                        .font(.largeTitle)
                        .padding(.all, 5.0)
                           .confirmationDialog("¿Estás seguro?",
                             isPresented: $isPresentingConfirmB) {
                             Button("Cambiar punto B", role: .destructive) {
                               //print("Cambiando localizacion punto B")
                                 besanaBlat = Lat
                                 besanaBlon = Lon
                                 besanaBalt = Alt
                                 besana.besanaPuntoB(Punto: {Coordenada(lat: besanaBlat, lon: besanaBlon, alt: besanaBalt)}())
                              }
                            }
                    }
                }
            }
            .onAppear {
                if viewDidLoad == false {
                    UIApplication.shared.isIdleTimerDisabled = true
                    viewDidLoad = true
                    lanzaConexionGPS()
                    besana.besanaPuntoA(Punto: {Coordenada(lat: besanaAlat, lon: besanaAlon, alt: besanaAalt)}())
                    besana.besanaPuntoB(Punto: {Coordenada(lat: besanaBlat, lon: besanaBlon, alt: besanaBalt)}())
                }
            }
            .onChange(of: gpsURL){
                reconectaGPS = true
            }
            .onChange(of: datosPosicion){
                let Ahora = Coordenada(lat:Lat, lon:Lon, alt:Alt)
                let d = distanciaLLH(puntoAnterior, Ahora)
                if (d > 2) && (d < 40){
                    // Solo añado un nuevo elemento si es mayor de una cantidad de metros
                    let A = heading(Ahora, normalizaAngulo(besana.rumbo + 90), besana.anchoApero / 2)
                    let B = heading(Ahora, normalizaAngulo(besana.rumbo - 90), besana.anchoApero / 2)
                    puntoAnterior = Ahora
                    if (forma.count < 3 ){
                        forma.append(CLLocationCoordinate2D(latitude: A.lat, longitude: A.lon))
                        forma.append(CLLocationCoordinate2D(latitude: B.lat, longitude: B.lon))
                        forma.append(forma[0])
                    }else{
                        let centro = forma.count / 2
                        forma.insert(CLLocationCoordinate2D(latitude: A.lat, longitude: A.lon), at: centro + 1)
                        forma.insert(CLLocationCoordinate2D(latitude: B.lat, longitude: B.lon), at: centro + 1)
                    }
                }else if (d >= 40){
                    puntoAnterior = Ahora
                    //rumboAnterior = besana.rumbo
                }
                
                //---------------------------------------
                besana.recalcula(
                    posicion: {Coordenada(lat:Lat, lon:Lon, alt:Alt)}(),
                    apero: anchoApero/100
                )
                if (besana.moverDesvio == IZQUIERDA) {
                    desvioIzquierda = minimo(besana.desvio, MAX_BARRA_PROGRESO)
                        /
                        minimo( ((anchoApero/2)/100) , MAX_BARRA_PROGRESO)
                    desvioDerecha = 0
                }else{
                    desvioIzquierda = 0
                    desvioDerecha = minimo(besana.desvio, MAX_BARRA_PROGRESO)
                    /
                    minimo( ((anchoApero/2)/100) , MAX_BARRA_PROGRESO)
                }

               // Pinto la besana actual en función del nBesana (numero de besana) y sus limites
                var s = besana.sentidoAB
                if ( sentidoGiro(besana.sentidoAB, bearing(besana.besanaA, besana.actual)) == IZQUIERDA ) {
                    s = besana.sentidoBA
                }

                var nuevoPuntoA = heading(besana.besanaA, normalizaAngulo(s + 90), Double(besana.nBesana) * besana.anchoApero)
                var nuevoPuntoB = heading(besana.besanaB, normalizaAngulo(s + 90), Double(besana.nBesana) * besana.anchoApero)
                nuevoPuntoA = heading(nuevoPuntoA, besana.sentidoBA, 3000)
                nuevoPuntoB = heading(nuevoPuntoB, besana.sentidoAB, 3000)
                currentLineAB = [
                    CLLocationCoordinate2D(latitude: nuevoPuntoA.lat, longitude: nuevoPuntoA.lon),
                    CLLocationCoordinate2D(latitude: nuevoPuntoB.lat, longitude: nuevoPuntoB.lon)
                ]

                nuevoPuntoA = heading(besana.besanaA, normalizaAngulo(s + 90), Double(besana.nBesana) * besana.anchoApero + besana.anchoApero/2)
                nuevoPuntoB = heading(besana.besanaB, normalizaAngulo(s + 90), Double(besana.nBesana) * besana.anchoApero + besana.anchoApero/2)
                nuevoPuntoA = heading(nuevoPuntoA, besana.sentidoBA, 3000)
                nuevoPuntoB = heading(nuevoPuntoB, besana.sentidoAB, 3000)
                currentLineABder = [
                    CLLocationCoordinate2D(latitude: nuevoPuntoA.lat, longitude: nuevoPuntoA.lon),
                    CLLocationCoordinate2D(latitude: nuevoPuntoB.lat, longitude: nuevoPuntoB.lon)
                ]

                nuevoPuntoA = heading(besana.besanaA, normalizaAngulo(s + 90), Double(besana.nBesana) * besana.anchoApero - besana.anchoApero/2)
                nuevoPuntoB = heading(besana.besanaB, normalizaAngulo(s + 90), Double(besana.nBesana) * besana.anchoApero - besana.anchoApero/2)
                nuevoPuntoA = heading(nuevoPuntoA, besana.sentidoBA, 3000)
                nuevoPuntoB = heading(nuevoPuntoB, besana.sentidoAB, 3000)
                currentLineABizq = [
                    CLLocationCoordinate2D(latitude: nuevoPuntoA.lat, longitude: nuevoPuntoA.lon),
                    CLLocationCoordinate2D(latitude: nuevoPuntoB.lat, longitude: nuevoPuntoB.lon)
                ]

                
                // Update track with new GPS point
                let coord = CLLocationCoordinate2D(latitude: Lat, longitude: Lon)
                if CLLocationCoordinate2DIsValid(coord) {
                    cameraPosition = .camera(
                        MapCamera(
                            centerCoordinate: coord,
                            distance: Double(alturaCamara),
                            heading: besana.rumbo,
                            pitch: 45
                        )
                    )
                }
            }
            .onChange(of: besanaAlat) { updateAB() }
            .onChange(of: besanaAlon) { updateAB() }
            .onChange(of: besanaBlat) { updateAB() }
            .onChange(of: besanaBlon) { updateAB() }
        }
    }
  }
  struct Principal_Previews: PreviewProvider {
      static var previews: some View {
          Principal()
      }
  }

extension Principal {
    private func updateAB() {
        lineAB = [
            CLLocationCoordinate2D(latitude: besanaAlat, longitude: besanaAlon),
            CLLocationCoordinate2D(latitude: besanaBlat, longitude: besanaBlon)
        ]
    }
}

private final class leeGPS: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer
    private var sendBytes = 0
    private var receiveBuffer: ByteBuffer = ByteBuffer()

    @AppStorage("Lat") var Lat = 0.0
    @AppStorage("Lon") var Lon = 0.0
    @AppStorage("Alt") var Alt = 0.0
    @AppStorage("Calidad") var Calidad = "No"
    @AppStorage("Error") var Error = 0.0
    @AppStorage("Ratio") var Ratio = 0.0
    @AppStorage("age") var age = 0.0

    @AppStorage("reconectaGPS") var reconectaGPS = false

    public func channelActive(context: ChannelHandlerContext) {
        print("Client connected to \(context.remoteAddress?.description ?? "unknown")")
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var unwrappedInboundData = Self.unwrapInboundIn(data)
        let recibidoBytes = unwrappedInboundData.readableBytes
        receiveBuffer.writeBuffer(&unwrappedInboundData)

        if (recibidoBytes > 0) {
            if (recibidoBytes < 300){
                let trozos = String(buffer: receiveBuffer)
                    .replacingOccurrences(of: "\\n*", with: "", options: .regularExpression)
                    .split(separator: " ")
                if (trozos.count >= 14){
                    switch trozos[5] {
                        case "1":
                            Calidad = "Fix"
                        case "2":
                            Calidad = "Float"
                        case "3":
                            Calidad = "SBAS"
                        case "4":
                            Calidad = "DGPS"
                        case "5":
                            Calidad = "Single"
                        case "6":
                            Calidad = "PPPP"
                        default:
                            Calidad = "NO"
                    }
                    Lat   = Double(trozos[2]) ?? 0.0
                    Lon   = Double(trozos[3]) ?? 0.0
                    Alt   = Double(trozos[4]) ?? 0.0
                    Error = hipotenusa(
                            Double(trozos[7]) ?? 0.0,
                            Double(trozos[8]) ?? 0.0
                    )
                    Ratio = Double(trozos[14]) ?? 0.0
                    age = Double(trozos[13]) ?? 0.0

                }
            }
        }else{
            context.close(promise: nil)
        }
        if (reconectaGPS) {
            context.close(promise: nil)
        }
        receiveBuffer.clear()
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)
        context.close(promise: nil)
    }
}


func lanzaConexionGPS() {
    Task {
        await conectarGPS()
    }
}

func conectarGPS() async {
    
    @AppStorage("gpsServer") var gpsServer = "localhost"
    @AppStorage("gpsPort") var gpsPort = 9001
    @AppStorage("reconectaGPS") var reconectaGPS = false
    reconectaGPS = false
    @AppStorage("conectadoGPS") var conectadoGPS = false

    print("Conectando a ", gpsServer, "puerto", gpsPort)
    
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let bootstrap = ClientBootstrap(group: group)
    // Enable SO_REUSEADDR.
        .channelOption(.socketOption(.so_reuseaddr), value: 1)
        .channelInitializer { channel in
            channel.pipeline.addHandler(leeGPS())
        }
    defer {
        try! group.syncShutdownGracefully()
    }
    
    conectadoGPS = true
    do {
        let channel = try { () -> Channel in
            return try bootstrap.connect(host: gpsServer, port: gpsPort).wait()
            //return try bootstrap.connect(host: "mprom2.local", port: 9001).get()
        }()
        try channel.closeFuture.wait()
        
    }catch {
        print(error)
    }
    conectadoGPS = false
    print("Client closed")
    sleep(5)
    await conectarGPS()
}

