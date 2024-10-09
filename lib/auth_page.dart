import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'loginpage.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RegisterPageContent(),
    );
  }
}

class RegisterPageContent extends StatefulWidget {
  @override
  _RegisterPageContentState createState() => _RegisterPageContentState();
}

class _RegisterPageContentState extends State<RegisterPageContent> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
   late AuthProvider authProvider;



  @override
  Widget build(BuildContext context) {
    final authProvider1 = Provider.of<AuthProvider>(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: authProvider. // Check loading state here
              ? const Center(child: CircularProgressIndicator())
              : Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    final regex = RegExp(r'^\+92[0-9]{10}$|^03[0-9]{9}$');
                    if (!regex.hasMatch(value)) {
                      return 'Please enter a valid Pakistani phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _cnicController,
                  decoration: const InputDecoration(
                    labelText: 'CNIC',
                    border: OutlineInputBorder(),
                  ),
                  // Uncomment if using a custom input formatter
                  // inputFormatters: [CnicFormatter()],
                  validator: (value) {
                    final RegExp cnicRegExp = RegExp(r'^\d{5}-\d{7}-\d{1}$');

                    if (value == null || value.isEmpty) {
                      return 'Please enter your CNIC number';
                    }

                    if (!cnicRegExp.hasMatch(value)) {
                      return 'Please enter a valid CNIC number in the format 12345-6789012-3';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        // Call the registerUser method
                        authProvider.registerUser(
                          name: _nameController.text.trim(),
                          phone: _phoneController.text.trim(),
                          email: _emailController.text.trim(),
                          cnic: _cnicController.text.trim(),
                          password: _passwordController.text.trim(),
                          context: context, // Pass context for navigation
                        ).then((_) {
                          // Handle successful registration
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        }).catchError((error) {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.green],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text("Go to login Page if you already have an account"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}




class CnicFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Remove all non-numeric characters from the input
    final numericValue = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit the input to 13 digits
    final limitedValue = numericValue.substring(0, numericValue.length > 13 ? 13 : numericValue.length);

    // Insert dashes in the correct positions
    String formattedValue = '';
    if (limitedValue.length > 5) {
      formattedValue = '${limitedValue.substring(0, 5)}-${limitedValue.substring(5)}';
    } else {
      formattedValue = limitedValue;
    }
    if (formattedValue.length > 13) {
      formattedValue = '${formattedValue.substring(0, 13)}-${formattedValue.substring(13)}';
    }

    // Return the formatted value
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
