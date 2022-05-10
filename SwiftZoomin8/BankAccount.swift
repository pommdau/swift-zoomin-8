import Foundation

// 競合を起こさないversion
actor BankAccount {
    private(set) var balance: Int = 0  // 預金残高. private(set)で外から参照可能になる
    
    @discardableResult
    func deposit(_ amount: Int) -> Int {  // 入金
        precondition(amount >= 0)  // 起こり得ない。ハンドリング不要なのでクラッシュさせてOK
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
    
    // MARK: - Transfer
    
    struct WithdrawalError: Error {}
    
    @discardableResult
    func withdraw(_ amount: Int) throws -> Int {
        precondition(amount >= 0)
        guard balance >= amount else {
            throw WithdrawalError()
        }
        balance -= amount
        return balance
    }
    
    func transfer(_ amount: Int, to account: BankAccount) async throws {
        _ = try withdraw(amount)
        _ = await account.deposit(amount)
    }
    
}

func bankAccountMain() {

    let account1: BankAccount = .init()
    let account2: BankAccount = .init()

    Task {
        // Task内では順番は保証されている
        await account1.deposit(100)
        try await account1.transfer(30, to: account2)
        print(await account1.balance)
        print(await account2.balance)
    }
    
//    var foo: Foo = .init()
//    foo.x = -100
//    do {
//        print(try foo.y)
//    } catch {
//        print(error.localizedDescription)
//    }
}

struct Foo {
    var x: Int = 0
    
    // throwsをつけたComputed Propertyを定義できる
    var y: Double {
        get throws {
            if x < 0 { throw NSError() }
            return Double(x).squareRoot()
        }
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
