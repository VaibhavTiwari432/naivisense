import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/state_widgets/loading_widget.dart';
import '../providers/auth_provider.dart';
import '../../../shared/models/api/auth_requests.dart';
import '../../../core/constants/app_constants.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Welcome to NaiviSense')),
      body: auth.isLoading
          ? const LoadingWidget(message: 'Signing in...')
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Select your role to continue',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    const Text('I am a...',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleCard(
                            role: UserRole.therapist,
                            icon: Icons.medical_services_rounded,
                            color: AppColors.primaryBlue,
                            tint: AppColors.blueTint,
                            selected: auth.selectedRole == UserRole.therapist,
                            onTap: () => ref
                                .read(authProvider.notifier)
                                .selectRole(UserRole.therapist),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RoleCard(
                            role: UserRole.parent,
                            icon: Icons.child_care_rounded,
                            color: AppColors.mintGreen,
                            tint: AppColors.mintTint,
                            selected: auth.selectedRole == UserRole.parent,
                            onTap: () => ref
                                .read(authProvider.notifier)
                                .selectRole(UserRole.parent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _RoleCard(
                      role: UserRole.admin,
                      icon: Icons.shield_moon_rounded,
                      color: AppColors.adminPurple,
                      tint: const Color(0xFFEFEAFE),
                      selected: auth.selectedRole == UserRole.admin,
                      fullWidth: true,
                      onTap: () => ref
                          .read(authProvider.notifier)
                          .selectRole(UserRole.admin),
                    ),
                    const SizedBox(height: 28),
                    if (auth.error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.softCoral.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  AppColors.softCoral.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.softCoral, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.error!,
                                style: const TextStyle(
                                    color: AppColors.softCoral, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _AuthForm(selectedRole: auth.selectedRole),
                  ],
                ),
              ),
            ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final IconData icon;
  final Color color;
  final Color tint;
  final bool selected;
  final bool fullWidth;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.color,
    required this.tint,
    required this.selected,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? tint : AppColors.cardSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : AppColors.borderLight,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: fullWidth
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                role.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? color : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthForm extends ConsumerStatefulWidget {
  final UserRole? selectedRole;
  const _AuthForm({required this.selectedRole});

  @override
  ConsumerState<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<_AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final bool _isRegister = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role first')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authProvider.notifier);
    if (_isRegister) {
      notifier.register(
        RegisterRequest(
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          password: _passwordCtrl.text,
          role: widget.selectedRole!.name,
        ),
      );
    } else {
      notifier.login(_phoneCtrl.text.trim(), _passwordCtrl.text);
    }
    // GoRouter redirect handles navigation after auth state updates.
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isRegister) ...[
            _Label('Full Name'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Dr. Anita Sharma'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),
          ],
          _Label('Mobile Number'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '9876543210'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Phone is required';
              if (v.trim().length < 10) return 'Enter a valid phone number';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _Label('Password'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: _isRegister ? 'Min 8 characters' : 'Your password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (_isRegister && v.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Login',
            onPressed: _submit,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.verified_user_rounded,
                  size: 16, color: AppColors.mintGreen),
              SizedBox(width: 6),
              Text('Your data is safe & secure',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600),
      );
}
