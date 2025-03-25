//
//  ContentView.swift
//  Tic Tac Toe Game
//  6510615096 ณัฐภูพิชา อรุณกรพสุรักษ์
//  6510615211 พรนัชชา ประทีปสังคม
//

import SwiftUI

struct ContentView: View {
    @State var moves: [Move?] = Array(repeating: nil, count: 9)
    @State var isGameBoardDisabled = false
    @State var gameOver = false
    @State var currentPlayer: Player = .human
    @State var resultMessage = ""
    @State var startPastTurn: Player = .human

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                    ForEach(0..<9) { index in
                        CellView(mark: moves[index]?.mark ?? "")
                            .onTapGesture {
                                humanPlay(at: index)
                            }
                    }
                }
                .padding()
                .disabled(isGameBoardDisabled || gameOver)
                
                Spacer()
                
                if gameOver {
                    Text(resultMessage)
                        .font(.title)
                        .padding()
                    
                    Button("Play Again") {
                        resetGame()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.title2)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .frame(maxHeight: .infinity)
            .navigationTitle("Tic Tac Toe")
        }
    }
    
    func resetGame() {
        
        moves = Array(repeating: nil, count: 9)
        isGameBoardDisabled = false
        gameOver = false
        resultMessage = ""

        startPastTurn = (startPastTurn == .human) ? .computer : .human
        currentPlayer = startPastTurn
        
        if currentPlayer == .computer {
            isGameBoardDisabled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                computerPlay()
            }
        }
    }

    func humanPlay(at index: Int) {
        guard !isCellOccupied(in: moves, forIndex: index) else { return }
        guard currentPlayer == .human else { return }

        moves[index] = Move(player: .human, boardIndex: index)

        if checkWinCondition(for: .human, in: moves) {
            resultMessage = "You Won!"
            gameOver = true
            return
        }

        if checkForDraw(in: moves) {
            resultMessage = "It's a Draw!"
            gameOver = true
            return
        }

        currentPlayer = .computer
        isGameBoardDisabled = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            computerPlay()
        }
    }

    func computerPlay() {
        var moveMade = false

        if let winMove = findWinningMove(for: .computer) {
            moves[winMove] = Move(player: .computer, boardIndex: winMove)
            moveMade = true
        } else if let blockMove = findWinningMove(for: .human) {
            moves[blockMove] = Move(player: .computer, boardIndex: blockMove)
            moveMade = true
        } else if moves[4] == nil {
            moves[4] = Move(player: .computer, boardIndex: 4)
            moveMade = true
        }

        if !moveMade {
            let computerPosition = determineComputerMovePosition(in: moves)
            moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
        }

        if checkWinCondition(for: .computer, in: moves) {
            resultMessage = "You Lost!"
            gameOver = true
            return
        }

        if checkForDraw(in: moves) {
            resultMessage = "It's a Draw!"
            gameOver = true
            return
        }

        currentPlayer = .human
        isGameBoardDisabled = false
    }

    func checkForDraw(in moves: [Move?]) -> Bool {
        moves.compactMap { $0 }.count == 9
    }

    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        let winPatterns: [Set<Int>] = [
            [0,1,2],[3,4,5],[6,7,8],
            [0,3,6],[1,4,7],[2,5,8],
            [0,4,8],[2,4,6]
        ]
        let playerPositions = Set(moves.compactMap { $0 }.filter { $0.player == player }.map { $0.boardIndex })
        return winPatterns.contains { $0.isSubset(of: playerPositions) }
    }

    func findWinningMove(for player: Player) -> Int? {
        let winPatterns: [Set<Int>] = [
            [0,1,2],[3,4,5],[6,7,8],
            [0,3,6],[1,4,7],[2,5,8],
            [0,4,8],[2,4,6]
        ]

        let playerPositions = Set(moves.compactMap { $0 }.filter { $0.player == player }.map { $0.boardIndex })

        for pattern in winPatterns {
            let positions = pattern.intersection(playerPositions)
            let emptyPositions = pattern.subtracting(Set(moves.compactMap { $0?.boardIndex }))

            if positions.count == 2 && emptyPositions.count == 1 {
                return emptyPositions.first
            }
        }
        return nil
    }

    func isCellOccupied(in moves: [Move?], forIndex: Int) -> Bool {
        moves[forIndex] != nil
    }

    func determineComputerMovePosition(in moves: [Move?]) -> Int {
        var movePosition = Int.random(in: 0..<9)
        while isCellOccupied(in: moves, forIndex: movePosition) {
            movePosition = Int.random(in: 0..<9)
        }
        return movePosition
    }
}

enum Player {
    case human, computer
}

struct Move {
    let player: Player
    let boardIndex: Int
    var mark: String {
        player == .human ? "circle" : "xmark"
    }
}

struct CellView: View {
    let mark: String
    var body: some View {
        ZStack {
            Color.pink.opacity(0.5)
                .frame(width: squareSize, height: squareSize)
                .cornerRadius(15)

            Image(systemName: mark)
                .resizable()
                .frame(width: markSize, height: markSize)
                .foregroundColor(.white)
        }
    }
    var squareSize: CGFloat { UIScreen.main.bounds.width / 3 - 15 }
    var markSize: CGFloat { squareSize / 2 }
}

#Preview {
    ContentView()
}
