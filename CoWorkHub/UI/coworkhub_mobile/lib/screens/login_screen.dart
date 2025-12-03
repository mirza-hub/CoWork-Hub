import 'package:another_flushbar/flushbar.dart';
import 'package:coworkhub_mobile/models/user.dart';
import 'package:coworkhub_mobile/providers/auth_provider.dart';
import 'package:coworkhub_mobile/providers/user_provider.dart';
import 'package:coworkhub_mobile/screens/register_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
      User user = await provider.login(
        AuthProvider.username!,
        AuthProvider.password!,
      );

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

      // if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/home"); // Home layout screen
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
                  validator: (v) => v == null || v.isEmpty
                      ? "Korisničko ime je obavezno"
                      : null,
                ),

                const SizedBox(height: 20),

                // Password
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
                  validator: (v) =>
                      v == null || v.isEmpty ? "Lozinka je obavezna" : null,
                ),

                const SizedBox(height: 30),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1079CF),
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

                // Forgot password
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

                // Register
                RichText(
                  text: TextSpan(
                    text: 'Nemate račun? ', // običan tekst
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    children: [
                      TextSpan(
                        text: 'Registrirajte se', // samo ovaj dio podvučen
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // navigacija na RegisterScreen
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

                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
