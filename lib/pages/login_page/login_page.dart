import 'package:flutter/material.dart';

import 'package:nethive_neo/models/users/token.dart';
import 'package:nethive_neo/pages/login_page/widgets/login_form.dart';
import 'package:nethive_neo/pages/login_page/widgets/right_image.dart';
import 'package:nethive_neo/theme/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
    this.token,
  }) : super(key: key);

  final Token? token;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      key: scaffoldKey,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primaryBackground,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Center(
                    child: LoginForm(),
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).primaryBackground,
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    const Positioned(
                      top: 101,
                      left: 109,
                      child: LoginForm(),
                    ),
                    const Positioned(
                      right: 0,
                      child: RightImageWidget(),
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
