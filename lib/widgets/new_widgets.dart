import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SABTN extends StatefulWidget {
  final void Function()? onBack;

  const SABTN({Key? key, this.onBack}) : super(key: key);

  @override
  _SABTNState createState() => _SABTNState();
}

class _SABTNState extends State<SABTN> {
  ScrollPosition? _position;
  bool? _visible;

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeListener();
    _addListener();
  }

  void _addListener() {
    _position = Scrollable.of(context)?.position;
    _position?.addListener(_positionListener);
    _positionListener();
  }

  void _removeListener() {
    _position?.removeListener(_positionListener);
  }

  void _positionListener() {
    final FlexibleSpaceBarSettings? settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    bool visible =
        settings == null || settings.currentExtent <= settings.minExtent;
    if (_visible != visible) {
      setState(() {
        _visible = visible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1,
      curve: Curves.easeIn,
      child: IconButton(
        onPressed: widget.onBack ??
            () {
              // Get.back();
            },
        icon: Icon(
          Icons.arrow_back,
          color: _visible == false ? Colors.white : Colors.blue,
        ),
      ),
    );
  }
}

class SABT extends StatefulWidget {
  final Widget child;

  const SABT({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  _SABTState createState() => _SABTState();
}

class _SABTState extends State<SABT> {
  ScrollPosition? _position;
  bool? _visible;

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeListener();
    _addListener();
  }

  void _addListener() {
    _position = Scrollable.of(context)?.position;
    _position?.addListener(_positionListener);
    _positionListener();
  }

  void _removeListener() {
    _position?.removeListener(_positionListener);
  }

  void _positionListener() {
    final FlexibleSpaceBarSettings? settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    bool visible =
        settings == null || settings.currentExtent <= settings.minExtent;
    if (_visible != visible) {
      setState(() {
        _visible = visible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _visible!,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1,
        curve: Curves.easeIn,
        child: widget.child,
      ),
    );
  }
}

Widget movieFlexibleSpacebarComponent({
  // required MovieDetailsModel movie,
  double? height,
}) {
  // final String? releaseDate = '${movie.releaseDate}';
  // final String? formatedDate =
  //     DateFormat.yMMMMd().format(movie.releaseDate ?? DateTime(0000));
  // final String movieDate = releaseDate!.substring(0, 4);

  return SizedBox(
    // height: _utilityController.titlevisiblity == false ? 310 : 300,
    height: 310,
    child: Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        // backdrop image slider
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              // Obx(
              //   () =>
              ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.black,
                      Colors.black,
                      Colors.transparent
                    ],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstIn,
                child: Container(
                  decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.transparent)),
                  ),
                  child: SizedBox(
                    height: height ?? 190,
                    child: PageView.builder(
                      onPageChanged: (value) {
                        // _utilityController.setSliderIndex(value);
                      },
                      itemCount: 1,
                      controller: PageController(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return BackdropCard(
                            imageUrl:
                                'https://image.tmdb.org/t/p/w500/A2uAzLDBIiXQqCExhaotEfLZGiX.jpg');
                      },
                    ),
                  ),
                ),
              ),

              // ),

              // img slider indicator
              Positioned(
                bottom: 16,
                child: AnimatedSmoothIndicator(
                  activeIndex: 1,
                  effect: ScrollingDotsEffect(
                    activeDotColor: Colors.blue,
                    dotColor: Colors.blue,
                    dotHeight: 6,
                    dotWidth: 6,
                  ),
                  count: 1,
                ),
              ),
            ],
          ),
        ),

        // poster and title movie details
        Positioned(
          bottom: 0.0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // poster
                ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: posterCard(
                        imageUrl:
                            'https://image.tmdb.org/t/p/w500/A2uAzLDBIiXQqCExhaotEfLZGiX.jpg')),
                const SizedBox(width: 16),
                //  titles
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.black.withOpacity(0.5),
                                  width: 1,
                                ),
                                left: BorderSide(
                                  color: Colors.black.withOpacity(0.5),
                                  width: 1,
                                ),
                                right: BorderSide(
                                  color: Colors.black.withOpacity(0.5),
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: Colors.black.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'released',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          // _utilityController.toggleTitleVisibility();
                        },
                        child: Text(
                          'Friends 2000',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        children: [
                          Text(
                            '2000',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '100 mins',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Text(
                              "tagline",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.blue.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class BackdropCard extends StatelessWidget {
  const BackdropCard({required this.imageUrl, Key? key}) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: imageUrl.isEmpty
          ? null
          : () {
              // Get.toNamed(
              //   '/backdrop_preview',
              //   arguments: {"filePath": imageUrl},
              // );
            },
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: imageUrl,
        errorWidget: (context, url, error) => Container(
          alignment: Alignment.center,
          // width: 94,
          // height: 140,
          color: Colors.black12,
          child: const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 34,
          ),
        ),
      ),
    );
  }
}

Widget posterCard({required String? imageUrl}) {
  // final _configurationController = Get.find<ConfigurationController>();

  return GestureDetector(
    onTap: imageUrl == null
        ? null
        : () {
            // Get.toNamed(
            //   '/poster_preview',
            //   arguments: {"filePath": imageUrl},
            // );
          },
    child: Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: imageUrl == null
            ? Container(
                alignment: Alignment.center,
                width: 94,
                height: 140,
                color: Colors.black12,
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 34,
                ),
              )
            : CachedNetworkImage(
                width: 94,
                height: 140,
                fit: BoxFit.fill,
                errorWidget: (context, url, error) => Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                  ),
                  child: const Icon(
                    Icons.error,
                    color: Colors.white,
                  ),
                ),
                imageUrl:
                    'https://image.tmdb.org/t/p/w500/A2uAzLDBIiXQqCExhaotEfLZGiX.jpg',
                placeholder: (context, url) => Container(
                  color: Colors.black12,
                ),
              ),
      ),
    ),
  );
}

///
///
///
//

Widget movieFlexibleSpacebarOptions() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // user score circle percent indicator
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 18, 0),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 30,
              percent: (7 / 10),
              curve: Curves.ease,
              animation: true,
              animationDuration: 800,
              progressColor: Colors.blue,
              center: Text(
                '70%',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'User\nScore',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),

      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          // height: 46,
          // width: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '1440',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          'Vote\nCounts',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.blue,
          ),
        ),
      ])
    ],
  );
}

// helpers
Widget optionBtn({IconData? icon, void Function()? onTap, Color? color}) {
  return GestureDetector(
    onTap: onTap ?? () {},
    child: Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
        ),
        Icon(
          icon ?? Icons.list,
          size: 20,
          color: color ?? Colors.white,
        ),
      ],
    ),
  );
}
