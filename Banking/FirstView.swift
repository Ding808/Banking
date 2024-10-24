//
//  ContentView.swift
//  Banking
//
//  Created by Yueyang Ding on 2024-10-21.
//
import SwiftUI
import Charts

struct Product: Identifiable {
    let id = UUID()
    let title: String
    var revenue: Double
}

struct FirstView: View {
    @State private var ethereumAddress: String = ""  // Empty by default
    @State private var ethereumBalance: Double = 0.0  // This will hold the balance fetched from the API
    @State private var usdtBalance: Double = 0.0  // This will hold the converted USDT balance
    @State private var ethToUsdtRate: Double = 0.0  // ETH to USDT conversion rate
    @State private var animateChart: Bool = false
    @State private var products: [Product] = [
        .init(title: "Annual", revenue: 0.1),
        .init(title: "Monthly", revenue: 0.2),
        .init(title: "Lifetime", revenue: 0.7)
    ]
    @State private var selectedProduct: Product?
    @State private var isDetailLocked: Bool = false
    @State private var touchLocation: CGPoint?
    
    // Timer for refreshing rate every 5 seconds
    @State private var timer: Timer?

    var body: some View {
            NavigationView {
                VStack {
                    HStack {
                        Text("Over View")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    .padding(.leading)

                    HStack {
                        Text("Year 2024")
                            .font(.headline)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    .padding(.leading)

                    // Ethereum Address Input with "Enter" Button
                    HStack {
                        TextField("Enter Ethereum Address", text: $ethereumAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading)

                        Button(action: {
                            // Update the Ethereum balance when the user presses Enter
                            fetchEthereumBalance(for: ethereumAddress) { balance in
                                ethereumBalance = balance ?? 0.0
                                fetchEthToUsdtRate { rate in
                                    if let rate = rate {
                                        ethToUsdtRate = rate
                                        usdtBalance = ethereumBalance * rate
                                    }
                                }
                            }
                        }) {
                            Text("Enter")
                                .font(.headline)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 15)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.trailing)
                    }

                    // Account Overview
                    VStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Account Balance (year 2024)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                            }

                            HStack {
                                Text("\(String(format: "%.20f", ethereumBalance)) ETH")  // Show the balance fetched
                                    .font(.system(size: 36))
                                    .bold()
                                Spacer()
                            }

                            // Doughnut Chart section
                            Spacer().frame(height: 10)

                            ZStack {
                                Chart(products) { product in
                                    SectorMark(
                                        angle: .value(
                                            Text(verbatim: product.title),
                                            animateChart ? product.revenue : 0
                                        ),
                                        innerRadius: .ratio(0.6),
                                        angularInset: 2
                                    )
                                    .cornerRadius(6)
                                    .foregroundStyle(
                                        by: .value(
                                            Text(verbatim: product.title),
                                            product.title
                                        )
                                    )
                                }
                                .rotationEffect(.degrees(animateChart ? 0 : -180))
                            }
                            .onAppear {
                                // Fetch Ethereum balance and ETH to USDT rate immediately on view appear
                                fetchEthereumBalance(for: ethereumAddress) { balance in
                                    ethereumBalance = balance ?? 0.0
                                    fetchEthToUsdtRate { rate in
                                        if let rate = rate {
                                            ethToUsdtRate = rate
                                            usdtBalance = ethereumBalance * rate
                                        }
                                    }
                                }
                                refreshChartAnimation()
                                startTimer()  // Start the timer when the view appears
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)

                        Spacer().frame(height: 20)

                        // Conversion rate section
                        VStack {
                            HStack {
                                Text("Conversion Rate: ")
                                    .font(.headline)
                                Spacer()
                                Text("\(ethToUsdtRate, specifier: "%.2f") USDT")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()

                            HStack {
                                Text("Balance in USDT")
                                    .font(.headline)
                                Spacer()
                                Button(action: {
                                    // Action for balance details
                                }) {
                                    HStack {
                                        Image(systemName: "banknote")
                                        Text("\(String(format: "%.4f", usdtBalance)) USDT")
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)

                        Spacer()
                    }
                    .navigationBarItems(
                        trailing: Button(action: {
                            // Fetch the Ethereum balance again when the user presses the refresh button
                            fetchEthereumBalance(for: ethereumAddress) { balance in
                                if let newBalance = balance {
                                    ethereumBalance = newBalance
                                    fetchEthToUsdtRate { rate in
                                        if let newRate = rate {
                                            ethToUsdtRate = newRate
                                            usdtBalance = ethereumBalance * newRate
                                        }
                                    }
                                }
                            }
                            refreshChartAnimation()  // Refresh the chart animation
                        }) {
                            Image(systemName: "arrow.clockwise")  // Refresh icon
                                .imageScale(.large)
                        }
                    )

                }
            }
        }


    // Function to calculate angle from center to a given point
    private func angleFromPoint(center: CGPoint, point: CGPoint) -> Double {
        let deltaX = point.x - center.x
        let deltaY = point.y - center.y
        let radians = atan2(deltaY, deltaX)
        var degrees = radians * 180 / .pi
        if degrees < 0 {
            degrees += 360
        }
        degrees += 90
        if degrees >= 360 {
            degrees -= 360
        }
        return degrees
    }

    // Function to refresh chart animation
    private func refreshChartAnimation() {
        animateChart = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 1.5)) {
                animateChart = true
            }
        }
    }

    // Function to fetch ETH to USDT rate using CoinMarketCap API
   

    // Start timer to refresh rate every 5 seconds
    private func startTimer() {
            timer?.invalidate()  // Invalidate any existing timer
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                fetchEthToUsdtRate { rate in
                    if let rate = rate {
                        ethToUsdtRate = rate
                        usdtBalance = ethereumBalance * rate
                    }
                }
            }
        }

        // Stop the timer if needed (e.g., on view disappear)
        private func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
}
