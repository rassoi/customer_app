import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:rassoi/models/recommendation_models.dart';
import 'package:rassoi/recommendation_screen/recommendation_state_unused_2.dart';
import 'package:transparent_image/transparent_image.dart';

class RecommendationPageUnused extends StatelessWidget {
  RecommendationPageUnused({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Recommendation Page",
      home: RecommendationWidgetUnused("Recommendation"),
    );
  }
}

class RecommendationWidgetUnused extends StatefulWidget {
  final String title;

  RecommendationWidgetUnused(this.title, {Key? key}) : super(key: key);

  @override
  State<RecommendationWidgetUnused> createState() => _RecommendationWidgetUnusedState();
}

class _RecommendationWidgetUnusedState extends State<RecommendationWidgetUnused> {
  final SuggestionsBoxController suggestionsBoxController =
      SuggestionsBoxController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecommendationStateUnused2>(
        create: (context) {
          return RecommendationStateUnused2();
        },
        child: Scaffold(
          appBar: AppBar(title: Text(widget.title)),
          body: GestureDetector(
            onTap: () {
              if (suggestionsBoxController != null &&
                  suggestionsBoxController.isOpened()) {
                suggestionsBoxController.close();
              }
            },
            child: Consumer<RecommendationStateUnused2>(
              builder: (context, recommendationState, widget) {
                return FutureBuilder<List<RecommendationModel>>(
                  future: recommendationState.getAllResultsFuture(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<RecommendationModel>> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    return SizedBox(
                      child: ListView.separated(
                        scrollDirection: Axis.vertical,
                        itemCount:
                            snapshot.data != null ? snapshot.data!.length : 0,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            height: 10,
                            width: 10,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 0) {
                            // Search bar typeahead
                            return getSearchbarWidget();
                          } else if (index == 1) {
                            // Favourites
                            return getFavouritesWidget();
                          }
                          // All Result widget for index
                          return getAllResultWidgetForIndex(
                              recommendationState, snapshot, index);
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

  getSearchbarWidget() {
    return Consumer<RecommendationStateUnused2>(
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
                  style: DefaultTextStyle.of(context)
                      .style
                      .copyWith(fontStyle: FontStyle.normal, fontSize: 15.0),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      filled: true,
                      // hintStyle: TextStyle(color: Colors.grey[800]),
                      hintText: "Type in your text",
                      fillColor: Colors.white10)),
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
                    border: Border.all(color: Colors.black26, width: 1),
                  ),
                  child: ListTile(
                    //    leading: Icon(Icons.shopping_cart),
                    title: Text(data as String),
                    //  subtitle: Text('\$${suggestion['price']}'),
                  ),
                );
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  recommendationState.setCurrentQuery(suggestion as String?);
                });
              },
            ),
          ),
        );
      },
    );
  }

  getFavouritesWidget() {
    return Consumer<RecommendationStateUnused2>(
      builder: (context, recommendationState, widget) {
        return recommendationState.favouritesFuture != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Favourites
                  const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 10, 20),
                      child: Text("Favourites")),
                  FutureBuilder<List<RecommendationModel>>(
                    future: recommendationState.favouritesFuture,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<RecommendationModel>> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              snapshot.data != null ? snapshot.data!.length : 0,
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(
                              height: 10,
                              width: 10,
                            );
                          },
                          itemBuilder: (BuildContext context, int index) {
                            String image = snapshot.data!
                                .elementAt(index)
                                .getDishImageUrl();
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

  getAllResultWidgetForIndex(RecommendationStateUnused2 recommendationState,
      AsyncSnapshot<List<RecommendationModel>> snapshot, int index) {
    String image = snapshot.data!.elementAt(index).getDishImageUrl();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index == 2)
          const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 10, 20),
              child: Text("Results")),
        Container(
          color: Colors.black12,
          height: 200,
          child: getResultImageWidget(context, image, recommendationState,
              snapshot.data!.elementAt(index)),
        )
      ],
    );
  }

  getResultImageWidget(BuildContext context, String image,
      RecommendationStateUnused2 recommendationState, RecommendationModel dishModel) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FadeInImage.memoryNetwork(
          height: 200,
          placeholder: kTransparentImage,
          fit: BoxFit.cover,
          image: image,
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: Icon(dishModel.isFavourite ? Icons.close : Icons.add),
            highlightColor: Colors.pink,
            onPressed: () {
              dishModel.isFavourite = !dishModel.isFavourite;
              setState(() {});
              recommendationState
                  .toggleFavouriteForDish(dishModel)
                  .then((success) {
                if (!success) {
                  dishModel.isFavourite = !dishModel.isFavourite;
                  setState(() {});
                  // Show message something went wrong
                }
              });
            },
          ),
        )
      ],
    );
  }
}
