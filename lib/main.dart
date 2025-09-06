import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tickets_kokosai_jp/firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
      debugShowCheckedModeBanner: false,
      supportedLocales: [Locale('ja', 'JP')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(fontFamily: 'NotoSansJP'),
      locale: Locale("ja", "JP"),
    );
  }
}

class PerformanceData {
  final String title;
  final String venue;
  final String date;
  final String time;
  final String prText;
  final String classnumber;

  PerformanceData({
    required this.title,
    required this.venue,
    required this.date,
    required this.time,
    required this.prText,
    required this.classnumber,
  });
}

class UrlLauncherUtil {
  static Future<void> launch({
    required String url,
    required BuildContext context,
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    final Uri uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URLを開けませんでした。'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    await launchUrl(uri, mode: mode);
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> scrollOffsetNotifier = ValueNotifier(0.0);
  bool _shouldAnimateIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _shouldAnimateIn = true;
        });
      }
    });
    _scrollController.addListener(() {
      scrollOffsetNotifier.value = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
      setState(() {
        _shouldAnimateIn = false;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _shouldAnimateIn = true;
          });
        }
      });
    }
  }

  Widget animatedTextItem({
    required String text,
    required int duration,
    required bool isVisible,
    required double top,
    left,
    required TextStyle? style,
  }) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: duration),
      curve: Curves.easeOut,
      top: isVisible ? top : top + 20,
      left: isVisible ? left : left - 20,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: Duration(milliseconds: duration),
        curve: Curves.easeIn,
        child: Text(text, style: style),
      ),
    );
  }

  Widget animatedItem({
    required Widget child,
    required int duration,
    required bool isVisible,
    double? top,
    double? left,
    double? right,
    double? bottom,
  }) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: duration),
      curve: Curves.easeOut,
      top: isVisible ? top : (top != null ? top + 50 : null),
      left: isVisible ? left : (left != null ? left - 50 : null),
      right: isVisible ? right : (right != null ? right - 50 : null),
      bottom: isVisible ? bottom : (bottom != null ? bottom - 50 : null),
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: Duration(milliseconds: duration),
        curve: Curves.easeIn,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F4FF),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  animatedItem(
                    isVisible: _shouldAnimateIn,
                    duration: 1500,
                    top: 20,
                    right: -10,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 127, 183, 248),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  animatedItem(
                    isVisible: _shouldAnimateIn,
                    duration: 1500,
                    top: 80,
                    right: -10,
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 240, 244, 249),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  animatedItem(
                    isVisible: _shouldAnimateIn,
                    duration: 1500,
                    bottom: 100,
                    right: 30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 178, 222, 246),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  animatedItem(
                    isVisible: _shouldAnimateIn,
                    duration: 800,
                    top: 50,
                    left: 50,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6B8FD4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  animatedItem(
                    isVisible: _shouldAnimateIn,
                    duration: 1500,
                    bottom: 100,
                    left: -50,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: const BoxDecoration(
                        color: Color(0xFF90D490),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  animatedItem(
                    isVisible: _shouldAnimateIn,
                    duration: 1800,
                    top: 250,
                    left: -150,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF6B8FD4),
                          width: 30,
                        ),
                      ),
                      child: const Center(
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Color(0xFF6B8FD4),
                        ),
                      ),
                    ),
                  ),
                  animatedTextItem(
                    isVisible: _shouldAnimateIn,
                    text: '鯱光祭\n三年劇チケット\n予約サイト',
                    duration: 1500,
                    top: 100,
                    left: 20,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  animatedTextItem(
                    isVisible: _shouldAnimateIn,
                    text: '77th Kokosai\nAsahigaoka High School',
                    duration: 1800,
                    top: 270,
                    left: 20,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedOpacity(
                opacity: _shouldAnimateIn ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeIn,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOut,
                  transform: Matrix4.translationValues(
                    0,
                    _shouldAnimateIn ? 0 : 50,
                    0,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            offset: const Offset(5, 5),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.confirmation_number,
                            size: 30,
                            color: const Color(0xFF6B8FD4),
                          ),
                          Text(
                            "三年劇チケット予約について",
                            style: TextStyle(
                              fontSize: 25,
                              fontFamily: 'NotoSansJP',
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "予約は抽選制です\n募集締め切り＆抽選は9/25です",
                            style: TextStyle(
                              fontSize: 25,
                              color: const Color.fromARGB(255, 255, 0, 0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "・劇の予約は一人につき3件まで可能です。ただし同じ時間帯の予約は1件しかできません。\n・抽選結果は9/25にメールでお知らせします。\n・メールアドレスは複数使用しないでください。",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B8FD4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TicketPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "予約選択へ",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          TextButton(
                            onPressed: () {
                              UrlLauncherUtil.launch(
                                url: 'https://tickets.kokosai.jp/faq',
                                context: context,
                              );
                            },
                            child: Text("その他の予約に関する説明はこちらから"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        UrlLauncherUtil.launch(
                          url: 'https://tickets.kokosai.jp/privacy',
                          context: context,
                        );
                      },
                      child: const Text(
                        'プライバシーポリシー',
                        style: TextStyle(color: Color(0xFF6B8FD4)),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('|', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () {
                        UrlLauncherUtil.launch(
                          url: 'https://tickets.kokosai.jp/disclaimer',
                          context: context,
                        );
                      },
                      child: const Text(
                        '免責事項',
                        style: TextStyle(color: Color(0xFF6B8FD4)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final ValueNotifier<double> scrollOffsetNotifier = ValueNotifier(0.0);
  final Map<String, PerformanceData> _selectedPerformances = {};
  final List<PerformanceData> _allPerformances = [
    PerformanceData(
      classnumber: "304",
      title: 'KINGDOM',
      venue: '鯱光館',
      date: '9月27日（土）',
      time: '9:30~11:00',
      prText:
          '時は春秋戦国時代。下僕の少年と若き王の出会いが、中華の未来を動かす__\n命を懸けた戦い、仲間との絆。｢KINGDOM｣ここに開幕！',
    ),
    PerformanceData(
      classnumber: "305",
      title: '今日から俺は‼︎',
      venue: '武道場',
      date: '9月27日（土）',
      time: '9:30~11:00',
      prText: '「今日俺」待望の舞台化。ここ旭丘でもヤンキーたちが大暴れ！！！この夏、最大で最凶の闘いが今始まる！！！',
    ),
    PerformanceData(
      classnumber: "306",
      title: 'アナと雪の女王',
      venue: '小体育館',
      date: '9月27日（土）',
      time: '9:30~11:00',
      prText:
          '秘密の力を持った姉エルサと運命の恋を夢見る妹アナの姉妹が織りなす、アレンデール王国を巡る魔法と感動の物語。\n「少しも寒くない」この夏、小体育館で魔法にかかろう！',
    ),
    PerformanceData(
      classnumber: "303",
      title: 'RRR-Re:Ramayana×mahabhaRata',
      venue: '鯱光館',
      date: '9月27日（土）',
      time: '13:00~14:30',
      prText: '友情か使命か。全ての次元を越えた出逢いを繋ぐ、インド映画の最高峰。',
    ),
    PerformanceData(
      classnumber: "308",
      title: 'マクベス',
      venue: '小体育館',
      date: '9月27日（土）',
      time: '13:00~14:30',
      prText: '「いずれは王になるお方」魔女の予言が、心を惑わす。野望に憑かれた男の血と裏切りの運命。悲劇『マクベス』開演。',
    ),
    PerformanceData(
      classnumber: "309",
      title: 'デスノート',
      venue: '武道場',
      date: '9月27日（土）',
      time: '13:00~14:30',
      prText: '名前を書かれた人間は死ぬ——。圧倒的な頭脳を持つ二人が繰り広げる、命を懸けた壮絶な心理戦。果たして、本当の“正義”とは何か？',
    ),
    PerformanceData(
      classnumber: "301",
      title: '心が叫びたがってるんだ。',
      venue: '武道場',
      date: '9月28日（日）',
      time: '9:30~11:00',
      prText: '伝えたい想いがある。言葉にできない心の叫びが、静かに、けれど確かに響き合う、切なくも温かい青春の物語。',
    ),
    PerformanceData(
      classnumber: "302",
      title: 'オペラ座の怪人',
      venue: '鯱光館',
      date: '9月28日（日）',
      time: '9:30~11:00',
      prText: 'オペラ座に響く、届かぬ恋と運命の物語。仮面に隠した想いが、舞台で動き出す＿\n旭丘史上、最高の劇を見逃すな！',
    ),
    PerformanceData(
      classnumber: "307",
      title: 'LA LA LAND',
      venue: '小体育館',
      date: '9月28日（日）',
      time: '9:30~11:00',
      prText: 'ミュージカルの魔法があなたを包む\n極上のエンターテイメント\nようこそLA LA LANDの世界へ！',
    ),
  ];
  Map<String, List<PerformanceData>> get _groupedAndSortedPerformances {
    int getDateTimeSortKey(PerformanceData p) {
      final date = p.date.contains('土') ? '27' : '28';
      final timeParts = p.time.split('~')[0].split(':').map(int.parse).toList();
      return int.parse(
        '202509$date${timeParts[0].toString().padLeft(2, '0')}${timeParts[1].toString().padLeft(2, '0')}',
      );
    }
    _allPerformances.sort((a, b) {
      return getDateTimeSortKey(a).compareTo(getDateTimeSortKey(b));
    });
    final Map<String, List<PerformanceData>> groups = {};
    for (var performance in _allPerformances) {
      final key = '${performance.date} ${performance.time}';
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(performance);
    }
    return groups;
  }

  void _handleSelection(PerformanceData classNo, String timeSlot) {
    setState(() {
      if (_selectedPerformances.containsKey(timeSlot)) {
        if (_selectedPerformances[timeSlot] == classNo) {
          _selectedPerformances.remove(timeSlot);
        } else {
          _selectedPerformances[timeSlot] = classNo;
        }
      } else {
        if (_selectedPerformances.length < 3) {
          _selectedPerformances[timeSlot] = classNo;
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('3つまでしか選択できません。'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Widget performanceCard({
    required BuildContext context,
    required PerformanceData performance,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: GestureDetector(
        onTap: onSelected,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color(0xFF6B8FD4).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20), // 外側のコンテナの角丸
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(5, 5),
                blurRadius: 15,
              ),
            ],
            border: Border.all(
              color: isSelected ? const Color(0xFF6B8FD4) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9, // ここでアスペクト比を設定（例: 16:9）
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18), // 上部の角丸を外側のコンテナに合わせる
                    ),
                  ),
                  clipBehavior: Clip.antiAlias, // 角丸を適用するために追加
                  child: Image.asset(
                    "lib/assets/img/${performance.classnumber}.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ), // ここで内側の余白を少し追加
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      performance.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'クラス: ${performance.classnumber}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '上演場所: ${performance.venue}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '上演時間: ${performance.time}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      performance.prText,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isSelected
                                  ? const Color(0xFF90D490)
                                  : const Color(0xFF6B8FD4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        onPressed: onSelected,
                        child: Text(
                          isSelected ? '選択済み' : '選択する',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedAndSortedPerformances;
    return Scaffold(
      appBar: AppBar(
        title: const Text('チケットを予約', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6B8FD4),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFE0F4FF),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  '上演作品一覧',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ),
              ...grouped.entries.map((entry) {
                final timeSlot = entry.key;
                final performancesInSlot = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        top: 20.0,
                        bottom: 10.0,
                      ),
                      child: Text(
                        '開催時間帯：$timeSlot',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B8FD4),
                        ),
                      ),
                    ),
                    ...performancesInSlot.map((performance) {
                      final isSelected =
                          _selectedPerformances[timeSlot] == performance;
                      return performanceCard(
                        context: context,
                        performance: performance,
                        isSelected: isSelected,
                        onSelected:
                            () => _handleSelection(performance, timeSlot),
                      );
                    }),
                  ],
                );
              }),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedOpacity(
        opacity: _selectedPerformances.isNotEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: _selectedPerformances.isEmpty,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(
                255,
                213,
                228,
                255,
              ).withValues(alpha: 0.9),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(15.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => ConfirmationPage(
                        selectedPerformances:
                            _selectedPerformances.values.toList(),
                      ),
                ),
              );
            },
            child: const Text(
              '選択を確定する',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConfirmationPage extends StatelessWidget {
  final List<PerformanceData> selectedPerformances;
  const ConfirmationPage({super.key, required this.selectedPerformances});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('予約内容の確認', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6B8FD4),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFE0F4FF),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '以下の内容でよろしいですか？',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B8FD4),
              ),
            ),
            const SizedBox(height: 20),
            ...selectedPerformances.map(
              (data) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF90D490),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "${data.classnumber} ${data.title}",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // 戻るボタンと確定ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 予約ページに戻る
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    '戻る',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => EmailInputPage(
                              selectedPerformances: selectedPerformances,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8FD4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    '予約を確定する',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmailInputPage extends StatelessWidget {
  final List<PerformanceData> selectedPerformances;
  final TextEditingController _emailController = TextEditingController();
  EmailInputPage({required this.selectedPerformances, super.key});
  Future<void> addEmailToArray({
    required List<PerformanceData> classNos,
    required String email,
  }) async {
    final docRef = FirebaseFirestore.instance.doc("entries/data");
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() as Map<String, dynamic>;
      int totalOccurrences = 0;
      for (int i = 1; i <= 9; i++) {
        final key = "array$i";
        final List<dynamic> list = (data[key] ?? []) as List<dynamic>;
        totalOccurrences += list.where((e) => e == email).length;
      }
      if (totalOccurrences < 3) {
        for (var i in classNos) {
          final List<dynamic> targetArray = (data[i.classnumber] ?? []);
          if (!targetArray.contains(email)) {
            targetArray.add(email);
          }
          transaction.update(docRef, {i.classnumber: targetArray});
        }
        var buffer = StringBuffer();
        buffer.writeln(
          '鯱光祭チケットシステムをご利用いただきありがとうございます。\nチケット抽選の受付が完了しました。\n\n----------\n',
        );
        for (int i = 0; i < selectedPerformances.length; i++) {
          buffer.writeln(
            '発表名: ${selectedPerformances[i].classnumber} ${selectedPerformances[i].title}\n日時:　 ${selectedPerformances[i].date}${selectedPerformances[i].time} @${selectedPerformances[i].venue}\n',
          );
        }
        buffer.writeln(
          '----------\n\n抽選結果は後日、メールにてお知らせいたします。\n\n第77回鯱光祭「旭斗七星」\n愛知県立旭丘高等学校 三年劇舞台監督審議会\n\nこのメールに見覚えのない方は無視してください。',
        );
        String emailContent = buffer.toString();
        await FirebaseFirestore.instance.collection("ticketsMail").add({
          "to": [email],
          "message": {"subject": "鯱光祭チケット受付", "text": emailContent},
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メールアドレスの入力', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6B8FD4),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFE0F4FF),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0D4),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: const Color(0xFFD4B96B),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '⚠︎ ご注意',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4B96B),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '・ご入力いただいたメールアドレスに抽選結果をお知らせします。',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '・迷惑メール設定をされている方は、事前に「@kokosai.jp」からのメールを受信できるように設定してください。',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '・複数のアドレスを使用しての応募は無効となります。',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '予約内容をメールで送信します。',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B8FD4),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'メールアドレス',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final email = _emailController.text;
                    if (email.isNotEmpty && email.contains('@')) {
                      await addEmailToArray(
                        email: email,
                        classNos: selectedPerformances,
                      );
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookingCompletePage(),
                        ),
                        (route) => route.isFirst,
                      );
                    } else {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('有効なメールアドレスを入力してください。'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8FD4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    '予約を完了する',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingCompletePage extends StatelessWidget {
  const BookingCompletePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F4FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF90D490),
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                '予約が完了しました！',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B8FD4),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                '抽選結果は、ご入力いただいたメールアドレスに9/25に送信されます。',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                    (route) => false, // これまでのナビゲーション履歴をすべて破棄
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8FD4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'メインページに戻る',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}