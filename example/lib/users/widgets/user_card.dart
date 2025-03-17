import 'package:example/models/user.dart';
import 'package:example/user_details/widgets/user_details_page.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: InkWell(
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserDetailsPage(id: user.id),
              ),
            ),
        child: PhysicalModel(
          elevation: 3,
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Text(user.name, style: const TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }
}
