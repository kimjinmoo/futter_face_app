import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SlidingCard extends StatelessWidget {
  final String name;
  final String comment;
  final String imageUrl;
  final VoidCallback showDetailHandler;
  final VoidCallback showDeleteHandler;

  const SlidingCard(
      {Key key,
      this.name,
      this.comment,
      this.imageUrl,
      this.showDetailHandler,
      this.showDeleteHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.only(left: 18, right: 18, bottom: 24),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Column(
          children: [
            InkWell(
              onTap: showDeleteHandler,
              child: Container(
                padding: EdgeInsets.only(top: 10),
                color: Colors.transparent,
                child: Text(
                  "삭제하기",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
                child: GestureDetector(
              onTap: showDetailHandler,
              child: Column(
                children: [
                  SizedBox(
                    height: 18,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ClipRRect(
                  //     borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  //     child:
                  // ),
                  SizedBox(
                    height: 8,
                  ),
                  Expanded(
                      child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        comment,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ))
                ],
              ),
            ))
          ],
        ));
  }
}
