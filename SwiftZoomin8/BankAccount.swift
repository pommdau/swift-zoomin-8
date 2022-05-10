import Foundation

// 競合を起こさないversion
actor BankAccount {
    var balance: Int = 0  // 預金残高
    func deposit(_ amount: Int) -> Int {  // 入金
        balance += amount
        return balance
    }
}

func bankAccountMain() {

    let account: BankAccount = .init()

    Task {
        print(await account.deposit(100))
    }

    Task {
        print(await account.deposit(100))
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
