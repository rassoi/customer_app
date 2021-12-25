import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassoi/recommendation_screen/recommendation_state.dart';
import 'package:transparent_image/transparent_image.dart';

class RecommendationPage extends StatelessWidget {
  RecommendationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   return const MaterialApp(
     title: "Recommendation Page",
     home: RecommendationWidget("Recommendation"),
   );
  }
}

class RecommendationWidget extends StatelessWidget {
  final String title;

  const RecommendationWidget(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecommendationState>(
        create: (context) {
          return RecommendationState();
        },
        child: Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                //padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                height: 40,
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(10.0),
                  child: TextField(
                    style: const TextStyle(
                      fontSize: 15.0,
                    ),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        filled: true,
                        // hintStyle: TextStyle(color: Colors.grey[800]),
                        hintText: "Type in your text",
                        fillColor: Colors.white10),
                  ),
                ),
              ),
              const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 10, 20),
                  child: Text("Favourites")),
              Consumer<RecommendationState>(
                builder: (context, recommendationState, widget) {
                  return FutureBuilder<Iterable<String>>(
                    future: recommendationState.querySearchResultList(null),
                    builder: (BuildContext context,
                        AsyncSnapshot<Iterable<String>> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const Text('Loading...');
                        default:
                          return SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length,
                              separatorBuilder: (BuildContext context,
                                  int index) {
                                return const SizedBox(
                                  height: 10,
                                  width: 10,
                                );
                              },
                              itemBuilder: (BuildContext context, int index) {
                                String image = snapshot.data!.elementAt(index);
                                return Container(
                                  color: Colors.red,
                                  height: 100,
                                  child: FadeInImage.memoryNetwork(
                                    width: 100,
                                    height: 100,
                                    placeholder: kTransparentImage,
                                    fit: BoxFit.cover,
                                    image:
                                    "https://images.unsplash.com/photo-1503818454-2a008dc38d43?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dGFsbHxlbnwwfHwwfHw%3D&w=1000&q=80",
                                  ),
                                );
                              },
                            ),
                          );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        )
    );
  }
}