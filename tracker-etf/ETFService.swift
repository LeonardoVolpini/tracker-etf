//
//  ETFService.swift
//  tracker-etf
//
//  Created by Leonardo Volpini on 10/03/25.
//

import Foundation

// Modello dati per rappresentare un ETF con il simbolo e il prezzo
struct ETFData: Codable {
    let symbol: String
    let price: Double
}

// Classe che gestisce il recupero dei dati degli ETF da Yahoo Finance
class ETFService: ObservableObject {
    @Published var etfs: [ETFData] = []  // Lista degli ETF da mostrare nell'app
    private var historicalMax: [String: Double] = [:] // Storico dei massimi per ogni ETF

    // Funzione per recuperare il prezzo attuale di un ETF dato il simbolo (es. "VOO" per Vanguard S&P 500)
    func fetchETFPrice(for symbol: String) {
        // URL dell'API di Yahoo Finance per ottenere il prezzo di un simbolo specifico
        let urlString = "https://query1.finance.yahoo.com/v7/finance/quote?symbols=\(symbol)"
        
        // Controllo che l'URL sia valido
        guard let url = URL(string: urlString) else {
            print("❌ Errore: URL non valido")
            return
        }

        // Creazione richiesta HTTP asincrona per ottenere i dati
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    // Decodifica JSON ottenuto in oggetti Swift
                    let decodedData = try JSONDecoder().decode(QuoteResponse.self, from: data)
                    
                    // Se risultato valido, aggiorno la lista di ETF
                    if let quote = decodedData.quoteResponse.result.first {
                        DispatchQueue.main.async {
                            let etf = ETFData(symbol: quote.symbol, price: quote.regularMarketPrice)
                            self.etfs.append(etf)
                            
                            self.updateMaxPrice(for: quote.symbol, price: quote.regularMarketPrice)
                            
                            self.checkETFDrop(for: quote.symbol, price: quote.regularMarketPrice)
                        }
                    }
                } catch {
                    print("❌ Errore nella decodifica del JSON: \(error)")
                }
            }
        }.resume()  // Avvio della richiesta HTTP
    }
    
    // Aggiorna il massimo degli ultimi 30 giorni
    private func updateMaxPrice(for symbol: String, price: Double) {
        if let currentMax = historicalMax[symbol] {
            historicalMax[symbol] = max(currentMax, price)
        } else {
            historicalMax[symbol] = price
        }
    }
    
    private func checkETFDrop(for symbol: String, price: Double) {
        guard let max30Days = historicalMax[symbol] else { return }
        let threshold = max30Days * 0.9 // Calcoliamo il -10% dal massimo

        if price < threshold {
            let message = "⚠️ ALERT: \(symbol) ha perso più del 10% dal massimo degli ultimi 30 giorni! Prezzo attuale: \(price) USD."
            TelegramService.shared.sendTelegramMessage(message)
        }
    }

}

// Strutture per decodificare la risposta JSON di Yahoo Finance
struct QuoteResponse: Codable {
    let quoteResponse: QuoteResult
}

struct QuoteResult: Codable {
    let result: [Quote]
}

struct Quote: Codable {
    let symbol: String
    let regularMarketPrice: Double  // Prezzo di mercato corrente
}
