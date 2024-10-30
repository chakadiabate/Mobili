import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projet_fin/moblie/Login.dart';
import 'package:provider/provider.dart';

import 'moblie/screens/Navigation.dart';


class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User?>(context);
    return _user == null ? Login() : Navigation();
  }
}
