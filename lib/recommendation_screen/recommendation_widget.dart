import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:rassoi/recommendation_screen/recommendation_state.dart';
import 'package:transparent_image/transparent_image.dart';

class RecommendationPage extends StatelessWidget {
  RecommendationPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Recommendation Page",
      home: RecommendationWidget("Recommendation"),
    );
  }
}

class RecommendationWidget extends StatelessWidget {
  final String title;
  final SuggestionsBoxController suggestionsBoxController = SuggestionsBoxController();

   RecommendationWidget(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecommendationState>(
        create: (context) {
          return RecommendationState();
        },
        child: Scaffold(
          appBar: AppBar(title: Text(title)),
          body: GestureDetector(
            onTap: () {
              if (suggestionsBoxController.isOpened()) {
                suggestionsBoxController.close();
              }
            },
            child: Consumer<RecommendationState>(
              builder: (context, recommendationState, widget) {
                return FutureBuilder<Iterable<String>>(
                  future: recommendationState.querySearchResultList(),
                  builder: (BuildContext context, AsyncSnapshot<Iterable<String>> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    return SizedBox(
                      child: ListView.separated(
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data != null
                            ? snapshot.data!.length
                            : 0,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            height: 10,
                            width: 10,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 0) {
                            // Search bar typeahead
                            return Consumer<RecommendationState>(
                              builder: (context, recommendationState, widget) {
                                return Container(
                                  alignment: Alignment.centerLeft,
                                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  //padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  height: 40,
                                  child: Material(
                                    elevation: 10,
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: TypeAheadField(
                                      suggestionsBoxController: suggestionsBoxController,
                                      textFieldConfiguration: TextFieldConfiguration(
                                          autofocus: true,
                                          style: DefaultTextStyle.of(context).style.copyWith(
                                              fontStyle: FontStyle.normal, fontSize: 15.0),
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                              ),
                                              filled: true,
                                              // hintStyle: TextStyle(color: Colors.grey[800]),
                                              hintText: "Type in your text",
                                              fillColor: Colors.white10)
                                      ),
                                      suggestionsCallback: (pattern) async {
                                        return recommendationState.querySearchSuggestionList(pattern);
                                      },
                                      itemBuilder: (context, data) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
/*                                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(9),
                  topLeft: const Radius.circular(9),
                ),*/
                                            border: Border.all(
                                                color: Colors.black26,
                                                width: 1
                                            ),
                                          ),
                                          child: ListTile(
                                            //    leading: Icon(Icons.shopping_cart),
                                            title: Text(data as String),
                                            //  subtitle: Text('\$${suggestion['price']}'),
                                          ),
                                        );
                                      },
                                      onSuggestionSelected: (suggestion) {
                                        /*        Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProductPage(product: suggestion)
                  ));*/
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (index == 1) {
                            // Favourites
                            return  Consumer<RecommendationState>(
                              builder: (context, recommendationState, widget) {
                                return recommendationState.favouritesFuture != null
                                    ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                        padding: EdgeInsets.fromLTRB(20, 20, 10, 20),
                                        child: Text("Favourites")),
                                    FutureBuilder<Iterable<String>>(
                                      future: recommendationState.favouritesFuture,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<Iterable<String>> snapshot) {
                                        if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        }
                                        return SizedBox(
                                          height: 100,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: snapshot.data != null
                                                ? snapshot.data!.length
                                                : 0,
                                            separatorBuilder:
                                                (BuildContext context, int index) {
                                              return const SizedBox(
                                                height: 10,
                                                width: 10,
                                              );
                                            },
                                            itemBuilder:
                                                (BuildContext context, int index) {
                                              String image =
                                              snapshot.data!.elementAt(index);
                                              return Container(
                                                color: Colors.black12,
                                                height: 100,
                                                child: FadeInImage.memoryNetwork(
                                                  width: 100,
                                                  height: 100,
                                                  placeholder: kTransparentImage,
                                                  fit: BoxFit.cover,
                                                  image: image,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    )
                                  ],
                                )
                                    : const SizedBox.shrink();
                              },
                            );
                          }
                          String image =
                              snapshot.data!.elementAt(index);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index == 2) const Padding(
                              padding: EdgeInsets.fromLTRB(20, 20, 10, 20),
                              child: Text("Results")),
                              Container(
                              color: Colors.black12,
                              height: 200,
                              child: getResultImageWidget(image),
                            )
                            ],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ));
  }
  
  getResultImageWidget(String image) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FadeInImage.memoryNetwork(
          height: 200,
          placeholder: kTransparentImage,
          fit: BoxFit.cover,
          image: image,
        ),
        const Align(
          alignment: Alignment.topRight,
          child: Icon(Icons.save),
        )
      ],
    );
  }
}
