import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tickets_kokosai_jp/firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  // main関数を非同期に変更
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
      // ロケール設定
      debugShowCheckedModeBanner: false,
      supportedLocales: [Locale('ja', 'JP')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        fontFamily: 'NotoSansJP', // ← pubspec.yamlで設定したフォント名を指定
      ),
      // アプリのロケールを明示的に指定
      locale: Locale("ja", "JP"),
    );
  }
}

// メインページ用のカードデータ
class CardData {
  final String title;
  final String body;
  final String? subText;
  final String? subText2;
  final String buttonText;
  final IconData icon;

  final VoidCallback? onButtonPressed;

  CardData({
    required this.title,
    required this.body,
    this.subText,
    this.subText2,
    required this.buttonText,
    required this.icon,
    this.onButtonPressed,
  });
}

// 予約ページ用の作品データ
class PerformanceData {
  final String title;
  final String venue;
  final String date;
  final String time;
  final String prText;
  final Color photoColor; //
  final String classnumber;
  final String extension;

  PerformanceData({
    required this.title,
    required this.venue,
    required this.date,
    required this.time,
    required this.prText,
    required this.photoColor,
    required this.classnumber,
    required this.extension,
  });
}

class UrlLauncherUtil {
  /// 指定されたURLを起動します。
  /// 起動できない場合は、`SnackBar`でエラーメッセージを表示します。
  static Future<void> launch({
    required String url,
    required BuildContext context,
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    final Uri uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      if (context.mounted) {
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
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> scrollOffsetNotifier = ValueNotifier(0.0);
  bool _shouldAnimateIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 初期アニメーションをトリガー
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

  // ページの再表示を検知
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // アプリがフォアグラウンドに戻ったときに実行
      _resetStateAndScroll();
    }
  }

  void _resetStateAndScroll() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
    setState(() {
      _shouldAnimateIn = false;
    });
    // アニメーションを再実行
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _shouldAnimateIn = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<CardData> cards = [
      CardData(
        title: '三年劇チケット予約について',
        body:
            '劇の予約は一人につき三本まで可能です。ただし同時刻帯の劇は一本しか予約できません。抽選結果は9/25にメールでお知らせします。また、メールアドレスの多使用による予約はご遠慮ください。',
        subText: '予約は抽選制です',
        subText2: '募集締め切り＆抽選は9/25です',
        buttonText: '予約フォームはこちら',
        icon: Icons.airplane_ticket,
        onButtonPressed: () {
          // 横にスライドする画面遷移を実装
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const TicketPage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                // 右から左へスライドするアニメーションを定義
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                final tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
      ),
      CardData(
        title: 'お問い合わせ',
        body: 'ご不明な点がありましたら、こちらのフォームでお問い合わせください。返信には多少時間がかかりますがご了承ください',
        buttonText: "お問い合わせフォームはこちら",
        icon: Icons.contact_mail,
        onButtonPressed: () {
          UrlLauncherUtil.launch(
            url: 'https://tickets.kokosai.jp/contact',
            context: context,
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE0F4FF),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: _InitialContent(isVisible: _shouldAnimateIn),
            ),
            ...List.generate(cards.length, (index) {
              final cardData = cards[index];
              final cardOffset =
                  MediaQuery.of(context).size.height + (index * 200);
              return ValueListenableBuilder<double>(
                valueListenable: scrollOffsetNotifier,
                builder: (context, offset, child) {
                  final isCardVisible =
                      offset >
                      cardOffset - MediaQuery.of(context).size.height * 0.7;
                  return _AnimatedCardItem(
                    isVisible: isCardVisible,
                    child: _MainCard(cardData: cardData),
                  );
                },
              );
            }),
            const SizedBox(height: 50),
            Padding(
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
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

// メインページのカードを構築する新しいウィジェット
class _MainCard extends StatelessWidget {
  final CardData cardData;

  const _MainCard({required this.cardData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(5, 5),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(cardData.icon, size: 30, color: const Color(0xFF6B8FD4)),
          Text(
            cardData.title,
            style: TextStyle(
              fontSize: 25,
              fontFamily: FlutterVersion.version,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 10),
          if (cardData.subText != null)
            Text(
              cardData.subText!,
              style: TextStyle(
                fontSize: 25,
                color: const Color.fromARGB(255, 255, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
          if (cardData.subText2 != null)
            Text(
              cardData.subText2!,
              style: TextStyle(
                fontSize: 25,
                color: const Color.fromARGB(255, 255, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 15),
          Text(
            cardData.body,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          if (cardData.onButtonPressed != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8FD4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                onPressed: cardData.onButtonPressed,
                child: Text(
                  cardData.buttonText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
          SizedBox(height: 5),
          if (cardData.title == '三年劇チケット予約について')
            TextButton(
              onPressed: () {
                UrlLauncherUtil.launch(
                  url: 'https://www.google.com',
                  context: context,
                );
              },
              child: Text("その他の予約に関する説明はこちらから"),
            ),
        ],
      ),
    );
  }
}

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final ValueNotifier<double> scrollOffsetNotifier = ValueNotifier(0.0);

  // 選択された作品を「時間帯」と「作品名」で管理するマップに変更
  final Map<String, String> _selectedPerformances = {};

  // 予約ページ用の作品データ
  final List<PerformanceData> _allPerformances = [
    PerformanceData(
      classnumber: "304",
      title: 'KINGDOM',
      venue: '鯱光館',
      date: '9月27日（土）',
      time: '9:30~11:00',
      prText:
          '時は春秋戦国時代。下僕の少年と若き王の出会いが、中華の未来を動かす__\n命を懸けた戦い、仲間との絆。｢KINGDOM｣ここに開幕！',
      photoColor: const Color(0xFFD4B96B).withOpacity(0.8),
      extension: ".jpeg",
    ),
    PerformanceData(
      classnumber: "305",
      title: '今日から俺は‼︎',
      venue: '武道場',
      date: '9月27日（土）',
      time: '9:30~11:00',
      prText: '「今日俺」待望の舞台化。ここ旭丘でもヤンキーたちが大暴れ！！！この夏、最大で最凶の闘いが今始まる！！！',
      photoColor: const Color(0xFFD46B6B).withOpacity(0.8),
      extension: ".png",
    ),
    PerformanceData(
      classnumber: "306",
      title: 'アナと雪の女王',
      venue: '小体育館',
      date: '9月27日（土）',
      time: '9:30~11:00',
      prText:
          '秘密の力を持った姉エルサと運命の恋を夢見る妹アナの姉妹が織りなす、アレンデール王国を巡る魔法と感動の物語。\n「少しも寒くない」この夏、小体育館で魔法にかかろう！',
      photoColor: const Color(0xFF6BD4D4).withOpacity(0.8),
      extension: ".png",
    ),
    PerformanceData(
      classnumber: "303",
      title: 'RRR-Re:Ramayana×mahabhaRata',
      venue: '鯱光館',
      date: '9月27日（土）',
      time: '13:00~14:30',
      prText: '友情か使命か。全ての次元を越えた出逢いを繋ぐ、インド映画の最高峰。',
      photoColor: const Color(0xFFC498D4).withOpacity(0.8),
      extension: ".png",
    ),
    PerformanceData(
      classnumber: "308",
      title: 'マクベス',
      venue: '小体育館',
      date: '9月27日（土）',
      time: '13:00~14:30',
      prText: '「いずれは王になるお方」魔女の予言が、心を惑わす。野望に憑かれた男の血と裏切りの運命。悲劇『マクベス』開演。',
      photoColor: const Color(0xFF6B8FD4).withOpacity(0.8),
      extension: ".png",
    ),
    PerformanceData(
      classnumber: "309",
      title: 'デスノート',
      venue: '武道場',
      date: '9月27日（土）',
      time: '13:00~14:30',
      prText: '名前を書かれた人間は死ぬ——。圧倒的な頭脳を持つ二人が繰り広げる、命を懸けた壮絶な心理戦。果たして、本当の“正義”とは何か？',
      photoColor: const Color(0xFF90D490).withOpacity(0.8),
      extension: ".png",
    ),
    PerformanceData(
      classnumber: "301",
      title: '心が叫びたがってるんだ。',
      venue: '武道場',
      date: '9月28日（日）',
      time: '9:30~11:00',
      prText: '伝えたい想いがある。言葉にできない心の叫びが、静かに、けれど確かに響き合う、切なくも温かい青春の物語。',
      photoColor: const Color(0xFF6B8FD4).withOpacity(0.8),
      extension: ".jpg",
    ),
    PerformanceData(
      classnumber: "302",
      title: 'オペラ座の怪人',
      venue: '鯱光館',
      date: '9月28日（日）',
      time: '9:30~11:00',
      prText: 'オペラ座に響く、届かぬ恋と運命の物語。仮面に隠した想いが、舞台で動き出す＿\n旭丘史上、最高の劇を見逃すな！',
      photoColor: const Color(0xFF90D490).withOpacity(0.8),
      extension: ".jpg",
    ),
    PerformanceData(
      classnumber: "307",
      title: 'LA LA LAND',
      venue: '小体育館',
      date: '9月28日（日）',
      time: '9:30~11:00',
      prText: 'ミュージカルの魔法があなたを包む\n極上のエンターテイメント\nようこそLA LA LANDの世界へ！',
      photoColor: const Color(0xFFD46BB9).withOpacity(0.8),
      extension: ".JPG",
    ),
  ];

  // 時間帯ごとに作品をグループ化し、時系列でソートする
  Map<String, List<PerformanceData>> get _groupedAndSortedPerformances {
    // 日付と時間を表す文字列からDateTimeオブジェクトを作成
    int _getDateTimeSortKey(PerformanceData p) {
      final date = p.date.contains('土') ? '27' : '28';
      final timeParts = p.time.split('~')[0].split(':').map(int.parse).toList();
      return int.parse(
        '202509$date${timeParts[0].toString().padLeft(2, '0')}${timeParts[1].toString().padLeft(2, '0')}',
      );
    }

    _allPerformances.sort((a, b) {
      return _getDateTimeSortKey(a).compareTo(_getDateTimeSortKey(b));
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

  void _handleSelection(String title, String timeSlot) {
    setState(() {
      // 同じ時間帯で既に選択されている作品があるか確認
      if (_selectedPerformances.containsKey(timeSlot)) {
        // 同じ作品を再度選択した場合、選択を解除
        if (_selectedPerformances[timeSlot] == title) {
          _selectedPerformances.remove(timeSlot);
        } else {
          // 違う作品を選択した場合、上書きする
          _selectedPerformances[timeSlot] = title;
        }
      } else {
        // 選択数が3つ未満か確認
        if (_selectedPerformances.length < 3) {
          _selectedPerformances[timeSlot] = title;
        } else {
          // 3つ以上選択できないことをユーザーに通知
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
                    color: Colors.black.withOpacity(0.7),
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
                      // 選択済みかどうかの判定をマップを使って変更
                      final isSelected =
                          _selectedPerformances[timeSlot] == performance.title;
                      return _PerformanceCard(
                        performance: performance,
                        isSelected: isSelected,
                        onSelected:
                            () => _handleSelection(performance.title, timeSlot),
                      );
                    }).toList(),
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
              ).withOpacity(0.9),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(15.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            onPressed: () {
              // 確認ページに遷移
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          _ConfirmationPage(
                            selectedPerformances:
                                _selectedPerformances.values.toList(),
                          ),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;
                    final tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
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

// 選択内容を確認する新しいページ
class _ConfirmationPage extends StatelessWidget {
  final List<String> selectedPerformances;

  const _ConfirmationPage({required this.selectedPerformances});

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
            // 選択された作品を一覧で表示
            ...selectedPerformances.map(
              (title) => Padding(
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
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black.withOpacity(0.8),
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
                    // 予約確定ボタンを押したらメールアドレス入力画面へ遷移
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                EmailInputPage(
                                  selectedPerformances: selectedPerformances,
                                ),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          final tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
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

// メールアドレス入力画面
class EmailInputPage extends StatelessWidget {
  final List<String> selectedPerformances;
  final TextEditingController _emailController = TextEditingController();

  EmailInputPage({required this.selectedPerformances, super.key});

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
              // 注意点を示す欄
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
                      '⚠︎ 注意',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4B96B),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'まだ予約は完了していません',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(221, 255, 2, 2),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '・ご入力いただいたメールアドレスに抽選結果をお知らせします。',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '・迷惑メール設定をされている方は、事前に「...」からのメールを受信できるように設定してください。',
                      // TODO
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
              const SizedBox(height: 30),
              // プライバシーポリシーと免責事項のボタンを配置
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      UrlLauncherUtil.launch(
                        url: 'https://tickets.kokosai.jp/privacy',
                        context: context,
                      );
                      // プライバシーポリシーの表示処理
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
                      // 免責事項の表示処理
                    },
                    child: const Text(
                      '免責事項',
                      style: TextStyle(color: Color(0xFF6B8FD4)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final email = _emailController.text;
                    if (email.isNotEmpty && email.contains('@')) {
                      await FirebaseFirestore.instance
                          .collection("ticketsMail")
                          .add({
                            "to": [email],
                            "message": {
                              "subject": "鯱光祭チケット抽選予約完了のお知らせ",
                              "text":
                                  "旭丘高校鯱光祭三年劇の抽選予約誠にありがとうございます。結果につきましては再度9/25に送信いたします。また、万が一抽選に外れましても、一部当日席がありますので、ぜひお越しください。",
                            },
                          });
                      // スナックバーの代わりに予約完了ページに遷移
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const _BookingCompletePage(),
                        ),
                        (route) => route.isFirst,
                      );
                    } else {
                      // メールアドレスが無効な場合の通知
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

// 作品情報を表示するカードウィジェット
class _PerformanceCard extends StatelessWidget {
  final PerformanceData performance;
  final bool isSelected;
  final VoidCallback onSelected;

  const _PerformanceCard({
    required this.performance,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: GestureDetector(
        onTap: onSelected,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color(0xFF6B8FD4).withOpacity(0.2)
                    : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20), // 外側のコンテナの角丸
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
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
              // 宣伝写真の代わりのプレースホルダー
              AspectRatio(
                aspectRatio: 16 / 9, // ここでアスペクト比を設定（例: 16:9）
                child: Container(
                  decoration: BoxDecoration(
                    color: performance.photoColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18), // 上部の角丸を外側のコンテナに合わせる
                    ),
                  ),
                  clipBehavior: Clip.antiAlias, // 角丸を適用するために追加
                  child: Image.asset(
                    "docs/assets/png/${performance.classnumber}${performance.extension}",
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
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'クラス: ${performance.classnumber}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '上演場所: ${performance.venue}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '上演時間: ${performance.time}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      performance.prText,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.7),
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
}

// 予約完了ページ
class _BookingCompletePage extends StatelessWidget {
  const _BookingCompletePage({super.key});

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
                  // メインページに戻る
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

class _InitialContent extends StatefulWidget {
  final bool isVisible;

  const _InitialContent({required this.isVisible});

  @override
  __InitialContentState createState() => __InitialContentState();
}

class __InitialContentState extends State<_InitialContent> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _AnimatedItem(
          isVisible: widget.isVisible,
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

        _AnimatedItem(
          isVisible: widget.isVisible,
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
        _AnimatedItem(
          isVisible: widget.isVisible,
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
        _AnimatedItem(
          isVisible: widget.isVisible,
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
        _AnimatedItem(
          isVisible: widget.isVisible,
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
        _AnimatedItem(
          isVisible: widget.isVisible,
          duration: 1800,
          top: 250,
          left: -150,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6B8FD4), width: 30),
            ),
            child: const Center(
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Color(0xFF6B8FD4),
              ),
            ),
          ),
        ),
        _AnimatedTextItem(
          isVisible: widget.isVisible,
          text: '鯱光祭',
          duration: 1500,
          top: 100,
          left: 20,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        _AnimatedTextItem(
          isVisible: widget.isVisible,
          text: '三年劇チケット',
          duration: 1500,
          top: 150,
          left: 20,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        _AnimatedTextItem(
          isVisible: widget.isVisible,
          text: '予約サイト',
          duration: 1500,
          top: 200,
          left: 20,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        _AnimatedTextItem(
          isVisible: widget.isVisible,
          text: 'Asahigaoka Highschool',
          duration: 1800,
          top: 250,
          left: 20,
          style: const TextStyle(fontSize: 15, color: Colors.black38),
        ),
        _AnimatedTextItem(
          isVisible: widget.isVisible,
          text: 'festival, KOKOSAI',
          duration: 1800,
          top: 270,
          left: 20,
          style: const TextStyle(fontSize: 15, color: Colors.black38),
        ),
        _AnimatedTextItem(
          isVisible: widget.isVisible,
          text: 'third grade theater',
          duration: 1800,
          top: 290,
          left: 20,
          style: const TextStyle(fontSize: 15, color: Colors.black38),
        ),
        _AnimatedTextItem(
          isVisible: widget.isVisible,
          text: 'ticket formal website',
          duration: 1800,
          top: 310,
          left: 20,
          style: const TextStyle(fontSize: 15, color: Colors.black38),
        ),
      ],
    );
  }
}

class _AnimatedItem extends StatelessWidget {
  final Widget child;
  final int duration;
  final bool isVisible;
  final double? top, left, right, bottom;

  const _AnimatedItem({
    required this.child,
    required this.duration,
    required this.isVisible,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: duration),
      curve: Curves.easeOut,
      top: isVisible ? top : (top != null ? top! + 50 : null),
      left: isVisible ? left : (left != null ? left! - 50 : null),
      right: isVisible ? right : (right != null ? right! - 50 : null),
      bottom: isVisible ? bottom : (bottom != null ? bottom! - 50 : null),
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: Duration(milliseconds: duration),
        curve: Curves.easeIn,
        child: child,
      ),
    );
  }
}

class _AnimatedTextItem extends StatelessWidget {
  final String text;
  final int duration;
  final bool isVisible;
  final double top, left;
  final TextStyle? style;

  const _AnimatedTextItem({
    required this.text,
    required this.duration,
    required this.isVisible,
    required this.top,
    required this.left,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _AnimatedCardItem extends StatelessWidget {
  final bool isVisible;
  final Widget child;

  const _AnimatedCardItem({required this.isVisible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeIn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, isVisible ? 0 : 50, 0),
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: child),
      ),
    );
  }
}
