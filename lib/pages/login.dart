import 'package:clothes_ecommerce/pages/bottom_nav.dart';
import 'package:clothes_ecommerce/pages/signup.dart';
import 'package:clothes_ecommerce/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    emailController.text = "amanchamolidehradun@gmail.com";
    passwordController.text = "123456";
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  userLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showError("Please fill all fields");
      return;
    }
    try {
      setState(() => _isLoading = true);

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());

      String id = userCredential.user!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        await SharedPreferenceHelper().saveUserEmail(data["Email"] ?? "");
        await SharedPreferenceHelper().saveUserName(data["Name"] ?? "");
        await SharedPreferenceHelper().saveUserId(id);
        await SharedPreferenceHelper().saveUserWallet(data["Wallet"] ?? "0");
      }

      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xff6e5038),
          content: Text("Welcome back! 👋",
              style: TextStyle(fontSize: 16.0))));

      // ✅ BottomNav — Home + NavBar saath milega
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const BottomNav()));

    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (e.code == 'user-not-found') {
        _showError("No account found with this email");
      } else if (e.code == 'wrong-password') {
        _showError("Incorrect password");
      } else {
        _showError(e.message ?? "Login failed");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Something went wrong. Please try again.");
    }
  }

  _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.redAccent, content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xff1A0F0A),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Background Decorations ──
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xff6e5038).withOpacity(0.45),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              height: 240,
              width: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xffD4A57A).withOpacity(0.2),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // ── Image Area ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.38,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/login.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      const Color(0xff1A0F0A),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Main Scrollable Content ──
          SafeArea(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.26),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08, vertical: 36),
                        decoration: const BoxDecoration(
                          color: Color(0xff1A0F0A),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(36),
                            topRight: Radius.circular(36),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Brand
                            Row(
                              children: [
                                Container(
                                  height: 3,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffD4A57A),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "STYLE•CO",
                                  style: GoogleFonts.cormorantGaramond(
                                    color: const Color(0xffD4A57A),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Text(
                              "Welcome\nBack",
                              style: GoogleFonts.cormorantGaramond(
                                color: Colors.white,
                                fontSize: screenWidth > 400 ? 52 : 42,
                                fontWeight: FontWeight.w300,
                                height: 1.0,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Sign in to continue your style journey",
                              style: GoogleFonts.poppins(
                                color: Colors.white38,
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                              ),
                            ),

                            const SizedBox(height: 36),

                            _buildInputField(
                              controller: emailController,
                              label: "Email Address",
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),

                            _buildInputField(
                              controller: passwordController,
                              label: "Password",
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              obscure: _obscurePassword,
                              onToggle: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),

                            const SizedBox(height: 12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Forgot Password?",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xffD4A57A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 36),

                            _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                        color: Color(0xffD4A57A)),
                                  )
                                : GestureDetector(
                                    onTap: userLogin,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xff8B6346),
                                            Color(0xff6e5038),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xff6e5038)
                                                .withOpacity(0.5),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Sign In",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 20),
                                        ],
                                      ),
                                    ),
                                  ),

                            const SizedBox(height: 30),

                            Row(
                              children: [
                                Expanded(
                                    child: Container(
                                        height: 1, color: Colors.white10)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text("OR",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white24,
                                          fontSize: 12)),
                                ),
                                Expanded(
                                    child: Container(
                                        height: 1, color: Colors.white10)),
                              ],
                            ),

                            const SizedBox(height: 28),

                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Signup())),
                                child: RichText(
                                  text: TextSpan(
                                    text: "New here?  ",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white38, fontSize: 14),
                                    children: [
                                      TextSpan(
                                        text: "Create Account",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xffD4A57A),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            Center(
                              child: Text(
                                "✦  Fashion. Style. You.  ✦",
                                style: GoogleFonts.cormorantGaramond(
                                  color: Colors.white12,
                                  fontSize: 13,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscure : false,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          hintText: label,
          hintStyle:
              GoogleFonts.poppins(color: Colors.white30, fontSize: 14),
          prefixIcon:
              Icon(icon, color: const Color(0xffD4A57A), size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white24,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        cursorColor: const Color(0xffD4A57A),
      ),
    );
  }
}