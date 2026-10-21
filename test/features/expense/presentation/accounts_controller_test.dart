import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/controllers/account_form_controller.dart';
import 'package:dailytrack/features/expense/presentation/controllers/accounts_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

/// EXP-06 and EXP-07 controller intents (T101).
void main() {
  late ExpenseFakes f;
  late ProviderContainer c;

  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await pumpEventQueue();
    }
  }

  setUp(() {
    f = ExpenseFakes.withDefaults()
      ..addAccount('SBI', id: 'sbi', opening: 1000)
      ..addAccount('Old', id: 'old', archived: true, opening: 50);
    c = ProviderContainer(overrides: f.overrides);
    addTearDown(c.dispose);
  });

  group('AccountsController', () {
    AccountsData data() => c.read(accountsControllerProvider).value!;
    AccountsController ctrl() => c.read(accountsControllerProvider.notifier);

    setUp(() async {
      c.listen(accountsControllerProvider, (_, _) {});
      await settle();
    });

    test('splits active and archived; the total counts active only', () {
      expect(data().active.map((a) => a.account.id), ['cash', 'sbi']);
      expect(data().archived.single.account.id, 'old');
      expect(data().totalMinor, 1000);
      expect(data().canRemoveActive, isTrue);
    });

    test(
      'archive returns an undo; the last active account is refused (Q3)',
      () async {
        final undo = await ctrl().setArchived('sbi', archived: true);
        await settle();
        expect(data().active.single.account.id, 'cash');
        expect(data().canRemoveActive, isFalse);
        expect(await ctrl().setArchived('cash', archived: true), isNull);
        expect(await ctrl().delete('cash'), isNull);

        await undo!();
        await settle();
        expect(data().active, hasLength(2));
      },
    );

    test('delete refuses an account with transactions', () async {
      f.addTransaction(amount: 1, account: 'sbi', category: 'food');
      await settle();
      expect(await ctrl().delete('sbi'), isNull);
      final undo = await ctrl().delete('old');
      expect(undo, isNotNull);
      await settle();
      expect(data().archived, isEmpty);
    });
  });

  group('AccountFormController', () {
    Future<AccountFormControllerProvider> ready(String? id) async {
      final p = accountFormControllerProvider(id);
      c.listen(p, (_, _) {});
      await settle();
      return p;
    }

    test('new: ready at once with type Cash and an empty balance', () async {
      final p = await ready(null);
      final s = c.read(p);
      expect(s.status, AccountFormStatus.ready);
      expect(s.type, AccountType.cash);
      expect(c.read(p.notifier).openingBalanceMinor, 0);
    });

    test('the keypad and the sign toggle make a signed balance', () async {
      final p = await ready(null);
      final ctrl = c.read(p.notifier)
        ..key('1')
        ..key('2')
        ..key('.')
        ..key('5')
        ..setNegative(negative: true);
      expect(ctrl.openingBalanceMinor, -1250);
      ctrl
        ..operator('+')
        ..key('1')
        ..operator('=');
      expect(c.read(p).openingExpression, '13.50');
      expect(ctrl.openingBalanceMinor, -1350);
    });

    test('save validates, then creates', () async {
      final p = await ready(null);
      final ctrl = c.read(p.notifier);
      expect(await ctrl.save(), isNull);
      expect(c.read(p).errors.keys, contains(isNotNull));
      ctrl
        ..setName('Paytm')
        ..setType(AccountType.wallet);
      final saved = await ctrl.save();
      expect(saved!.type, AccountType.wallet);
      expect(f.world.accounts[saved.id]!.name, 'Paytm');
    });

    test('edit loads the account, including a negative opening', () async {
      f.addAccount('Card', id: 'card', opening: -2550);
      final p = await ready('card');
      final s = c.read(p);
      expect(s.isEdit, isTrue);
      expect(s.negative, isTrue);
      expect(s.openingExpression, '25.50');
      expect(c.read(p.notifier).openingBalanceMinor, -2550);
    });
  });
}
