import 'outstanding_invoice.dart';

abstract class ReceivablesRepository {
  Future<List<OutstandingInvoice>> list();
}
