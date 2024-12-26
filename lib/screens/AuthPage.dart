import 'package:flutter/material.dart';
import 'package:fluuter/connections/firebase.dart';
import 'package:fluuter/main.dart';
import 'package:fluuter/utils/MyUtils.dart';
import '../widgets/CredentialFieldWidget.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  bool _isLogin = true;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      // Shortened to make animation faster
      vsync: this,
    )..repeat(reverse: true); // Makes the animation repeat in reverse.

    _animation = Tween<double>(begin: 0.0, end: 10.0).animate(
      // Reduced range for faster movement
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white12,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            _buildCredentialField(_controllerEmail, 'myemail@gmail.com',
                Icons.account_circle_rounded),
            const SizedBox(height: 20),
            _buildCredentialField(
                _controllerPassword, 'mysecretpassword', Icons.lock),
            const SizedBox(height: 40),
            _buildAuthButton(),
            _buildToggleAuthButton(),
            const SizedBox(height: 50),
            _buildSocialIcons(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      toolbarHeight: 80,
      title: const Text(
        'Benvenuto in Easy_Code',
        style: TextStyle(
            fontSize: 25, letterSpacing: 1.3, color: Colors.deepOrange),
      ),
      backgroundColor: Colors.black,
    );
  }

  CredentialFieldWidget _buildCredentialField(
      TextEditingController controller, String hintText, IconData icon) {
    return CredentialFieldWidget(
      controller: controller,
      hintText: hintText,
      icon: icon,
    );
  }

  ElevatedButton _buildAuthButton() {
    return ElevatedButton(
      onPressed: _handleAuthAction,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.deepOrange,
        backgroundColor: Colors.black,
        elevation: 10,
        textStyle: const TextStyle(fontStyle: FontStyle.italic, fontSize: 36),
        side: const BorderSide(color: Colors.purpleAccent, width: 4.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      ),
      child: Text(_isLogin ? "Accedi" : "Registrati"),
    );
  }

  TextButton _buildToggleAuthButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isLogin = !_isLogin;
        });
      },
      style: ButtonStyle(
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.deepOrange),
      ),
      child: Text(
        _isLogin
            ? "Non hai un account? Registrati"
            : "Hai già un account? Accedi",
      ),
    );
  }

  Row _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAnimatedIcon('assets/social_network_icon/facebook.png'),
        const SizedBox(width: 20), // Aggiungi uno spazio tra le icone
        _buildAnimatedIcon('assets/social_network_icon/ig.png'),
        const SizedBox(width: 20), // Aggiungi uno spazio tra le icone
        _buildAnimatedIcon('assets/social_network_icon/snapchat.png'),
      ],
    );
  }

  Widget _buildAnimatedIcon(String assetPath) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          // Animazione di movimento su e giù
          child: IconButton(
            icon: Image.asset(assetPath),
            iconSize: 20,
            onPressed: () {
              MyToast.show(text: 'In arrivo !!');
            },
          ),
        );
      },
    );
  }

  Future<void> _handleAuthAction() async {
    try {
      if (_isLogin) {
        await FirebaseService().signInWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text,
        );
        _controllerEmail.clear();
        _controllerPassword.clear();
        MyToast.show(text: 'Attendi qualche secondo');
      } else {
        String username = await MyDialog().showInputDialog(
          context: context,
          text: 'Inserisci username',
          barrierDismissible: false,
        );

        if (username.isEmpty) {
          throw Exception("Username non valido");
        }

        await FirebaseService().createUserWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text,
          username: username,
        );
        _controllerEmail.clear();
        _controllerPassword.clear();
        MyToast.show(text: 'Attendi qualche secondo');
        MyNotification.showNotification(
            "Registrazione effettuata correttamente",
            "Benvenuto $username!!",
            MyHomePageState.flutterLocalNotificationsPlugin);
      }
    } catch (e) {
      MyToast.show(text: e.toString());
    }
  }
}
