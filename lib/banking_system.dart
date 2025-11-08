  //  Banking System OOP – Final Clean Version (Dart)

  abstract class BankAccount {
    final String _accountNumber;
    String _holderName;
    double _balance;

    BankAccount(this._accountNumber, this._holderName, this._balance) {
      if (_accountNumber.trim().isEmpty) {
        throw ArgumentError('Account number cannot be empty');
      }
      if (_holderName.trim().isEmpty) {
        throw ArgumentError('Account holder name cannot be empty');
      }
      if (_balance.isNaN || _balance.isInfinite) {
        throw ArgumentError('Invalid opening balance');
      }
    }

    //  Encapsulation: Private fields with getters/setters
    String get accountNumber => _accountNumber;
    String get holderName => _holderName;
    double get balance => _balance;

    set holderName(String name) {
      if (name.trim().isEmpty) throw ArgumentError('Name cannot be empty');
      _holderName = name.trim();
    }

    //   (Encapsulation)
    void credit(double amount) {
      _requirePositive(amount, 'Deposit amount must be > 0');
      _balance += amount;
    }

    void debit(double amount) {
      _requirePositive(amount, 'Withdrawal amount must be > 0');
      _balance -= amount;
    }

    void _requirePositive(double amount, String msg) {
      if (amount <= 0) throw ArgumentError(msg);
    }

  //  Common behaviors
  void deposit(double amount) => credit(amount);

  void displayInfo() =>
      print('$holderName ($accountNumber): \$${balance.toStringAsFixed(2)}');

  // Abstraction
  void withdraw(double amount);
}

//  Interface for interest-bearing accounts
abstract class InterestBearing {
  double calculateInterest();
}

//  Savings Account
class SavingsAccount extends BankAccount implements InterestBearing {
  static const double minBalance = 500;
  static const double interestRate = 0.02; // annual
  int withdrawals = 0;

  SavingsAccount(String accNo, String name, double bal)
      : super(accNo, name, bal) {
    if (balance < minBalance) {
      throw ArgumentError(
          'Savings requires opening balance >= \$${minBalance.toStringAsFixed(2)}');
    }
  }

  @override
  void withdraw(double amount) {
    if (withdrawals >= 3) {
      print('Withdrawal limit reached!');
      return;
    }
    if (balance - amount < minBalance) {
      print('Cannot go below minimum balance!');
      return;
    }
    debit(amount);
    withdrawals++;
  }

  @override
  double calculateInterest() => balance * (interestRate / 12.0);
}

// Checking Account
class CheckingAccount extends BankAccount {
  static const double overdraftFee = 35;

  CheckingAccount(String accNo, String name, double bal)
      : super(accNo, name, bal);

  @override
  void withdraw(double amount) {
    debit(amount);
    if (balance < 0) {
      print('⚠️ Overdraft! Fee applied.');
      debit(overdraftFee);
    }
  }
}

//  Premium Account
class PremiumAccount extends BankAccount implements InterestBearing {
  static const double minBalance = 10000;
  static const double interestRate = 0.05; // annual

  PremiumAccount(String accNo, String name, double bal)
      : super(accNo, name, bal) {
    if (balance < minBalance) {
      throw ArgumentError(
          'Premium requires opening balance >= \$${minBalance.toStringAsFixed(2)}');
    }
  }

  @override
  void withdraw(double amount) {
    if (balance - amount < 0) {
      print(' Insufficient funds!');
      return;
    }
    debit(amount);
  }

  @override
  double calculateInterest() => balance * (interestRate / 12.0);
}

// Student Account
class StudentAccount extends BankAccount {
  static const double maxBalance = 5000;

  StudentAccount(String accNo, String name, double bal)
      : super(accNo, name, bal) {
    if (balance > maxBalance) {
      throw ArgumentError(
          'StudentAccount opening balance cannot exceed \$${maxBalance.toStringAsFixed(2)}');
    }
  }

  @override
  void withdraw(double amount) {
    if (balance - amount < 0) {
      print('Insufficient funds!');
      return;
    }
    debit(amount);
  }

  @override
  void deposit(double amount) {
    if (balance + amount > maxBalance) {
      print(' Cannot exceed maximum balance!');
      return;
    }
    credit(amount);
  }
}

//  Bank Class 
class Bank {
  final List<BankAccount> accounts = [];

  void addAccount(BankAccount account) => accounts.add(account);

  BankAccount findAccount(String number) {
    return accounts.firstWhere(
      (acc) => acc.accountNumber == number,
      orElse: () => throw StateError('Account not found: $number'),
    );
  }

  void transfer(String fromAcc, String toAcc, double amount) {
    if (fromAcc == toAcc) {
      throw ArgumentError('Cannot transfer to the same account');
    }
    final sender = findAccount(fromAcc);
    final receiver = findAccount(toAcc);

    final senderStart = sender.balance;
    try {
      sender.withdraw(amount);
      receiver.deposit(amount);
    } catch (e) {
      if (sender.balance != senderStart) {
        sender.deposit(amount);
      }
      rethrow;
    }
  }

  // Fixed version of applyMonthlyInterest
  void applyMonthlyInterest() {
    for (final acc in accounts) {
      if (acc is InterestBearing) {
        final ib = acc as InterestBearing;
        final interest = ib.calculateInterest();
        if (interest > 0) acc.deposit(interest);
      }
    }
  }

  void displayAll() {
    print('\n Bank Report:');
    for (var acc in accounts) {
      acc.displayInfo();
    }
    print('-----------------------------------');
  }
}

//  Main Program
void main() {
  final bank = Bank();

  final s1 = SavingsAccount('SAV001', 'Sujan', 1500);
  final c1 = CheckingAccount('CHK001', 'bishal', 500);
  final p1 = PremiumAccount('PRM001', 'gm', 20000);
  final st1 = StudentAccount('STD001', 'susan', 1000);

  bank.addAccount(s1);
  bank.addAccount(c1);
  bank.addAccount(p1);
  bank.addAccount(st1);

  // Demonstrate features
  s1.withdraw(200);
  c1.withdraw(600);
  bank.transfer('SAV001', 'PRM001', 100);
  bank.applyMonthlyInterest();
  bank.displayAll();
}
