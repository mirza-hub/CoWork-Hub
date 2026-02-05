import 'package:another_flushbar/flushbar.dart';
import 'package:coworkhub_mobile/providers/user_provider.dart';
import 'package:coworkhub_mobile/screens/password_reset_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;

  const NewPasswordScreen({super.key, required this.email});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await UserProvider().resetPassword(
        widget.email,
        _passwordCtrl.text,
        _confirmPasswordCtrl.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PasswordResetSuccessScreen(),
          ),
        );
      }
    } catch (e) {
      Flushbar(
        message: e.toString().replaceFirst("Exception: ", ""),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nova lozinka"), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Postavite novu lozinku",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Unesite novu lozinku i potvrdu.",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Nova lozinka",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Lozinka je obavezna";
                    }
                    if (v.length < 8) {
                      return "Lozinka mora biti najmanje 8 karaktera";
                    }
                    if (v.length > 64) return 'Lozinka je preduga';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordCtrl,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: "Potvrdi lozinku",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Potvrda lozinke je obavezna";
                    }
                    if (v != _passwordCtrl.text) {
                      return "Lozinke se ne poklapaju";
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Prosljeđivanje",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Nazad",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }
}
