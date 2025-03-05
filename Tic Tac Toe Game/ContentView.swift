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
    @State var gameOver = false //ตรวจว่าเกมจบหรือยัง
    var body: some View {
        NavigationView() {
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                ForEach(0..<9) { index in
                    CellView(mark: moves[index]?.mark ?? "")
                        .onTapGesture {
                            isGameBoardDisabled.toggle()
                            if humanPlay(at: index) { return }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if computerPlay() { return }
                                isGameBoardDisabled.toggle()
                            }
                        }
                }
            }
            .padding().disabled(isGameBoardDisabled).navigationTitle("Tic Tac Toe")
        }
        if gameOver {
            Button("Play Again") {
                resetGame()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
            .font(.title2)
        }
    }
    func resetGame() {
        moves = Array(repeating: nil, count: 9)
        isGameBoardDisabled = false
        gameOver = false
    }
    func humanPlay(at index: Int) -> Bool {
        moves[index] = Move(player: .human, boardIndex: index)
        if checkWinCondition(for: .human, in: moves) {
            print("You won!")
            gameOver = true
            return true
        }
        if checkForDraw(in: moves) {
            print("Draw")
            gameOver = true
            return true
        }
        return false
    }
    func computerPlay() -> Bool {
        let computerPosition = determineComputerMovePoswition(in: moves)
        moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
        if checkWinCondition(for: .computer, in: moves) {
            print("You lost!")
            gameOver = true
            return true
        }
        return false
    }
    func checkForDraw(in moves: [Move?]) -> Bool {
        moves.compactMap { $0 }.count == 9
    }
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        let winPatterns: [Set<Int>] = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
        let playerMoves = moves.compactMap { $0 }.filter { $0.player == player } //move = parameter, $0 = parameter ตัวแรก, มี 2 ตัวก็ $0 $1
        let playerPositions = Set(playerMoves.map { $0.boardIndex })
        // ลบค่าใน set ไปเรื่อยๆ เหลือช่องสุดท้ายให้วางให้ชนะ หรือเหลือช่องสุดท้ายคนจะชนะก็ให้คอมไปวางขวางไว้
        for pattern in winPatterns where pattern.isSubset(of: playerPositions) {
            return true
        }
        return false
    }
    func isCellOccupied(in moves: [Move?], forIndex: Int) -> Bool {
        moves[forIndex] != nil
    }
    func determineComputerMovePoswition(in moves: [Move?]) -> Int {
        var movePosition = Int.random(in: 0..<9)
        while isCellOccupied(in: moves, forIndex: movePosition) {
            movePosition = Int.random(in: 0..<9)
        }
        return movePosition
    }
}

// View
enum Player {
    case human, computer
}

// Model
struct Move {
    let player: Player
    let boardIndex: Int
    var mark: String {
        player == .human ? "xmark" : "circle"
    }
}

struct CellView: View {
    let mark: String
    var body: some View {
        ZStack {
            Color.blue.opacity(0.5).frame(width: squareSize, height: squareSize).cornerRadius(15)
            Image(systemName: mark)    // ?? = default | "" = blank
                .resizable().frame(width: markSize, height: markSize).foregroundColor(.white)
        }
    }
    var squareSize: CGFloat { UIScreen.main.bounds.width / 3 - 15 }
    var markSize: CGFloat { squareSize / 2 }
}

#Preview {
    ContentView()
}
