import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:notemobileapp/home/home.dart';
import 'package:notemobileapp/newnote/showShareNote.dart';

import '../../newnote/newnote.dart';
import '../../router.dart';

class FirebaseDynamicLinkService{
  Future<String> createDynamicLink(bool short, String pagename, String noteid) async {

    String owner = FirebaseAuth.instance.currentUser?.email?.toString() ?? "";

    final DynamicLinkParameters dynamicLinkParams = DynamicLinkParameters(
      //link: Uri.parse("https://www.notemobileapp.com/noteData?id=${noteid}"),
      link: Uri.parse("http://localhost/noteweb/notedetail.html" + "?id=${noteid}&owner=${owner}"),
      uriPrefix: "https://notemobileapp.page.link",
      androidParameters: AndroidParameters(
        fallbackUrl: Uri.parse("https://www.google.com"),
        packageName: "com.example.notemobileapp",
        minimumVersion: 0,
      ),
      
      
    );

    Uri url;
    if(short){
      final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
      url  = shortLink.shortUrl;
    }
    else{
      url = await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);
    }

    return url.toString();
  }

  Future<void> initDynamicLink(BuildContext context) async {

    ///HANDLE TERMINATE STATE
    final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink != null) {
      String? id;
      String? owner;
      final Uri deepLink = initialLink.link;
      if(deepLink.queryParameters.isNotEmpty){
        id = deepLink.queryParameters['id'];
        owner = deepLink.queryParameters['owner'];
      }
      // Example of using the dynamic link to push the user to a different screen

      Navigator.of(context).pushNamedAndRemoveUntil(
              RoutePaths.start, (Route<dynamic> route) => false);
      
      Navigator.push(context,
                      MaterialPageRoute(
                        builder: (context) => ShowShareNote(
                          noteId: id?.toString() ?? "", 
                          isEdit: true, 
                          email: owner?.toString() ?? "", 
                          rule: 'Chỉ xem'
                        )
                      ),
                    );
    }

    ///HANDLE TERMINATE STATE
    
    
    ///HANDLE BACKGROUND STATE

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri deeplink = dynamicLinkData.link;

      final queryparams = deeplink.queryParameters;

      if(queryparams.isNotEmpty){
        String? id = deeplink.queryParameters['id'];
        String? owner = deeplink.queryParameters['owner'];

        try{

             /////////SAU NAY THAY NEW NOTE SCREEN BANG SCREEN KHAC
             /////////SAU NAY THAY NEW NOTE SCREEN BANG SCREEN KHAC
             /////////SAU NAY THAY NEW NOTE SCREEN BANG SCREEN KHAC
            Navigator.of(context).pushNamed(RoutePaths.start);
      
            Navigator.push(context,
                      MaterialPageRoute(
                        builder: (context) => ShowShareNote(
                          noteId: id?.toString() ?? "", 
                          isEdit: true, 
                          email: owner?.toString() ?? "", 
                          rule: 'Chỉ xem'
                        )
                      ),
                    );
        }
        catch(e){
          debugPrint(e.toString());
        }
      }
      
    }).onError((error) {
      // Handle errors
      debugPrint("Dynamic link error, error details: " + error.toString());
    });

    ///HANDLE BACKGROUND STATE
  }
}