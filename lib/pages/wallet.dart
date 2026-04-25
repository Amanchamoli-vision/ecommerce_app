import 'dart:async';
import 'package:clothes_ecommerce/services/database.dart';
import 'package:clothes_ecommerce/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> with TickerProviderStateMixin {
  late Razorpay _razorpay;
  String? wallet, id;
  TextEditingController amountController = TextEditingController();
  late AnimationController _cardController;
  late Animation<double> _cardAnim;

  @override
  void initState() {
    super.initState();
    getontheload();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _cardController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _cardAnim =
        CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack);
    _cardController.forward();
  }

  getontheload() async {
    id = await SharedPreferenceHelper().getUserId();
    wallet = await SharedPreferenceHelper().getUserWallet();
    wallet ??= "0";
    setState(() {});
  }

  @override
  void dispose() {
    _razorpay.clear();
    _cardController.dispose();
    super.dispose();
  }

  void openCheckout(String amount) {
    var options = {
      'key': 'YOUR_RAZORPAY_KEY_HERE',
      'amount': int.parse(amount) * 100,
      'name': 'Style•Co',
      'description': 'Add Money to Wallet',
      'prefill': {'contact': '9876543210', 'email': 'user@gmail.com'},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    int updatedAmount =
        int.parse(wallet!) + int.parse(amountController.text);
    await SharedPreferenceHelper().saveUserWallet(updatedAmount.toString());
    await DatabaseMethods().updateWallet(id!, updatedAmount.toString());

    String formattedDate =
        DateFormat('dd, MMM yyyy').format(DateTime.now());
    Map<String, dynamic> transactionMap = {
      "Amount": amountController.text,
      "Status": "CREDITED",
      "Date": formattedDate,
    };
    await DatabaseMethods().addTransactions(transactionMap, id!);

    amountController.clear();
    await getontheload();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xff2ecc71),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text("💰 Money Added Successfully!",
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Error: ${response.message}")));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      body: wallet == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff6e5038)))
          : CustomScrollView(
              slivers: [
                // ── Header ──
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff6e5038),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(24, 16, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text("My Wallet",
                                    style: GoogleFonts.playfairDisplay(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: Colors.white,
                                      size: 22),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // ── Balance Card ──
                            ScaleTransition(
                              scale: _cardAnim,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(26),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xff2D1F14),
                                      Color(0xff4A3020),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Available Balance",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white54,
                                              fontSize: 13,
                                            )),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffD4A57A)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: const Color(
                                                    0xffD4A57A)
                                                    .withOpacity(0.4)),
                                          ),
                                          child: Text("ACTIVE",
                                              style: GoogleFonts.poppins(
                                                color:
                                                    const Color(0xffD4A57A),
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.5,
                                              )),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "\$${wallet!}",
                                      style: GoogleFonts.playfairDisplay(
                                        color: Colors.white,
                                        fontSize: 46,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: List.generate(
                                        4,
                                        (i) => Padding(
                                          padding: const EdgeInsets.only(
                                              right: 6),
                                          child: Row(
                                            children: List.generate(
                                                4,
                                                (_) => Container(
                                                      width: 5,
                                                      height: 5,
                                                      margin:
                                                          const EdgeInsets
                                                              .only(right: 3),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.white30,
                                                        shape:
                                                            BoxShape.circle,
                                                      ),
                                                    )),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Add Money Section ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Add Money",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff2D1F14),
                            )),
                        const SizedBox(height: 6),
                        Text("Select or enter amount below",
                            style: GoogleFonts.poppins(
                                color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 24),

                        // ── Quick Amount Chips ──
                        Row(
                          children: ["100", "200", "300", "500"]
                              .map((val) => _amountChip(val))
                              .toList(),
                        ),
                        const SizedBox(height: 24),

                        // ── Custom Amount Input ──
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff2D1F14),
                            ),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: "Enter custom amount",
                              hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey[400], fontSize: 14),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 16, right: 8),
                                child: Text("\$",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff6e5038),
                                    )),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                  minWidth: 0, minHeight: 0),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Add Money Button ──
                        GestureDetector(
                          onTap: () {
                            if (amountController.text.isNotEmpty) {
                              openCheckout(amountController.text);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  backgroundColor:
                                      const Color(0xff6e5038),
                                  content: const Text(
                                      "Please enter or select amount"),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff8B6346),
                                  Color(0xff6e5038),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff6e5038)
                                      .withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle_outline_rounded,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Text("Add to Wallet",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _amountChip(String val) {
    final bool isSelected = amountController.text == val;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          amountController.text = val;
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xff6e5038) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xff6e5038).withOpacity(0.35)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text("\$$val",
                  style: GoogleFonts.poppins(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xff2D1F14),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}