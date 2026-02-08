import 'package:coworkhub_mobile/providers/payment_provider.dart';
import 'package:coworkhub_mobile/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:provider/provider.dart';

import '../models/space_unit.dart';
import '../models/payment_method.dart';
import '../providers/payment_method_provider.dart';

class PaymentMethodScreen extends StatefulWidget {
  final SpaceUnit spaceUnit;
  final DateTimeRange dateRange;
  final int peopleCount;
  final int reservationId;

  const PaymentMethodScreen({
    super.key,
    required this.spaceUnit,
    required this.dateRange,
    required this.peopleCount,
    required this.reservationId,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  List<PaymentMethod> paymentMethods = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
  }

  Future<void> _fetchPaymentMethods() async {
    try {
      final provider = context.read<PaymentMethodProvider>();
      final result = await provider.get(filter: {"RetrieveAll": true});

      setState(() {
        paymentMethods = result.resultList
            .where((x) => x.isDeleted == false)
            .toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      showTopFlushBar(
        context: context,
        message: "Greška pri učitavanju metoda plaćanja",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final days =
        widget.dateRange.end.difference(widget.dateRange.start).inDays + 1;

    double totalPrice;

    if (widget.spaceUnit.workspaceTypeId == 1) {
      totalPrice = widget.peopleCount * widget.spaceUnit.pricePerDay * days;
    } else {
      totalPrice = widget.spaceUnit.pricePerDay * days;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Plaćanje")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info
            Text(
              widget.spaceUnit.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Period: $days dana"),
            Text(
              "Cijena po danu: ${widget.spaceUnit.pricePerDay.toStringAsFixed(2)} KM",
            ),
            Text("Broj osoba: ${widget.peopleCount}"),
            const SizedBox(height: 5),
            Text(
              widget.spaceUnit.workspaceTypeId == 1
                  ? "Računica: $days dana x ${widget.spaceUnit.pricePerDay.toStringAsFixed(2)} KM x ${widget.peopleCount} osoba"
                  : "Računica: $days dana x ${widget.spaceUnit.pricePerDay.toStringAsFixed(2)} KM",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              "Ukupno: ${totalPrice.toStringAsFixed(2)} KM",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            const Text(
              "Odaberite način plaćanja",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Način plaćanja
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : paymentMethods.isEmpty
                  ? const Center(
                      child: Text(
                        "Nema dostupnih metoda plaćanja",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: paymentMethods.length,
                      itemBuilder: (context, index) {
                        final method = paymentMethods[index];

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: _paymentIcon(method.paymentMethodName),
                            title: Text(method.paymentMethodName),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              _handlePaymentMethodTap(method, totalPrice);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePaymentMethodTap(PaymentMethod method, double totalPrice) async {
    if (method.paymentMethodName.toLowerCase() != "paypal") {
      showTopFlushBar(
        context: context,
        message: "Metoda plaćanja nije podržana",
        backgroundColor: Colors.orange,
      );
      return;
    }

    final bool? isSuccess = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PaypalCheckoutView(
          sandboxMode: true,
          clientId: dotenv.env['PAYPAL_CLIENT_ID'] ?? "",
          secretKey: dotenv.env['PAYPAL_SECRET'] ?? "",
          transactions: [
            {
              "amount": {
                "total": totalPrice.toStringAsFixed(2),
                "currency": "USD",
                "details": {
                  "subtotal": totalPrice.toStringAsFixed(2),
                  "shipping": '0',
                },
              },
              "description": "Payment",
              "item_list": {
                "items": [
                  {
                    "name": widget.spaceUnit.name,
                    "quantity": 1,
                    "price": totalPrice.toStringAsFixed(2),
                    "currency": "USD",
                  },
                ],
              },
            },
          ],
          note: "Hvala na bukiranju!",

          onSuccess: (Map params) async {
            try {
              final paymentProvider = context.read<PaymentProvider>();

              await paymentProvider.insert({
                "reservationId": widget.reservationId,
                "paymentMethodId": 2,
                "totalPaymentAmount": totalPrice,
                "discount": 0,
              });

              if (!context.mounted) return;

              Navigator.of(context).pop(true);
            } catch (e) {
              if (!context.mounted) return;
              Navigator.of(context).pop(false);
            }
          },

          onError: (error) {
            if (!context.mounted) return;
            Navigator.of(context).pop(false);
          },

          onCancel: () {
            if (!context.mounted) return;
            Navigator.of(context).pop(false);
          },
        ),
      ),
    );

    if (!mounted) return;

    Navigator.of(context).pop(isSuccess);
  }

  Widget _paymentIcon(String name) {
    switch (name.toLowerCase()) {
      case "paypal":
        return Image.asset("assets/images/paypal.png", height: 28);
      case "credit card":
        return const Icon(Icons.credit_card, color: Colors.blue);
      case "cash":
        return const Icon(Icons.money, color: Colors.green);
      default:
        return const Icon(Icons.payment);
    }
  }
}
