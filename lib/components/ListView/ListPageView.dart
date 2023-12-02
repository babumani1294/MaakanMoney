import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lottie/lottie.dart';
import 'dart:math' as math;

import 'package:sizer/sizer.dart';
import 'package:tuple/tuple.dart';

import '../icon_content.dart';
import 'ListController.dart';

class ListViewBuilder extends ConsumerStatefulWidget {
  final String? getListHeading;
  final int? getIndex;
  const ListViewBuilder(
      {Key? key, required this.getListHeading, required this.getIndex})
      : super(key: key);

  @override
  ConsumerState<ListViewBuilder> createState() => _ListViewBuilderState();
}

class _ListViewBuilderState extends ConsumerState<ListViewBuilder>
    with TickerProviderStateMixin {
  late AnimationController lottieController;

  @override
  void initState() {
    super.initState();

    lottieController = AnimationController(
      vsync: this,
    );

    lottieController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        lottieController.repeat();
      }
    });
  }

  @override
  void dispose() {
    lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Select',
            style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
          ),
        ),
        body: Stack(
          children: [
            ref.read(ListProvider.notifier).getData!.isEmpty
                ? Center(
                    child: Lottie.asset("assets/90988-no-results.json",
                        height: 80.h,
                        repeat: true,
                        controller: lottieController, onLoaded: (composition) {
                      lottieController.duration = Duration(seconds: 2);
                      lottieController.forward();
                    }),
                  )
                : CustomScrollView(
                    slivers: <Widget>[
                      makeHeader(widget.getListHeading ?? ""),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return ReusableIdProofSection(
                                getText: ref
                                        .read(ListProvider.notifier)
                                        .getData![index]
                                        ?.item1 ??
                                    ""
                                        "Empty",
                                onTap: () {
                                  ref.read(adminTypeProvider.notifier).state =
                                      ref
                                              .read(ListProvider.notifier)
                                              .getData![index] ??
                                          Tuple2("", "");
                                  ref
                                      .read(ListProvider.notifier)
                                      .txtAdminType
                                      ?.text = ref
                                          .read(ListProvider.notifier)
                                          .getData![index]
                                          ?.item1 ??
                                      "";
                                  Navigator.of(context).pop();
                                });
                          },
                          childCount:
                              ref.read(ListProvider.notifier).getData!.length ??
                                  0,
                        ),
                      ),
                    ],
                  ),
          ],
        ));
  }

  //todo:- Page 2
  SliverPersistentHeader makeHeader(String headerText) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate1(
        minHeight: 50.0,
        maxHeight: 70.0,
        child: Container(
            alignment: Alignment.centerLeft,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    headerText,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    Icons.expand_circle_down,
                    size: 20,
                  ),
                ],
              ),
            )),
      ),
    );
  }

  bool _containsAlphabeticCharacters(String text) {
    final pattern = RegExp('[a-zA-Z]');
    return pattern.hasMatch(text);
  }
}

class _SliverAppBarDelegate1 extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate1({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double? minHeight;
  final double? maxHeight;
  final Widget? child;
  @override
  double get minExtent => minHeight!;
  @override
  double get maxExtent => math.max(maxHeight!, minHeight!);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate1 oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
