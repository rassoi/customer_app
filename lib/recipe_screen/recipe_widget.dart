import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RecipeWidget extends StatelessWidget {
  const RecipeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     return MaterialApp(
       title: "Recipe Details",
       home: Scaffold(
         appBar: AppBar(
           title: const Text('Rassoi'),
         ),
         body: Column(
           children: [
             SizedBox(
             height: 200,
             child: YoutubePlayer(
               controller: YoutubePlayerController(
                 initialVideoId: getVideoId("https://www.youtube.com/watch?v=JupJtfiNn2M"), //Add videoID.
                 flags: const YoutubePlayerFlags(
                   hideControls: false,
                   controlsVisibleAtStart: true,
                   autoPlay: true,
                   mute: false,
                 ),
               ),
               showVideoProgressIndicator: true,
               progressIndicatorColor: Colors.white,
             ),
           ),
             SizedBox(
               height: 20,
             ),
             Text("Aaloo Dum"),
             SizedBox(
               height: 20,
             ),
             Text("Description"),
           ],
         ),
       ),
     );
  }

  String getVideoId(String youtubeUrl) {
    String? videoID;
    try {
      videoID= YoutubePlayer.convertUrlToId(youtubeUrl);
    } on Exception catch (exception) {
      return "";
    } catch (error) {
      return "";
    }
    return videoID ?? "";
  }

}