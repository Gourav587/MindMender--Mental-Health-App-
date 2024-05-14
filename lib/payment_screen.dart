import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Future<UpiResponse>? _transaction;
  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;
  bool _paymentSuccess = false;

  TextStyle header = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
  );

  @override
  void initState() {
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      print(e);
      apps = [];
    });
    super.initState();
  }

  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: 'gouravmahajan587@okaxis', // replace with actual UPI ID
      receiverName: 'Gourav Mahajan',
      transactionRefId: 'TestingUpiIndiaPlugin',
      amount: 10.00,
    );
  }

  Widget displayUpiApps() {
    if (apps == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (apps!.isEmpty) {
      return Center(
        child: Text(
          "No apps found to handle the transaction.",
          style: header,
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            children: apps!.map<Widget>((UpiApp app) {
              return UpiAppListItem(
                app: app,
                onTap: () async {
                  try {
                    _transaction = initiateTransaction(app);
                    UpiResponse response = await _transaction!;
                    setState(() {
                      _paymentSuccess = response.status == UpiTransactionStatus.success;
                    });
                  } catch (e) {
                    print('Error initiating transaction: $e');
                    setState(() {
                      _paymentSuccess = false;
                    });
                  }
                },
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('UPI Payment',style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_paymentSuccess)
            Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            )
          else
            displayUpiApps(),
        ],
      ),
    );
  }
}

class UpiTransactionStatus {
  static const success = 'success';
  static const failure = 'failure';
  static const submitted = 'submitted';
}

class UpiAppListItem extends StatelessWidget {
  final UpiApp app;
  final VoidCallback onTap;

  UpiAppListItem({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.memory(
              app.icon,
              height: 60,
              width: 60,
            ),
            Text(app.name),
          ],
        ),
      ),
    );
  }
}
