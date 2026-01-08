import 'package:coworkhub_mobile/models/payment.dart';
import 'package:coworkhub_mobile/providers/base_provider.dart';

class PaymentProvider extends BaseProvider<Payment> {
  PaymentProvider() : super("Payment");

  @override
  Payment fromJson(data) {
    return Payment.fromJson(data);
  }
}
