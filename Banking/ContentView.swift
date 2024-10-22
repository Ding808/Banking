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
        .init(title: "Annual", revenue: 0.1),
        .init(title: "Monthly", revenue: 0.2),
        .init(title: "Lifetime", revenue: 0.7)
    ]
    @State private var selectedProduct: Product?
    @State private var isDetailLocked: Bool = false
    @State private var touchLocation: CGPoint?

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
                            Chart(products) { product in
                                SectorMark(
                                    angle: .value(
                                        Text(verbatim: product.title),
                                        animateChart ? product.revenue : 0 // Start from 0
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

                            // Adding an overlay to handle taps
                            GeometryReader { geometry in
                                Color.clear
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                guard !isDetailLocked else { return }
                                                let touchLocation = value.location
                                                self.touchLocation = touchLocation
                                                let center = CGPoint(
                                                    x: geometry.size.width / 2,
                                                    y: geometry.size.height / 2
                                                )
                                                let touchAngle = angleFromPoint(center: center, point: touchLocation)
                                                let totalRevenue = products.map(\.revenue).reduce(0, +)
                                                var currentAngle: Double = 0

                                                for product in products {
                                                    let productAngle = 360 * (product.revenue / totalRevenue)
                                                    if touchAngle >= currentAngle && touchAngle <= currentAngle + productAngle {
                                                        selectedProduct = product
                                                        break
                                                    }
                                                    currentAngle += productAngle
                                                }
                                            }
                                            .onEnded { _ in
                                                if !isDetailLocked {
                                                    selectedProduct = nil
                                                }
                                            }
                                    )
                                    .simultaneousGesture(
                                        TapGesture(count: 2)
                                            .onEnded {
                                                isDetailLocked.toggle()
                                            }
                                    )
                            }

                            // Tooltip view for showing details
                            if let selectedProduct = selectedProduct, let touchLocation = touchLocation {
                                VStack {
                                    Text("\(selectedProduct.title)")
                                        .font(.headline)
                                        .padding(4)
                                    Text("Revenue: \(selectedProduct.revenue * 100, specifier: "%.1f")%")
                                        .font(.subheadline)
                                        .padding(4)
                                }
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 5)
                                .position(x: touchLocation.x, y: touchLocation.y - 50)
                                .animation(.easeInOut)
                            }
                        }
                        .onAppear {
                            // Trigger the animation after the view appears
                            withAnimation(.easeInOut(duration: 1.5)) {
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
                            Text("press +")
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
                            Text("transaction in plan")
                                .font(.headline)
                            Spacer()
                        }
                        Spacer().frame(height: 10)

                        HStack {
                            Text("no transaction")
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

    // Function to calculate angle from center to a given point
    private func angleFromPoint(center: CGPoint, point: CGPoint) -> Double {
        let deltaX = point.x - center.x
        let deltaY = point.y - center.y
        let radians = atan2(deltaY, deltaX)
        var degrees = radians * 180 / .pi
        if degrees < 0 {
            degrees += 360
        }
        
        // Adjust for the 90-degree rotation of the chart
        degrees += 90
        if degrees >= 360 {
            degrees -= 360
        }
        
        return degrees
    }
}
