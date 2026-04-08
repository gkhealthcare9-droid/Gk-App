// import 'package:flutter/material.dart';
// import '../Widgets/CustomBottomNav.dart';
//
// class BottomNavExample extends StatefulWidget {
//   const BottomNavExample({super.key});
//
//   @override
//   State<BottomNavExample> createState() => _BottomNavExampleState();
// }
//
// class _BottomNavExampleState extends State<BottomNavExample> {
//   int _currentIndex = 0;
//
//   final List<Widget> _pages = const [
//     DummyScreen(title: 'Home Screen'),
//     DummyScreen(title: 'Shop Screen'),
//     DummyScreen(title: 'Favorites Screen'),
//     DummyScreen(title: 'Profile Screen'),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_currentIndex],
//       bottomNavigationBar: CustomBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }
//
// class DummyScreen extends StatelessWidget {
//   final String title;
//   const DummyScreen({super.key, required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }