import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('تماس با جابینجا', style: TextStyle(fontFamily: 'Vazir', fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF212529),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfo(),
            const SizedBox(height: 16),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(Icons.headset_mic, color: Color(0xFF4A90D9), size: 28),
            SizedBox(width: 8),
            Text('ارتباط با ما', style: TextStyle(fontFamily: 'Vazir', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.email_outlined, 'ایمیل: support@jobinja.ir'),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.language_outlined, 'وبلاگ: blog.jobinja.ir'),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.camera_alt_outlined, 'اینستاگرام: @myjobinja'),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.chat_outlined, 'تلگرام: @jobinja_ir'),
      ]),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4A90D9)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF495057))),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Text('ارسال پیام', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameCtrl,
            textDirection: TextDirection.rtl,
            decoration: _input('نام و نام خانوادگی', Icons.person_outline),
            validator: (v) => (v == null || v.isEmpty) ? 'نام را وارد کنید' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            textDirection: TextDirection.rtl,
            decoration: _input('ایمیل', Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || v.isEmpty) ? 'ایمیل را وارد کنید' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _messageCtrl,
            textDirection: TextDirection.rtl,
            maxLines: 5,
            decoration: _input('پیام شما', Icons.message_outlined),
            validator: (v) => (v == null || v.isEmpty) ? 'پیام را وارد کنید' : null,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'ارسال پیام',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('پیام شما با موفقیت ارسال شد', style: TextStyle(fontFamily: 'Vazir')),
                  backgroundColor: const Color(0xFF27AE60),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              }
            },
          ),
        ]),
      ),
    );
  }

  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Vazir', color: Color(0xFF6C757D)),
      prefixIcon: Icon(icon, color: const Color(0xFFADB5BD)),
      filled: true, fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 2)),
    );
  }
}
