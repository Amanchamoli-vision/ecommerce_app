import 'package:clothes_ecommerce/pages/home.dart';
import 'package:clothes_ecommerce/pages/login.dart';
import 'package:clothes_ecommerce/services/database.dart';
import 'package:clothes_ecommerce/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with TickerProviderStateMixin {
  // Controllers — same as before
  TextEditingController nameController = TextEditingController();
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ── SAME LOGIC as original ──────────────────────────────────────────────────
  registration() async {
    if (nameController.text != "" &&
        emailController.text != "" &&
        passwordController.text != "") {
      try {
        setState(() => _isLoading = true);

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim());

        setState(() => _isLoading = false);

        String id = userCredential.user!.uid;

        Map<String, dynamic> userInfoMap = {
          "Name": nameController.text,
          "Email": emailController.text,
          "Id": id,
          "Wallet": "0",
        };

        await DatabaseMethods().addUserDetails(userInfoMap, id);
        await SharedPreferenceHelper().saveUserEmail(emailController.text);
        await SharedPreferenceHelper().saveUserName(nameController.text);
        await SharedPreferenceHelper().saveUserId(id);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Color(0xff6e5038),
            content: Text("Welcome! Account created successfully ✨",
                style: TextStyle(fontSize: 16.0))));

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const Home()));
      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);
        if (e.code == 'weak-password') {
          _showError("Password is too weak");
        } else if (e.code == 'email-already-in-use') {
          _showError("Account already exists");
        } else {
          _showError(e.message ?? "Authentication failed");
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showError("Something went wrong. Please try again.");
      }
    } else {
      _showError("Please fill all fields");
    }
  }

  _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent, content: Text(msg)));
  }
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xff1A0F0A), // Deep espresso background
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Decorative Background Elements ──────────────────────────────
          // Top-right large circle
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              height: 280,
              width: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xff6e5038).withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom-left circle
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xffD4A57A).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Thin decorative diagonal line
          Positioned(
            top: screenHeight * 0.28,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xff6e5038).withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main Content ────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.06),

                      // ── Brand Mark ──
                      Row(
                        children: [
                          Container(
                            height: 3,
                            width: 30,
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
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      // ── Headline ──
                      Text(
                        "Create\nAccount",
                        style: GoogleFonts.cormorantGaramond(
                          color: Colors.white,
                          fontSize: screenWidth > 400 ? 54 : 44,
                          fontWeight: FontWeight.w300,
                          height: 1.0,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Join us for an exclusive experience",
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.055),

                      // ── Name Field ──
                      _buildInputField(
                        controller: nameController,
                        label: "Full Name",
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 20),

                      // ── Email Field ──
                      _buildInputField(
                        controller: emailController,
                        label: "Email Address",
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      // ── Password Field ──
                      _buildInputField(
                        controller: passwordController,
                        label: "Password",
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        obscure: _obscurePassword,
                        onToggle: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),

                      SizedBox(height: screenHeight * 0.055),

                      // ── Sign Up Button ──
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xffD4A57A)),
                            )
                          : GestureDetector(
                              onTap: registration,
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xff8B6346),
                                      Color(0xff6e5038),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Create Account",
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

                      SizedBox(height: screenHeight * 0.03),

                      // ── OR Divider ──
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white10,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OR",
                              style: GoogleFonts.poppins(
                                color: Colors.white24,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white10,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // ── Login Link ──
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login())),
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account?  ",
                              style: GoogleFonts.poppins(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: "Log In",
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

                      SizedBox(height: screenHeight * 0.04),

                      // ── Decorative bottom text ──
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

                      SizedBox(height: screenHeight * 0.03),
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

  // ── Reusable Elegant Input Field ────────────────────────────────────────────
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
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscure : false,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.poppins(
            color: Colors.white30,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: const Color(0xffD4A57A), size: 20),
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