//
//  _funcionesGPS.swift
//  autosteer
//
//  Created by David Rodríguez Fernández on 24/11/24.
//

import Foundation
import SwiftUI
let IZQUIERDA: String = "izquierda"
let DERECHA: String = "derecha"

func noID(_ sentido: String) -> String {
    if (sentido == DERECHA){
        return IZQUIERDA
    } else{
        return DERECHA
    }
}
        
struct Coordenada {
    var lat = 0.0
    var lon = 0.0
    var alt = 0.0
}

struct Punto {
    let time = Date().timeIntervalSince1970
    let position: Coordenada
}

func sqrt(_ number: Double) -> Double {
    return number.squareRoot()
}


func distanciaH(_ metros: Double) -> String {
    if (metros < 0.015){
        return String(Int(metros * 1000)) + " mm"
    }
    if (metros < 0.1){
        return String(Double(Int(metros * 1000))/10
        ) + " cm"
    }
    if (metros < 1.5){
        return String(Int(metros * 100)) + " cm"
    }
    if (metros > 1000){
        return  String(Int(metros / 100)/10) + " km"
    }
    return String(Int(metros*10)/10) + " m"
}


func hipotenusa(_ a: Double, _ b: Double) -> Double {
    return sqrt(a * a + b * b)
}

func radians(_ number: Double) -> Double {
    return number * .pi / 180
}

func degrees(_ number: Double) -> Double {
    return number * 180 / .pi
}

func radioTierra(_ puntoA: Coordenada, _ puntoB: Coordenada) -> Double {
    let R = 6378 - 21 * sin(radians(puntoA.lat))
    return  Double(R * 1000) + ((puntoA.alt + puntoB.alt) / 2)
}

func bearing(_ puntoA: Coordenada, _ puntoB: Coordenada) -> Double {
    let rLat1 = radians(puntoA.lat)
    let rLat2 = radians(puntoB.lat)
    let rLon1 = radians(puntoA.lon)
    let rLon2 = radians(puntoB.lon)
    let y = sin(rLon2-rLon1) * cos(rLat2)
    let x = cos(rLat1)*sin(rLat2) -
        sin(rLat1)*cos(rLat2)*cos(rLon2-rLon1)
    let brng = degrees(atan2(y, x))
    return (brng+360).truncatingRemainder(dividingBy: 360)
}

func distanciaLLH(_ puntoA: Coordenada, _ puntoB: Coordenada) -> Double {
    let rLat1 = radians(puntoA.lat)
    let rLat2 = radians(puntoB.lat)
    let dlat = radians(puntoA.lat - puntoB.lat)
    let dlon = radians(puntoA.lon - puntoB.lon)
    let a = sin(dlat/2) *
        sin(dlat/2) +
        cos(rLat1)  *
        cos(rLat2)  *
        sin(dlon/2) *
        sin(dlon/2)
    let c = 2 * atan2(sqrt(a),sqrt(1-a))
    let d = radioTierra(puntoA, puntoB) * c
    return Double(d)
}

// Devuelve el punto al que llegas al ir desde un punto en un sentido una distancia
func heading (_ origen: Coordenada, _ sentido: Double, _ distancia: Double) -> Coordenada {
    let rLat = radians(origen.lat)
    let rLon = radians(origen.lon)
    let rSen = radians(sentido)
    let Ad = distancia/radioTierra(origen, origen)
    let latdestino = asin(sin(rLat) * cos(Ad) + cos(rLat) * sin(Ad) * cos(rSen))
    let londestino = rLon + atan2(sin(rSen) * sin(Ad) * cos(rLat) , cos(Ad) - sin(rLat) * sin(latdestino))
    return {Coordenada(lat: degrees(latdestino), lon:degrees(londestino), alt:origen.alt)}()
}

func normalizaAngulo(_ angulo: Double) -> Double {
    return (angulo + 3600).truncatingRemainder(dividingBy: 360)
}

func anguloComplementario(_ angulo: Double) -> Double {
    if (angulo > 180){
        return 360 - angulo
    }
    return angulo
}

func comparaGrados (_ g1: Double,_ g2: Double) -> Double {
    return anguloComplementario(
        abs(
            normalizaAngulo(g1) - normalizaAngulo(g2)
        )
    )
}

func sentidoGiro(_ origen: Double, _ destino: Double) -> String {
    let origenNormalizado=Int(normalizaAngulo(origen))
    let destinoNormalizado=Int(normalizaAngulo(destino))
    let diferencia = comparaGrados(Double(origenNormalizado),Double(destinoNormalizado))
    if (diferencia == 0){
        return "recto"
    }
    if (normalizaAngulo(Double(origenNormalizado) + diferencia) == Double(destinoNormalizado)){
        return DERECHA
    }
    if (normalizaAngulo(Double(origenNormalizado) - diferencia) == Double(destinoNormalizado)){
        return IZQUIERDA
    }
    return "Error: " + origen.description + " => " + destino.description
}

struct Besana {
    let tiempoCalculoSentido = 1.5

    var anchoApero: Double = 1.1
    var actual: Coordenada
    var besanaA: Coordenada
    var besanaB: Coordenada
    var longitudBesana: Double = 0.0
    var sentidoAB: Double = 0.0
    var sentidoBA: Double = 0.0
    var rumbo: Double = 0.0
    var listado: [Punto] = []
    var distanciaABesana: Double = 0.0
    var rumboBesana: String = "AB"
    var sentido: Double = 0.0
    var origen: Coordenada
    var desvioGrados: Double = 0.0
    var rumboBesanaPosicion: Double = 0.0
    var nBesana: Int = 0
    var resto: Double = 0.0
    var desvio: Double = 0.0
    var moverDesvio: String = ""
    var posicionBesana: String = ""
    var moverRumbo: String = ""
    
    init() {
        //let coord:Coordenada = {Coordenada(lat: Double.random(in: 0...359), lon:Double.random(in: 0...359), alt:Double.random(in: 0...359))}()
        actual = {Coordenada(lat: Double.random(in: 0...359), lon:Double.random(in: 0...359), alt:Double.random(in: 0...359))}()
        besanaA = {Coordenada(lat: Double.random(in: 0...359), lon:Double.random(in: 0...359), alt:Double.random(in: 0...359))}()
        besanaB = {Coordenada(lat: Double.random(in: 0...359), lon:Double.random(in: 0...359), alt:Double.random(in: 0...359))}()
        origen = {Coordenada(lat: Double.random(in: 0...359), lon:Double.random(in: 0...359), alt:Double.random(in: 0...359))}()
    }
    mutating func sentidoBesana(){
        sentidoAB = bearing(besanaA, besanaB)
        sentidoBA = (sentidoAB+180).truncatingRemainder(dividingBy: 360)
        longitudBesana = distanciaLLH(besanaA, besanaB)
    }
    mutating func besanaPuntoA (
        Punto: Coordenada
    ){
        besanaA = Punto
        self.sentidoBesana()
    }
    mutating func besanaPuntoB (
        Punto: Coordenada
    ){
        besanaB = Punto
        self.sentidoBesana()
    }
    func calculaDistanciaBesana() -> Double{
        let b = distanciaLLH(besanaA,actual)
        let a = distanciaLLH(besanaB,actual)
        let c = longitudBesana
        let s = (a+b+c)/2
        let duplo = s*(s-a)*(s-b)*(s-c)
        // var h:Double = 0
        if (duplo >= 0){
            return ((2/c) * sqrt(duplo))
        }
        return 0.0
    }

    mutating func recalcula (
            posicion: Coordenada,
            apero: Double
    ) {
        actual = posicion
        if (apero > 0){
            anchoApero = apero
        }else{
            anchoApero = 1.1
        }
        let punto:Punto = {Punto(position:posicion)}()
        listado.append(punto)
        while (
            Double(listado.first!.time) < (Double(punto.time) - tiempoCalculoSentido)
        ){
            listado.removeFirst(1)
        }
        rumbo = bearing(listado.first!.position, punto.position)
        distanciaABesana = calculaDistanciaBesana()
        nBesana = Int(distanciaABesana / anchoApero)
        resto = distanciaABesana.truncatingRemainder(dividingBy: anchoApero)

        let rumboAB = comparaGrados(sentidoAB,rumbo)
        let rumboBA = comparaGrados(sentidoBA,rumbo)
        if (rumboAB > rumboBA) {
            rumboBesana = "BA"
            sentido = sentidoBA
            origen = besanaB
            desvioGrados = rumboBA

        }else{
            rumboBesana = "AB"
            sentido = sentidoAB
            origen = besanaA
            desvioGrados = rumboAB
        }
        rumboBesanaPosicion = bearing(actual,origen)
        posicionBesana = sentidoGiro(rumbo, rumboBesanaPosicion)
        moverRumbo = sentidoGiro(rumbo, sentido)

        if (resto > (anchoApero/2)){
            nBesana = nBesana + 1
            desvio = anchoApero - resto
            moverDesvio = noID(posicionBesana)
        }else{
            desvio = resto
            moverDesvio = posicionBesana
        }

    }
}

