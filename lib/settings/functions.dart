import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

bool isAnonymousUser() => FirebaseAuth.instance.currentUser!.isAnonymous;

String getID() => DateFormat('d.M.y-kk:mm:ss').format(DateTime.now());

String userId() => FirebaseAuth.instance.currentUser!.email.toString();

isOwner() =>
    !isAnonymousUser() &&
        ((FirebaseAuth.instance.currentUser!.email! ==
            "sujithnimmala03@gmail.com") ||
            (FirebaseAuth.instance.currentUser!.email! ==
                "sujithnaidu03@gmail.com"));
