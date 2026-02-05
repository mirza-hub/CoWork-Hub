import 'package:another_flushbar/flushbar.dart';
import 'package:coworkhub_mobile/layout/layout_screen.dart';
import 'package:coworkhub_mobile/models/user.dart';
import 'package:coworkhub_mobile/providers/auth_provider.dart';
import 'package:coworkhub_mobile/providers/user_provider.dart';
import 'package:coworkhub_mobile/screens/register_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  final Route? returnRoute;

  const LoginScreen({super.key, this.returnRoute});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscure = true;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      AuthProvider.username = _usernameCtrl.text;
      AuthProvider.password = _passwordCtrl.text;

      var provider = UserProvider();
      User user = await provider.login(_usernameCtrl.text, _passwordCtrl.text);

      if (user.isDeleted == true) {
        throw Exception("Vaš korisnički račun ne postoji.");
      }

      if (user.isActive == false) {
        throw Exception("Vaš korisnički račun je deaktiviran.");
      }

      bool isUser = user.userRoles.any((role) => role.role.roleName == "User");
      if (!isUser) {
        throw Exception(
          "Nemate prava za pristup ovoj aplikaciji. Samo korisnici mogu pristupiti.",
        );
      }

      AuthProvider.userId = user.usersId;
      AuthProvider.userRoles = user.userRoles;
      AuthProvider.isSignedIn = true;

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.returnRoute != null) {
            Navigator.pushReplacement(context, widget.returnRoute!);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LayoutScreen(user: user)),
            );
          }
        });
      }
    } catch (e) {
      Flushbar(
        message: "Pogrešno korisničko ime ili lozinka",
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Dobro došli",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Prijavite se za nastavak.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),

                const SizedBox(height: 35),

                // Username
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Korisničko ime",
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(15)],
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Korisničko ime je obavezno";
                    }

                    if (v.length > 15) {
                      return "Korisničko ime ne smije imati više od 15 karaktera";
                    }

                    final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
                    if (!regex.hasMatch(v)) {
                      return "Dozvoljena su samo slova, brojevi, _ i -";
                    }

                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 20),

                // Šifra
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: "Lozinka",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  validator: (v) =>
                      v == null || v.isEmpty ? "Lozinka je obavezna" : null,
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: 30),

                // Login dugme
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Prijavite se",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                // Zaboravljena šifra
                GestureDetector(
                  onTap: () {
                    // TODO: dodaj forgot password ekran
                  },
                  child: const Text(
                    "Zaboravili ste šifru?",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Registracija
                RichText(
                  text: TextSpan(
                    text: 'Nemate račun? ',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    children: [
                      TextSpan(
                        text: 'Registrirajte se',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LayoutScreen(user: null),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      "Nastavi kao gost",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
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
}
