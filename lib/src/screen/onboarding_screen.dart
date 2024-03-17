import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {

  final PageController _controller = PageController();

  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: const [
              Page1(),
              Page2(),
              Page3()
            ],

          ),

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              alignment: const Alignment(-0.95, 0.85),
                  child: Row(
                    children: [

                      SmoothPageIndicator(
                        controller: _controller,
                        count: 3,
                        effect: const ExpandingDotsEffect(
                          expansionFactor: 6,
                          dotColor: Colors.grey,
                          activeDotColor: Colors.white

                        )
                      ),


                      const Spacer(),

                      onLastPage
                      ? ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/dashboardScreen', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                          foregroundColor: Colors.orange, // Background color
                        ),
                        child: const Icon(
                          Icons.keyboard_double_arrow_right,
                          color: Colors.white, // Icon color
                          size: 32, // Icon size
                        ),
                      ) : ElevatedButton(
                        onPressed: () {
                          _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                          foregroundColor: const Color.fromARGB(255, 239, 127, 26), // Background color
                        ),
                        child: const Icon(
                          Icons.keyboard_double_arrow_right,
                          color: Colors.white, // Icon color
                          size: 32, // Icon size
                        ),
                      ),

                    ],
                  )
              ),
          ),

        ],
      )
    );
  }
}

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/step1.png'), fit: BoxFit.cover)
            ),
          ),

          const Positioned.fill(
            child: FractionalTranslation(
              translation: Offset(0, 0.55), // Translate the Column by half of its height
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'მოგესალმებით\n',
                            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: 'HotCard',
                            style: TextStyle(color: Color.fromARGB(255, 239, 127, 26), fontSize: 30, fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: '-ის მობილურ\nაპლიკაციაში',
                            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'აპლიკაციის გამოსაყენებლად მიყევით\nშემდეგ ნაბიჯებს',
                      style: TextStyle(color: Colors.grey, fontSize: 17),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/images/step2.png'), fit: BoxFit.cover)
            ),
          ),

          const Positioned.fill(
            child: FractionalTranslation(
              translation: Offset(0, 0.52), // Translate the Column by half of its height
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'გადადით',
                            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: ' "ჩემ\nბარათში"',
                            style: TextStyle(color: Color.fromARGB(255, 239, 127, 26), fontSize: 30, fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: ' და\nგააქტიურეთ ბარათი',
                            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text('დაათვალიერეთ და აარჩიეთ თქვენთვის\nსასურველი ობიექტი', style: TextStyle(color: Colors.grey, fontSize: 17),)
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

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/images/step3.png'), fit: BoxFit.cover)
            ),
          ),

          const Positioned.fill(
            child: FractionalTranslation(
              translation: Offset(0, 0.55), // Translate the Column by half of its height
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'ბარათის გააქტიურების\n',
                            style: TextStyle(color: Color.fromARGB(255, 239, 127, 26), fontSize: 27.5, fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: 'შემდეგ აირჩიეთ\nპროდუქტი შესაძენად\nდა მიიღეთ ',
                            style: TextStyle(color: Colors.white, fontSize: 27.5, fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: '1+1\n',
                            style: TextStyle(color: Color.fromARGB(255, 239, 127, 26), fontSize: 27.5, fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: 'საჩუქრები',
                            style: TextStyle(color: Colors.white, fontSize: 27.5, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                 //   SizedBox(height: 10,),
                  //  Text('აპლიკაციის გამოსაყენებლად მიყევით\nშემდეგ ნაბიჯებს', style: TextStyle(color: Colors.grey, fontSize: 17),)
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

