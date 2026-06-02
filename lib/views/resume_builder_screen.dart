import 'package:flutter/material.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _educations = [];
  final List<Map<String, dynamic>> _experiences = [];
  final List<String> _skills = [];

  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('رزومه‌ساز', style: TextStyle(fontFamily: 'Vazir', fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF212529),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProgressBar(),
            Form(
              key: _formKey,
              child: _buildCurrentStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('تکمیل رزومه', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
          const SizedBox(height: 16),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              _buildStepDot(0, 'اطلاعات', Icons.person_outline),
              _buildStepLine(0),
              _buildStepDot(1, 'تحصیلات', Icons.school_outlined),
              _buildStepLine(1),
              _buildStepDot(2, 'سوابق', Icons.work_outline),
              _buildStepLine(2),
              _buildStepDot(3, 'مهارت‌ها', Icons.psychology_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int index, String label, IconData icon) {
    final isActive = index <= _currentStep;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4A90D9) : const Color(0xFFE9ECEF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: isActive ? Colors.white : const Color(0xFFADB5BD)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontFamily: 'Vazir', fontSize: 10, color: isActive ? const Color(0xFF4A90D9) : const Color(0xFFADB5BD))),
      ],
    );
  }

  Widget _buildStepLine(int index) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: index < _currentStep ? const Color(0xFF4A90D9) : const Color(0xFFE9ECEF),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildPersonalInfo();
      case 1: return _buildEducation();
      case 2: return _buildExperience();
      case 3: return _buildSkills();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('اطلاعات شخصی', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
        const SizedBox(height: 20),
        TextFormField(
          controller: _nameController,
          textDirection: TextDirection.rtl,
          decoration: _inputDecoration('نام و نام خانوادگی', Icons.person_outline),
          validator: (v) => (v == null || v.isEmpty) ? 'نام را وارد کنید' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          textDirection: TextDirection.rtl,
          decoration: _inputDecoration('ایمیل', Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          validator: (v) => (v == null || v.isEmpty) ? 'ایمیل را وارد کنید' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          textDirection: TextDirection.rtl,
          decoration: _inputDecoration('شماره تماس', Icons.phone_outlined),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bioController,
          textDirection: TextDirection.rtl,
          maxLines: 4,
          decoration: _inputDecoration('درباره من (خلاصه)', Icons.info_outline),
        ),
        const SizedBox(height: 24),
        _buildNextButton(),
      ]),
    );
  }

  Widget _buildEducation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('تحصیلات', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
          TextButton.icon(
            onPressed: _addEducation,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('افزودن', style: TextStyle(fontFamily: 'Vazir', fontSize: 13)),
          ),
        ]),
        const SizedBox(height: 12),
        if (_educations.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('تحصیلی ثبت نشده', style: TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFFADB5BD))),
          )),
        ..._educations.asMap().entries.map((e) => _buildEducationCard(e.key, e.value)),
        const SizedBox(height: 16),
        Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(onPressed: () => setState(() => _currentStep--), child: const Text('مرحله قبل', style: TextStyle(fontFamily: 'Vazir'))),
          ElevatedButton(onPressed: () => setState(() => _currentStep++), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90D9), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('مرحله بعد', style: TextStyle(fontFamily: 'Vazir'))),
        ]),
      ]),
    );
  }

  void _addEducation() {
    showDialog(
      context: context,
      builder: (ctx) {
        final degreeCtrl = TextEditingController();
        final fieldCtrl = TextEditingController();
        final uniCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('افزودن تحصیلات', style: TextStyle(fontFamily: 'Vazir')),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: degreeCtrl, textDirection: TextDirection.rtl, decoration: _inputDecoration('مقطع تحصیلی', null)),
            const SizedBox(height: 12),
            TextField(controller: fieldCtrl, textDirection: TextDirection.rtl, decoration: _inputDecoration('رشته تحصیلی', null)),
            const SizedBox(height: 12),
            TextField(controller: uniCtrl, textDirection: TextDirection.rtl, decoration: _inputDecoration('دانشگاه', null)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazir'))),
            ElevatedButton(onPressed: () {
              setState(() => _educations.add({'degree': degreeCtrl.text, 'field': fieldCtrl.text, 'university': uniCtrl.text}));
              Navigator.pop(ctx);
            }, child: const Text('ذخیره', style: TextStyle(fontFamily: 'Vazir'))),
          ],
        );
      },
    );
  }

  Widget _buildEducationCard(int index, Map<String, dynamic> edu) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('${edu['degree']} - ${edu['field']}', style: const TextStyle(fontFamily: 'Vazir', fontSize: 14), textAlign: TextAlign.right),
        subtitle: Text(edu['university'] ?? '', style: const TextStyle(fontFamily: 'Vazir', fontSize: 12), textAlign: TextAlign.right),
        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFE74C3C)), onPressed: () => setState(() => _educations.removeAt(index))),
      ),
    );
  }

  Widget _buildExperience() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('سوابق شغلی', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
          TextButton.icon(
            onPressed: _addExperience,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('افزودن', style: TextStyle(fontFamily: 'Vazir', fontSize: 13)),
          ),
        ]),
        const SizedBox(height: 12),
        if (_experiences.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('سابقه شغلی ثبت نشده', style: TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFFADB5BD))),
          )),
        ..._experiences.asMap().entries.map((e) => _buildExperienceCard(e.key, e.value)),
        const SizedBox(height: 16),
        Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(onPressed: () => setState(() => _currentStep--), child: const Text('مرحله قبل', style: TextStyle(fontFamily: 'Vazir'))),
          ElevatedButton(onPressed: () => setState(() => _currentStep++), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90D9), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('مرحله بعد', style: TextStyle(fontFamily: 'Vazir'))),
        ]),
      ]),
    );
  }

  void _addExperience() {
    showDialog(
      context: context,
      builder: (ctx) {
        final companyCtrl = TextEditingController();
        final positionCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('افزودن سابقه شغلی', style: TextStyle(fontFamily: 'Vazir')),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: companyCtrl, textDirection: TextDirection.rtl, decoration: _inputDecoration('نام شرکت', null)),
            const SizedBox(height: 12),
            TextField(controller: positionCtrl, textDirection: TextDirection.rtl, decoration: _inputDecoration('سمت', null)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazir'))),
            ElevatedButton(onPressed: () {
              setState(() => _experiences.add({'company': companyCtrl.text, 'position': positionCtrl.text}));
              Navigator.pop(ctx);
            }, child: const Text('ذخیره', style: TextStyle(fontFamily: 'Vazir'))),
          ],
        );
      },
    );
  }

  Widget _buildExperienceCard(int index, Map<String, dynamic> exp) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(exp['position'] ?? '', style: const TextStyle(fontFamily: 'Vazir', fontSize: 14), textAlign: TextAlign.right),
        subtitle: Text(exp['company'] ?? '', style: const TextStyle(fontFamily: 'Vazir', fontSize: 12), textAlign: TextAlign.right),
        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFE74C3C)), onPressed: () => setState(() => _experiences.removeAt(index))),
      ),
    );
  }

  Widget _buildSkills() {
    final skillCtrl = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('مهارت‌ها', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: skillCtrl,
                textDirection: TextDirection.rtl,
                decoration: _inputDecoration('مهارت جدید', null),
                onSubmitted: (v) {
                  if (v.isNotEmpty) {
                    setState(() => _skills.add(v));
                    skillCtrl.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF4A90D9)),
              onPressed: () {
                if (skillCtrl.text.isNotEmpty) {
                  setState(() => _skills.add(skillCtrl.text));
                  skillCtrl.clear();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8, runSpacing: 8,
          textDirection: TextDirection.rtl,
          children: _skills.map((s) => Chip(
            label: Text(s, style: const TextStyle(fontFamily: 'Vazir', fontSize: 12)),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => setState(() => _skills.remove(s)),
            backgroundColor: const Color(0xFFE8F0FE),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          )).toList(),
        ),
        if (_skills.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('مهارتی ثبت نشده', style: TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFFADB5BD))),
          )),
        const SizedBox(height: 24),
        Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(onPressed: () => setState(() => _currentStep--), child: const Text('مرحله قبل', style: TextStyle(fontFamily: 'Vazir'))),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('رزومه با موفقیت ساخته شد', style: TextStyle(fontFamily: 'Vazir')),
                backgroundColor: const Color(0xFF27AE60),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('ذخیره رزومه', style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold)),
          ),
        ]),
      ]),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          setState(() => _currentStep++);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A90D9),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('مرحله بعد', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Vazir', color: Color(0xFF6C757D)),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFADB5BD)) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 2)),
    );
  }
}
