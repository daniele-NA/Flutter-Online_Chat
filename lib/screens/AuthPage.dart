import 'package:flutter/material.dart';
import 'package:fluuter/connections/firebase.dart';
import 'package:fluuter/connections/firestore.dart';
import 'package:fluuter/main.dart';
import 'package:fluuter/utils/MyUtils.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Importa flutter_rating_bar
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

  /**
   * controller per animazione loghi
   */
  late AnimationController _animationController;
  late Animation<double> _animation;

  double _rating = 0; // Variabile per memorizzare la valutazione

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  //animazione loghi social network
  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 10.0).animate(
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

            // RatingBar a 5 stelle in basso
            const SizedBox(height: 50),
            // Aggiungi spazio tra gli altri elementi
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                // Spazio per la label
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  // Colore di sfondo semitrasparente per "schiarire"
                  borderRadius: BorderRadius.circular(
                      10), // Opzionale: bordi arrotondati per effetto più morbido
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Aggiungi una label opzionale sopra la RatingBar
                    Text(
                      'Valuta la tua esperienza',
                      // Puoi modificare questo testo come vuoi
                      style: TextStyle(
                        color: Colors.purpleAccent, // Colore del testo
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8), // Spazio tra il testo e le stelle
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 40,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        if (_rating == 0) {
                          setState(() {
                            _rating = rating; // Aggiorna la valutazione
                          });
                          try {
                            FirestoreService().insertRating(value: rating);
                          } catch (e) {
                            MyToast.show(text: e.toString());
                          }
                        }
                      },
                      ignoreGestures: _rating !=
                          0, // Disabilita l'interazione dopo il primo clic
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * widget per appBar
   */
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

  /**
   * chiamata al mio widget per gli input
   */
  CredentialFieldWidget _buildCredentialField(
      TextEditingController controller, String hintText, IconData icon) {
    return CredentialFieldWidget(
      controller: controller,
      hintText: hintText,
      icon: icon,
    );
  }

  /**
   * costruzione bottone per accesso/registrazione
   */
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

  /**
   * bottone accedi/registrati
   */
  TextButton _buildToggleAuthButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isLogin = !_isLogin;
        });
      },
      style: ButtonStyle(
        textStyle: WidgetStateProperty.all<TextStyle>(
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.deepOrange),
      ),
      child: Text(
        _isLogin
            ? "Non hai un account? Registrati"
            : "Hai già un account? Accedi",
      ),
    );
  }

  /**
   * costruzione loghi social
   */
  Row _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAnimatedIcon('assets/social_network_icon/facebook.png'),
        const SizedBox(width: 20),
        _buildAnimatedIcon('assets/social_network_icon/ig.png'),
        const SizedBox(width: 20),
        _buildAnimatedIcon('assets/social_network_icon/snapchat.png'),
      ],
    );
  }

  /**
   * costruzione icone animate
   */
  Widget _buildAnimatedIcon(String assetPath) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
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

  /**
   * gestione login/registrazione
   */
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
