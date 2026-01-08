import 'package:coworkhub_mobile/models/payment_method.dart';
import 'package:coworkhub_mobile/providers/base_provider.dart';

class PaymentMethodProvider extends BaseProvider<PaymentMethod> {
  PaymentMethodProvider() : super("PaymentMethod");

  @override
  PaymentMethod fromJson(data) {
    return PaymentMethod.fromJson(data);
  }
}
