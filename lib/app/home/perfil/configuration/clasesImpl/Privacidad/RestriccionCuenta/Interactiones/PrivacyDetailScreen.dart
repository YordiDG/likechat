
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../../../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';

class PrivacyDetailScreen extends StatefulWidget {
  final String title;
  final List<String> options;
  final IconData icon;

  const PrivacyDetailScreen({
    Key? key,
    required this.title,
    required this.options,
    required this.icon,
  }) : super(key: key);

  @override
  State<PrivacyDetailScreen> createState() => _PrivacyDetailScreenState();
}

class _PrivacyDetailScreenState extends State<PrivacyDetailScreen>
    with SingleTickerProviderStateMixin {
  int _selectedOption = 0;
  late AnimationController _controller;
  late List<Animation<double>> _scaleAnimations;
  late Animation<double> _fadeAnimation;

  final List<List<Color>> optionGradients = [
    [Color(0xFF9B30FF), Color(0xFF00BFFF)],
    [Color(0xFF00BFFF), Color(0xFF00FFFF)],
    [Color(0xFF00FFFF), Color(0xFF9B30FF)],
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Inicializar fadeAnimation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    // Inicializar scaleAnimations para cada opción
    _scaleAnimations = List.generate(
      widget.options.length,
          (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.2,
          (index * 0.2) + 0.6,
          curve: Curves.easeOutBack,
        ),
      )),
    );

    // Iniciar la animación
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildOption(String option, int index) {
    final isSelected = _selectedOption == index;
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final fontSize = fontSizeProvider.fontSize;

    // Definir colores constantes
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[50];
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return AnimatedBuilder(
      animation: _scaleAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimations[index].value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedOption = index);
                HapticFeedback.lightImpact();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                constraints: const BoxConstraints(
                  minHeight: 50, // Altura mínima consistente
                  maxHeight: 50, // Altura máxima consistente
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                    colors: optionGradients[index % optionGradients.length],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                      : null,
                  color: isSelected ? null : backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: !isSelected
                      ? Border.all(
                    color: isDarkMode
                        ? Colors.grey[800]!
                        : Colors.grey[300]!,
                    width: 0.5,
                  )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? optionGradients[index % optionGradients.length][0]
                          .withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: isSelected ? 8 : 4,
                      offset: Offset(0, isSelected ? 4 : 2),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : textColor,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.black.withOpacity(0.2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final fontSize = fontSizeProvider.fontSize; // Asegúrate de que esta propiedad exista.

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: fontSize + 2
          ),
          overflow: TextOverflow.ellipsis,
        ),
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDarkMode ? Colors.white : Colors.black87,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ScaleTransition(
                  scale: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF9B30FF), Color(0xFF00BFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF9B30FF).withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    '¿Quién puede ${widget.title.toLowerCase()}?',
                    style: TextStyle(
                      fontSize: fontSize + 1,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: widget.options.length,
              itemBuilder: (context, index) => _buildOption(
                widget.options[index],
                index,
              ),
            ),
          ),
        ],
      ),
    );
  }
}