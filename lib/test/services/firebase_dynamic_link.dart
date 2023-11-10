import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

import '../../newnote/newnote.dart';

class FirebaseDynamicLinkService{
  Future<String> createDynamicLink(bool short, String pagename, String noteid) async {

    final DynamicLinkParameters dynamicLinkParams = DynamicLinkParameters(
      //link: Uri.parse("https://www.notemobileapp.com/noteData?id=${noteid}"),
      link: Uri.parse("https://notemobileapp.page.link/" + pagename + "?id=${noteid}"),
      uriPrefix: "https://notemobileapp.page.link",
      androidParameters: const AndroidParameters(
        packageName: "com.example.notemobileapp",
        minimumVersion: 30,
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
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri deeplink = dynamicLinkData.link;

      final queryparams = deeplink.queryParameters;

      if(queryparams.isNotEmpty){
        String? id = deeplink.queryParameters['id'];

        try{

             /////////SAU NAY THAY NEW NOTE SCREEN BANG SCREEN KHAC
             /////////SAU NAY THAY NEW NOTE SCREEN BANG SCREEN KHAC
             /////////SAU NAY THAY NEW NOTE SCREEN BANG SCREEN KHAC
             Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewNoteScreen(
                                  noteId: id?.toString() ?? "",
                                  isEdit: false,
                                  email: FirebaseAuth.instance.currentUser?.email,
                                ),
                              ));
        }
        catch(e){
          debugPrint(e.toString());
        }
      }
      
    }).onError((error) {
      // Handle errors
      debugPrint("Dynamic link error, error details: " + error.toString());
    });
  }
}