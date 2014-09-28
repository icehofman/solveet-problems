import 'package:unittest/unittest.dart';

main() {
  
  test('1€ breaks down as a 1 coin of 1€', () {
    expect(breakdown(1), equals('1 coin of 1€'));
  });
  
  test('2€ breaks down as a 1 coin of 2€', () {
    expect(breakdown(2), equals('1 coin of 2€'));
  });
  
  test('3€ breaks down as a 1 coin of 2€, 1 coin of 1€', () {
    expect(breakdown(3), equals('1 coin of 2€, 1 coin of 1€'));
  });
  
  test('5€ breaks down as a 1 bill of 5€', () {
    expect(breakdown(5), equals('1 bill of 5€'));
  });

}

class Money {
  String type;
  int value;
  Money(this.type, this.value);
}

String breakdown(int amount) {
  List moneys = [
                 new Money('bill', 5),
                 new Money('coin', 2),
                 new Money('coin', 1)
                 ];

  List results = [];
  moneys.forEach((money) {
    if (amount >= money.value) {
      results.add('1 ' + money.type + ' of ' + money.value.toString() + '€');
      amount -= money.value;
    }
  });
  
  return results.join(', ');
}
