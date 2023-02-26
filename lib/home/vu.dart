import 'package:animated_stack/animated_stack.dart';
import 'package:flutter/material.dart';

class Vu extends StatefulWidget {
  const Vu({Key? key}) : super(key: key);

  @override
  _VuState createState() => _VuState();
}

class _VuState extends State<Vu> {
  @override
  Widget build(BuildContext context) {
    return AnimatedStack(
      backgroundColor: const Color(0xff321B4A),
      fabBackgroundColor: const Color(0xffEB456F),
      foregroundWidget: Container(
        decoration: const BoxDecoration(
          color: Color(0xff56377C),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black26,
              blurRadius: 1,
              offset: Offset(4, 4),
            ),
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(1),
          ),
        ),
        child: Scaffold(
          appBar: AppBar(),
          body: ListView.builder(
            itemCount: 9,
            itemBuilder: (context, index) {
              return _ItemPlaceholder();
            },
          ),
        ),
      ),
      columnWidget: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.height,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 20,
          itemBuilder: (context, index) {
            return const CircleAvatar(
              radius: 80,
            );
          },
        ),
      ),
      bottomWidget: Container(
        decoration: const BoxDecoration(
          color: Color(0xff645478),
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        width: 260,
        height: 50,
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  final double width;
  final double height;
  final IconData iconData;

  const _IconTile(
      {Key? key,
      required this.width,
      required this.height,
      required this.iconData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color(0xff645478),
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Icon(
        iconData,
        color: Color(0xffAEA6B6),
      ),
    );
  }
}

class _ItemPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipOval(
            child: Container(
              width: 60,
              height: 60,
              color: const Color(0xff9783A9),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xff6D528D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: _RowPlaceholder(color: 0xffA597B4),
                      width: MediaQuery.of(context).size.width * 2 / 5,
                    ),
                    _RowPlaceholder(color: 0xff846CA1),
                    _RowPlaceholder(color: 0xff846CA1),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _RowPlaceholder extends StatelessWidget {
  final int color;

  const _RowPlaceholder({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 15,
      decoration: BoxDecoration(
        color: Color(color),
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
    );
  }
}
