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
                        }
                    }
                } catch {
                    print("❌ Errore nella decodifica del JSON: \(error)")
                }
            }
        }.resume()  // Avvio della richiesta HTTP
    }
    
    func checkETFDrop(for symbol: String) {
        let max30Days: Double = 500.0  // Supponiamo di ottenere questo valore dall'API
        let threshold = max30Days * 0.9 // Calcoliamo il -10% dal massimo
        
        fetchETFPrice(for: symbol)  // Prezzo attuale

        if let etf = etfs.first(where: { $0.symbol == symbol }) {
            if etf.price < threshold {
                print("⚠️ ALERT: \(symbol) è sceso sotto il 10% dal massimo!")
            }
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
