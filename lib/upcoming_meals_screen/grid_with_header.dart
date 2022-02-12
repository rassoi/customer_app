import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';

class GridHeader extends StatefulWidget {
  const GridHeader({Key? key}) : super(key: key);

  @override
  _GridHeaderState createState() => _GridHeaderState();
}

class _GridHeaderState extends State<GridHeader> {
  List<String> listHeader = [
    'HEADER1',
    'HEADER2',
    'HEADER3',
    'HEADER4',
    'HEADER5',
    'HEADER6',
    'HEADER7',
    'HEADER8',
    'HEADER9',
    'HEADER10',
  ];
  List<String> listTitle = [
    'title1',
    'title2',
    'title3',
    'title4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
/*      appBar: AppBar(
        title: const Text("Grid Header Demo"),
      ),*/
      body: gridHeader(),
    );
  }

  Widget gridHeader() {
    return ListView.builder(
      itemCount: listHeader.length,
      itemBuilder: (context, index) {
        print("Karan header"+ index.toString());
        return StickyHeader(
          header: Container(
            height: 38.0,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            alignment: Alignment.centerLeft,
            child: Text(
              listHeader[index],
              style: const TextStyle(
                  color: Colors.purple,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          content: Container(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listTitle.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemBuilder: (contxt, indx) {
                print("Karan title"+ indx.toString());
                return Card(
                  margin: const EdgeInsets.all(4.0),
                  color: Colors.purpleAccent,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 12.0, top: 6.0, bottom: 2.0),
                    child: Center(
                        child: Text(
                      listTitle[indx],
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    )),
                  ),
                );
              },
            ),
          ),
        );
      },
      shrinkWrap: true,
    );
  }
}
