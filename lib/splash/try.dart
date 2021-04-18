import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Home> {

  final _authForm = GlobalKey<FormState>();
  final _smsForm = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool isVerified = false;

  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();
  String _verificationId;
  FirebaseAuth auth;
  @override
  initState(){
    super.initState();
    getFireBase();
  }

  getFireBase() async{
    final String name = 'Anna Sir';
    final FirebaseOptions options = const FirebaseOptions(
        googleAppID: '1:147894380946:android:e723e754413d2cf268f94b',
        apiKey: 'AIzaSyC8-6buT4lBlDnRF6xtIPsm3aa3QcRNxsU',
        projectID: 'anna-c6eda'
    );

    final FirebaseApp _fireBase = await FirebaseApp.configure(name: name, options: options);
    auth = FirebaseAuth.fromApp(_fireBase);

  }


  Future<void> _sigIn(String otp)async{
    if(_smsForm.currentState.validate()){
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId,
        smsCode: _smsController.text,
      );
      final FirebaseUser user =
          (await auth.signInWithCredential(credential)).user;
      final FirebaseUser currentUser = await auth.currentUser();
      assert(user.uid == currentUser.uid);

      if (user != null) {
        setState(() {
          this.isVerified = true;
        });
        Navigator.pop(context);
        print( 'Successfully signed in, uid: ' + user.uid);
      } else {
        print('Sign in failed');
      }
    }

  }
  Future<void> _verify()async{
    if(_authForm.currentState.validate()){
      setState(() {
        this.isLoading = true;
      });
      try{
        final PhoneVerificationCompleted verificationCompleted =
            (AuthCredential phoneAuthCredential) {
          auth.signInWithCredential(phoneAuthCredential);
          print(phoneAuthCredential);
        };

        final PhoneVerificationFailed verificationFailed =
            (AuthException authException) {
          print(authException);
        };

        final PhoneCodeSent codeSent =
            (String verificationId, [int forceResendingToken]) async {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content:
            const Text('Please check your phone for the verification code.'),
          ));
          _verificationId = verificationId;
          showDialog(context: context,barrierDismissible: false,
              builder: (context)=>SimpleDialog(
                title: Text("Enter OTP"),
                children: <Widget>[
                  SimpleDialogOption(
                    child: Form(
                      key: _smsForm,
                      child: TextFormField(
                        controller: _smsController,
                        maxLength: 6,
                        onSaved: (val){
                          return _sigIn(val);
                        },
                        validator: (val)=>val.length != 6 ? "Invalid OTP!":null,
                        decoration: InputDecoration(
                            labelText: "OTP"
                        ),
                      ),
                    ),
                  ),
                  SimpleDialogOption(
                    child: RaisedButton(
                      child: Text("Verify"),
                      onPressed: ()=>_sigIn(_smsController.text),
                    ),
                  )
                ],
              ));

        };

        final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
            (String verificationId) {
          _verificationId = verificationId;
        };

        await auth.verifyPhoneNumber(
            phoneNumber: "+91"+_phoneController.text,
            timeout: const Duration(seconds: 5),
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
      }catch(_){
        setState(() {
          this.isLoading = false;
        });
        print("AUTH FAILED: $_");
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isVerified ? Scaffold(
      appBar: AppBar(title: Text("Home"),),
      body: Center(child: Text("Welcome to Flutter FireBase Login!"),),
    ) : Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Phone Authentication"),
        centerTitle: true,
      ),
      body: isLoading ? Center(
        child: CircularProgressIndicator(),
      ) : Center(
        child: Form(
          key: _authForm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                onFieldSubmitted: (fl){
                  return _verify();
                },
                textInputAction: TextInputAction.done,
                controller: _phoneController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Phone Number",
                    hintText: "+919999999999"
                ),
              ),
              SizedBox(height: 10.0,),
              RaisedButton(
                onPressed: ()=>_verify(),
                child: Text("Sign In"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

