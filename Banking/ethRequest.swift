//
//  File.swift
//  Banking
//
//  Created by Yueyang Ding on 2024-10-23.
//
import Foundation

// Structure for the API request
struct InfuraRequest: Encodable {
    let jsonrpc: String = "2.0"
    let method: String
    let params: [String]
    let id: Int
}

// Structure for the API response (generic)
struct InfuraResponse: Decodable {
    let jsonrpc: String
    let id: Int
    let result: String
}

// Function to fetch Ethereum balance
func fetchEthereumBalance(for address: String, completion: @escaping (Double?) -> Void) {
    guard let projectID = Config.shared.getAPIKey(for: "InfuraAPIKey") else {
        print("Infura API Key not found")
        completion(nil)
        return
    }

    let url = URL(string: "https://mainnet.infura.io/v3/\(projectID)")!

    // Create request to get balance of a specific address
    let balanceRequest = InfuraRequest(method: "eth_getBalance", params: [address, "latest"], id: 1)

    // Encode the request body to JSON
    guard let balanceRequestData = try? JSONEncoder().encode(balanceRequest) else {
        print("Failed to encode request data.")
        return
    }

    // Fetch balance
    makePostRequest(with: url, body: balanceRequestData) { data in
        guard let data = data, let response = try? JSONDecoder().decode(InfuraResponse.self, from: data) else {
            print("Failed to fetch balance.")
            completion(nil)
            return
        }

        let hexBalance = response.result
        let hexBalanceString = String(hexBalance.dropFirst(2))  // Drop '0x' prefix from hex

        // Convert hex string to decimal number (in Wei)
        let balanceInWei = NSDecimalNumber(hexString: hexBalanceString)

        if balanceInWei == NSDecimalNumber.notANumber {
            print("Failed to convert balance to a valid number.")
            completion(nil)
            return
        }

        // Convert wei to ether (1 Ether = 10^18 Wei)
        let weiToEther = NSDecimalNumber(mantissa: 1, exponent: 18, isNegative: false)
        let balanceInEth = balanceInWei.dividing(by: weiToEther)

        // Return the balance using the completion handler
        completion(balanceInEth.doubleValue)
    }
}

// Function to fetch ETH to USDT rate using CoinMarketCap API
func fetchEthToUsdtRate(completion: @escaping (Double?) -> Void) {
    guard let apiKey = Config.shared.getAPIKey(for: "CoinMarketCapAPIKey") else {
        print("CoinMarketCap API Key not found")
        completion(nil)
        return
    }

    let url = URL(string: "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=ETH&convert=USDT")!
    var request = URLRequest(url: url)
    request.addValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("Failed to fetch conversion rate: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               let ethData = dataDict["ETH"] as? [String: Any],
               let quote = ethData["quote"] as? [String: Any],
               let usdtQuote = quote["USDT"] as? [String: Any],
               let price = usdtQuote["price"] as? Double {
                completion(price)
            } else {
                print("Invalid response format")
                completion(nil)
            }
        } catch {
            print("Failed to parse conversion rate: \(error.localizedDescription)")
            completion(nil)
        }
    }
    task.resume()
}

// Helper function for POST request
func makePostRequest(with url: URL, body: Data, completion: @escaping (Data?) -> Void) {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = body

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            completion(nil)
            return
        }
        completion(data)
    }
    task.resume()
}

// Utility extension to convert hex string to NSDecimalNumber
extension NSDecimalNumber {
    convenience init(hexString: String) {
        let decimalValue = UInt64(hexString, radix: 16) ?? 0
        self.init(value: decimalValue)
    }
}
