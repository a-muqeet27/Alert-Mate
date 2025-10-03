import 'package:flutter/material.dart';
import 'models/user.dart';
import 'package:country_picker/country_picker.dart';
import 'services/auth_service.dart';
import 'dashboards/driver_dashboard.dart';
import 'dashboards/passenger_dashboard.dart';
import 'dashboards/owner_dashboard.dart';
import 'dashboards/admin_dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isSignIn = false; // Start with Sign Up by default
  bool _obscurePassword = true;
  int _selectedDashboard = 0; // 0: Driver, 1: Passenger, 2: Owner, 3: Admin
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  // Country code state for phone field
  String _selectedDialCode = '+1';
  String _selectedCountryIso = 'US';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _getSelectedRole() {
    switch (_selectedDashboard) {
      case 0:
        return 'driver';
      case 1:
        return 'passenger';
      case 2:
        return 'owner';
      case 3:
        return 'admin';
      default:
        return 'driver';
    }
  }

  String _getSelectedRoleLabel() {
    switch (_selectedDashboard) {
      case 0:
        return 'Driver';
      case 1:
        return 'Passenger';
      case 2:
        return 'Owner';
      case 3:
        return 'Admin';
      default:
        return 'Driver';
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      isSignIn = !isSignIn;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _onRoleSelected(int index) {
    if (_selectedDashboard != index) {
      setState(() {
        _selectedDashboard = index;
        // Clear form when switching roles
        _firstNameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _passwordController.clear();
        // Start with Sign Up for new role selection
        isSignIn = false;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _handleAuth() {
    if (_formKey.currentState!.validate()) {
      final selectedRole = _getSelectedRole();
      final email = _emailController.text.trim();

      if (isSignIn) {
        // Sign In Logic
        User? user = AuthService.signIn(
          email: email,
          password: _passwordController.text,
          role: selectedRole,
        );

        if (user != null) {
          _navigateToDashboard(user);
        } else {
          _showErrorDialog(
              'Invalid credentials or not registered for ${_getSelectedRoleLabel()} role');
        }
      } else {
        // Sign Up Logic
        bool success = AuthService.signUp(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: email,
          phone: '$_selectedDialCode ${_phoneController.text.trim()}',
          password: _passwordController.text,
          role: selectedRole,
        );

        if (success) {
          _showSuccessDialog(
              'Account created successfully for ${_getSelectedRoleLabel()} role! Please sign in.');
        } else {
          _showErrorDialog(
              'Email already registered for ${_getSelectedRoleLabel()} role');
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isSignIn = true;
                _firstNameController.clear();
                _lastNameController.clear();
                _phoneController.clear();
                _passwordController.clear();
                // Keep email for convenience
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToDashboard(User user) {
    Widget dashboardScreen;

    switch (_selectedDashboard) {
      case 0:
        dashboardScreen = DriverDashboard(user: user);
        break;
      case 1:
        dashboardScreen = PassengerDashboard(user: user);
        break;
      case 2:
        dashboardScreen = OwnerDashboard(user: user);
        break;
      case 3:
        dashboardScreen = AdminDashboard(user: user);
        break;
      default:
        dashboardScreen = DriverDashboard(user: user);
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        dashboardScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Header
              const Text(
                'ALERT MATE',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Drowsiness Detection',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7F8C8D),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 40),
              // Dashboard Selection Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNavIcon(Icons.directions_car, 0, 'Driver'),
                  const SizedBox(width: 16),
                  _buildNavIcon(Icons.people, 1, 'Passenger'),
                  const SizedBox(width: 16),
                  _buildNavIcon(Icons.admin_panel_settings, 2, 'Owner'),
                  const SizedBox(width: 16),
                  _buildNavIcon(Icons.settings, 3, 'Admin'),
                ],
              ),
              const SizedBox(height: 20),
              // Role Selection Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Selected Role: ${_getSelectedRoleLabel()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3498DB),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              // Auth Card
              FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Container(
                    width: 500,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSignIn ? 'Welcome Back' : 'Create Account',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSignIn
                              ? 'Sign in to access your ${_getSelectedRoleLabel()} dashboard'
                              : 'Register as ${_getSelectedRoleLabel()} to get started',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Toggle Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildToggleButton('Sign In', isSignIn, () {
                                if (!isSignIn) _toggleAuthMode();
                              }),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildToggleButton('Sign Up', !isSignIn,
                                      () {
                                    if (isSignIn) _toggleAuthMode();
                                  }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Form Fields
                        if (!isSignIn) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'First Name',
                                  'John',
                                  _firstNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  'Last Name',
                                  'Doe',
                                  _lastNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                        _buildTextField(
                          'Email',
                          'Email (e.g., john@example.com)',
                          _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        if (!isSignIn) ...[
                          const SizedBox(height: 20),
                          _buildPhoneField(),
                        ],
                        const SizedBox(height: 20),
                        _buildPasswordField(),
                        const SizedBox(height: 30),
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _handleAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3498DB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isSignIn
                                  ? 'Sign In as ${_getSelectedRoleLabel()}'
                                  : 'Sign Up as ${_getSelectedRoleLabel()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, String label) {
    bool isActive = _selectedDashboard == index;

    return GestureDetector(
      onTap: () => _onRoleSelected(index),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFE8F4FD) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF3498DB)
                    : const Color(0xFFE0E0E0),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? const Color(0xFF3498DB)
                  : const Color(0xFF95A5A6),
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive
                  ? const Color(0xFF3498DB)
                  : const Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8F4FD) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? const Color(0xFF3498DB)
                  : const Color(0xFF7F8C8D),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      String hint,
      TextEditingController controller, {
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDC3C7)),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            InkWell(
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: true,
                  onSelect: (Country country) {
                    setState(() {
                      _selectedDialCode = '+${country.phoneCode}';
                      _selectedCountryIso = country.countryCode;
                    });
                  },
                );
              },
              child: Container(
                width: 140,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_selectedDialCode ($_selectedCountryIso)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF7F8C8D)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                validator: (value) {
                  if (!isSignIn && (value == null || value.isEmpty)) {
                    return 'Phone is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Phone (e.g., 555 123 4567)',
                  hintStyle: const TextStyle(color: Color(0xFFBDC3C7)),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                    const BorderSide(color: Color(0xFF3498DB), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (!isSignIn && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Create a password',
            hintStyle: const TextStyle(color: Color(0xFFBDC3C7)),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF7F8C8D),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}