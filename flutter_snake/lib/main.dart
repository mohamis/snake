import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

class NotAvailableScreen extends StatelessWidget {
  const NotAvailableScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Not Available'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sorry, this app is not available on the current platform.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData.dark(),
      home: _isPlatformSupported()
          ? const SnakeGame()
          : const NotAvailableScreen(),
    );
  }

  bool _isPlatformSupported() {
    // Check for unsupported platforms (macOS, Windows, Web)
    return !kIsWeb &&
        !Platform.isMacOS &&
        !Platform.isWindows &&
        !Platform.isLinux;
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  SnakeGameState createState() => SnakeGameState();
}

class SnakeGameState extends State<SnakeGame>
    with SingleTickerProviderStateMixin {
  static const int gridSize = 20;
  static const int initialSnakeLength = 5;

  List<Point<int>> snake = [];
  late Point<int> food;

  Direction direction = Direction.right;
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    resetGame();
    _ticker = createTicker((_) => onTick());
    startGameLoop();
  }

  void startGameLoop() {
    const gameSpeed = Duration(milliseconds: 100); // Adjust the speed here
    Timer.periodic(gameSpeed, (timer) {
      if (mounted) {
        moveSnake();
        setState(() {});
      } else {
        timer.cancel(); // Stop the timer if the widget is no longer mounted
      }
    });
  }

  void onTick() {
    // This method is no longer needed
  }

  void resetGame() {
    snake.clear();
    for (int i = 0; i < initialSnakeLength; i++) {
      snake.add(Point<int>(i, 0));
    }
    direction = Direction.right;
    food = generateFixedFood(); // Use the new method for fixed food position
  }

  Point<int> generateFixedFood() {
    // Set a fixed position for the food, for example, at the center of the grid
    return const Point<int>(gridSize ~/ 2, gridSize ~/ 2);
  }

  void moveSnake() {
    final head = snake.first;
    Point<int> newHead;

    switch (direction) {
      case Direction.up:
        newHead = Point(head.x, (head.y - 1 + gridSize) % gridSize);
        break;
      case Direction.down:
        newHead = Point(head.x, (head.y + 1) % gridSize);
        break;
      case Direction.left:
        newHead = Point((head.x - 1 + gridSize) % gridSize, head.y);
        break;
      case Direction.right:
        newHead = Point((head.x + 1) % gridSize, head.y);
        break;
    }

    if (snake.contains(newHead)) {
      resetGame();
    } else {
      snake.insert(0, newHead);
      if (newHead == food) {
        food = generateFood();
      } else {
        snake.removeLast();
      }
    }
  }

  Point<int> generateFood() {
    final random = Random();
    Point<int> newFood;

    do {
      newFood = Point<int>(random.nextInt(gridSize), random.nextInt(gridSize));
    } while (snake.contains(newFood));

    return newFood;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 6, // 60% of the available space
            child: SnakeGrid(
              gridSize: gridSize,
              snake: snake,
              food: food,
            ),
          ),
          Expanded(
            flex: 4, // 40% of the available space
            child: Container(
              color: Colors.amber,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ArcadeButton(
                        icon: Icons.arrow_upward,
                        onPressed: () {
                          setState(() {
                            direction = Direction.up;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ArcadeButton(
                        icon: Icons.arrow_back,
                        onPressed: () {
                          setState(() {
                            direction = Direction.left;
                          });
                        },
                      ),
                      const SizedBox(width: 90),
                      ArcadeButton(
                        icon: Icons.arrow_forward,
                        onPressed: () {
                          setState(() {
                            direction = Direction.right;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ArcadeButton(
                        icon: Icons.arrow_downward,
                        onPressed: () {
                          setState(() {
                            direction = Direction.down;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

class SnakeGrid extends StatelessWidget {
  const SnakeGrid({
    Key? key,
    required this.gridSize,
    required this.snake,
    required this.food,
  }) : super(key: key);

  final int gridSize;
  final List<Point<int>> snake;
  final Point<int> food;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: GridView.builder(
        itemCount: gridSize * gridSize,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
        ),
        itemBuilder: (BuildContext context, int index) {
          final point = Point<int>(index % gridSize, index ~/ gridSize);
          return drawCell(point);
        },
      ),
    );
  }

  Widget drawCell(Point<int> point) {
    if (snake.contains(point)) {
      return SnakeCell(isHead: point == snake.first);
    } else if (point == food) {
      return const FoodCell();
    } else {
      return const EmptyCell();
    }
  }
}

class ArcadeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const ArcadeButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green, // Customize the background color
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 70, // Adjust the icon size as needed
          color: Colors.amberAccent, // Customize the icon color
        ),
      ),
    );
  }
}

class SnakeCell extends StatelessWidget {
  final bool isHead;

  const SnakeCell({super.key, required this.isHead});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isHead
            ? Colors.blue
            : Colors.green, // Set a different color for the head
      ),
    );
  }
}

class FoodCell extends StatelessWidget {
  const FoodCell({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}

class EmptyCell extends StatelessWidget {
  const EmptyCell({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

enum Direction { up, down, left, right }
