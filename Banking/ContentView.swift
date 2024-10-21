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
    let revenue: Double
}
struct FirstView: View {
    @State private var animateChart: Bool = false
    @State private var products: [Product] = [
            .init(title: "Annual", revenue: 0.7),
            .init(title: "Monthly", revenue: 0.2),
            .init(title: "Lifetime", revenue: 0.1)
        ]
    
    var body: some View {
        NavigationView {
            VStack {
                // Year Label
                HStack {
                    Text("Year 2024")
                        .font(.headline)
                        .foregroundColor(.green)
                    Spacer()
                }
                .padding(.leading)

                // Account Overview
                VStack {
                    HStack {
                        Text("Over View")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    .padding(.leading)
                    
                    Spacer().frame(height: 20)
                    
                    // Account balance section with Doughnut Chart
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Account Balance (year 2024)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        Spacer().frame(height: 10)
                        
                        HStack {
                            Text("$0.00")
                                .font(.system(size: 36))
                                .bold()
                            Spacer()
                        }
                        
                        // Doughnut Chart section
                        Spacer().frame(height: 20)
                        
                        ZStack {
                            Chart(products) { product in  SectorMark(
                                angle: .value(
                                    Text(verbatim: product.title),
                                    product.revenue
                                ),
                                innerRadius: .ratio(0.6),
                                angularInset: 8
                            )
                            .foregroundStyle(
                                by: .value(
                                    Text(verbatim: product.title),
                                    product.title
                                )
                            )
                        
                            }
                        }
                        .onAppear {
                            // Trigger the animation after the view appears
                            withAnimation {
                                animateChart = true
                            }
                        }
                        
                        Spacer().frame(height: 20)
                        
                        // No transaction message
                        HStack {
                            Text("transaction not found")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        Spacer().frame(height: 10)
                        HStack {
                            Text("pree +")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 20)
                    
                    // Suggestions section
                    HStack {
                        Text("suggestion")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.leading)
                    
                    HStack {
                        Text("no suggestion")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.leading)
                    
                    Spacer().frame(height: 20)
                    
                    // Account balance and planned transactions
                    VStack {
                        HStack {
                            Text("account balance")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                // Action for account details
                            }) {
                                HStack {
                                    Image(systemName: "banknote")
                                    Text("$0.00")
                                }
                            }
                        }
                        Spacer().frame(height: 10)
                        
                        HStack {
                            Text("transacation in plan")
                                .font(.headline)
                            Spacer()
                        }
                        Spacer().frame(height: 10)
                        
                        HStack {
                            Text("no transacation")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            Button(action: {
                                // Action for adding a new transaction
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .navigationTitle("")
                .navigationBarHidden(true)
            }
        }
        .background(Color.black)
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView()
    }
}
