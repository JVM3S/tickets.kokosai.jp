import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 背景要素は最初非表示にしてフェードインさせる
  bool _isVisible = false;
  bool _isCardVisible = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    // サイトを開いた直後にフェードインを開始
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  void _onScroll() {
    // スクロール位置が500.0を超えたら、新しいカードのアニメーションを開始
    if (_scrollController.offset > 100.0 && !_isCardVisible) {
      setState(() {
        _isCardVisible = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F4FF), // 背景色
      body: SingleChildScrollView(
        controller: _scrollController,
        // スクロールできるように高さを持たせる
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 2,
          child: Stack(
            children: [
              // アニメーションする円形の背景要素
              _buildAnimatedItem(
                bottom: 100,
                right: 30,
                duration: 1500,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 178, 222, 246),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              _buildAnimatedItem(
                top: 50,
                left: 50,
                duration: 800,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6B8FD4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              _buildAnimatedItem(
                top: 20,
                right: -10,
                duration: 1500,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 127, 183, 248),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              _buildAnimatedItem(
                top: 80,
                right: -10,
                duration: 1500,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 240, 244, 249),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              _buildAnimatedItem(
                bottom: 100,
                left: -50,
                duration: 1500,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Color(0xFF90D490),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              _buildAnimatedItem(
                top: 250,
                left: -150,
                duration: 1800,
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

              // アニメーションするテキスト
              _buildAnimatedTextItem(
                text: '鯱光祭',
                top: 100,
                left: 20,
                duration: 1500,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              _buildAnimatedTextItem(
                text: '三年劇チケット',
                top: 150,
                left: 20,
                duration: 1500,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              _buildAnimatedTextItem(
                text: '予約サイト',
                top: 200,
                left: 20,
                duration: 1500,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              _buildAnimatedTextItem(
                text: 'Asahigaoka Highschool',
                top: 250,
                left: 20,
                duration: 1800,
                style: const TextStyle(fontSize: 15, color: Colors.black38),
              ),
              _buildAnimatedTextItem(
                text: 'festival, KOKOSAI',
                top: 270,
                left: 20,
                duration: 1800,
                style: const TextStyle(fontSize: 15, color: Colors.black38),
              ),
              _buildAnimatedTextItem(
                text: 'third grade theater',
                top: 290,
                left: 20,
                duration: 1800,
                style: const TextStyle(fontSize: 15, color: Colors.black38),
              ),
              _buildAnimatedTextItem(
                text: 'ticket formal website',
                top: 310,
                left: 20,
                duration: 1800,
                style: const TextStyle(fontSize: 15, color: Colors.black38),
              ),

              // 新しく追加した半透明のカード
              _buildAnimatedCardItem(
                top: 400, // スクロールして表示される位置
                duration: 1200,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.airplane_ticket,
                        size: 40,
                        color: Color(0xFF6B8FD4),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '三年劇チケット予約について',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'あいうえおあいうえお',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'こちらから予約する劇を選択してください',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // _buildAnimatedCardItem(
              //   top: 550, // スクロールして表示される位置
              //   duration: 1200,
              //   child: Padding(
              //     padding: const EdgeInsets.all(20.0),
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         const Icon(
              //           Icons.airplane_ticket,
              //           size: 40,
              //           color: Color(0xFF6B8FD4),
              //         ),
              //         const SizedBox(height: 10),
              //         Text(
              //           'チケットの予約はこちらから',
              //           style: TextStyle(
              //             fontSize: 20,
              //             fontWeight: FontWeight.bold,
              //             color: Colors.black.withOpacity(0.8),
              //           ),
              //         ),
              //         const SizedBox(height: 5),
              //         Text(
              //           'スクロールすると表示されるカードです。',
              //           style: TextStyle(
              //             fontSize: 14,
              //             color: Colors.black.withOpacity(0.6),
              //           ),
              //           textAlign: TextAlign.center,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // アニメーションする円形要素をビルドするヘルパーメソッド
  Widget _buildAnimatedItem({
    required Widget child,
    required int duration,
    double? top,
    double? left,
    double? right,
    double? bottom,
  }) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: duration),
      curve: Curves.easeOut,
      top: _isVisible ? top : (top != null ? top + 50 : null),
      left: _isVisible ? left : (left != null ? left - 50 : null),
      right: _isVisible ? right : (right != null ? right - 50 : null),
      bottom: _isVisible ? bottom : (bottom != null ? bottom - 50 : null),
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: Duration(milliseconds: duration),
        curve: Curves.easeIn,
        child: child,
      ),
    );
  }

  // アニメーションするテキストをビルドするヘルパーメソッド
  Widget _buildAnimatedTextItem({
    required String text,
    required int duration,
    required double top,
    required double left,
    TextStyle? style,
  }) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: duration),
      curve: Curves.easeOut,
      top: _isVisible ? top : top + 20,
      left: _isVisible ? left : left - 20,
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: Duration(milliseconds: duration),
        curve: Curves.easeIn,
        child: Text(text, style: style),
      ),
    );
  }

  // 新しいアニメーションするカードをビルドするヘルパーメソッド
  Widget _buildAnimatedCardItem({
    required Widget child,
    required int duration,
    required double top,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AnimatedPositioned(
      duration: Duration(milliseconds: duration),
      curve: Curves.easeOut,
      top: _isCardVisible ? top : top + 50,
      left: _isCardVisible ? screenWidth * 0.1 : screenWidth * 0.3, // 左からスライド
      child: AnimatedOpacity(
        opacity: _isCardVisible ? 1.0 : 0.0,
        duration: Duration(milliseconds: duration),
        curve: Curves.easeIn,
        child: Container(
          width: screenWidth * 0.8, // 画面幅の80%
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8), // 半透明の白色
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(5, 5),
                blurRadius: 15,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
