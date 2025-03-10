//
//  ContentView.swift
//  tracker-etf
//
//  Created by Leonardo Volpini on 10/03/25.
//

import SwiftUI  // Importiamo il framework per la UI

struct ContentView: View {
    @StateObject var etfService = ETFService()
    @State private var symbol: String = ""  // Stato per memorizzare il simbolo dell'ETF inserito dall'utente

    var body: some View {
        NavigationView {  //barra di navigazione
            VStack {
                TextField("Inserisci simbolo ETF", text: $symbol)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Bottone per aggiungere un ETF
                Button("Aggiungi ETF") {
                    //recupero il prezzo
                    etfService.fetchETFPrice(for: symbol)
                }
                .padding()
                .background(Color.blue)  // Sfondo blu
                .foregroundColor(.white)  // Testo bianco
                .cornerRadius(8)

                // Lista che mostra gli ETF aggiunti
                List(etfService.etfs, id: \.symbol) { etf in
                    HStack {
                        Text(etf.symbol)  // Simbolo dell'ETF
                            .font(.headline)  // Testo grande
                        Spacer()
                        Text("\(etf.price, specifier: "%.2f") $")  // Prezzo con 2 decimali
                            .foregroundColor(.green)  // Testo verde per i prezzi
                    }
                }
            }
            .navigationTitle("ETF Tracker")  // Titolo della schermata
        }
    }
}

#Preview {
    ContentView()
}
