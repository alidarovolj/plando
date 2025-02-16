import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plando/core/widgets/custom_app_bar.dart';
import 'package:plando/core/providers/requests/doctor_provider.dart';
import 'package:plando/core/types/slides.dart';

final List<Slide> slideList = [
  const Slide(
    image: 'lib/core/assets/images/promos/test.jpg',
    title: 'Скидка 20%',
    description: 'На УЗИ и МРТ при записи через приложение',
    partner: 'lib/core/assets/images/promos/partner.png',
    link: 'https://youtube.com',
  ),
  const Slide(
    image: 'lib/core/assets/images/promos/test2.jpg',
    title: '',
    description: '',
    partner: 'lib/core/assets/images/promos/partner2.png',
    link: 'https://google.com',
  ),
];

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final scrollController = ScrollController();
  bool isCompact = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.hasClients) {
      if (scrollController.offset > 20 && !isCompact) {
        setState(() {
          isCompact = true;
        });
      } else if (scrollController.offset <= 20 && isCompact) {
        setState(() {
          isCompact = false;
        });
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsProvider);

    return const Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomAppBar(),
          ),
        ],
      ),
    );
  }
}
