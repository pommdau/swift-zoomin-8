import Foundation

// 競合を起こさないversion
actor BankAccount {
    var balance: Int = 0  // 預金残高
    func deposit(_ amount: Int) -> Int {  // 入金
        balance += amount
        return balance
    }
    
    // nonisolatedをつけた場合、外から見た場合と同じようにawaitが必要となる
    nonisolated func deposit2(_ amount: Int) {
        Task {
            await deposit(amount)
        }
    }
    
    func getInterest(with rate: Double) -> Int {  // 残高を増やす
        deposit(Int(Double(balance) * rate))
    }
    
}

func bankAccountMain() {

    let account: BankAccount = .init()

    Task {
        // Task内では順番は保証されている
        _ = await account.deposit(100)  // 100
        print(await account.deposit(100))  // 200
        print(await account.getInterest(with: 0.05))  // 210
    }
}

// 競合を起こすversion
/*
final class BankAccount {
    var balance: Int = 0
    func deposit(_ amount: Int) -> Int {
        let balance = self.balance
        Thread.sleep(forTimeInterval: 1)
        self.balance = balance + amount

        return self.balance
    }
}

func bankAccountMain() {

    let account: BankAccount = .init()
    
    Task.detached {
        print(Thread.current)
        print(account.deposit(100))
    }
    
    print(Thread.current)
    print(account.deposit(100))

}
*/
