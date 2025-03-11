//
//  TelegramService.swift
//  tracker-etf
//
//  Created by Leonardo Volpini on 11/03/25.
//

import Foundation

class TelegramService {
    static let shared = TelegramService()
    
    private init() {}
    
    func sendTelegramMessage(_ message: String) {
        let botToken = "7799474797:AAERqqyB3CJ4SzYy7WGdlsPq2rcOHF2K3i4"
        let chatID = "283475397"
        let urlString = "https://api.telegram.org/bot\(botToken)/sendMessage?chat_id=\(chatID)&text=\(message)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Errore nell'invio del messaggio Telegram: \(error.localizedDescription)")
            } else {
                print("Messaggio Telegram inviato con successo!")
            }
        }.resume()
    }
}
