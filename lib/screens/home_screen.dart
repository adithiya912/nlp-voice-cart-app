import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../providers/cart_provider.dart';
import '../services/command_parser.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechToText _speechToText = SpeechToText();
  final TextEditingController _textController = TextEditingController();

  bool _speechEnabled = false;
  bool _isListening = false;
  String _recognizedText = '';
  String _statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadData();
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) => _handleError(error.errorMsg),
        onStatus: (status) => _updateStatus(status),
      );

      setState(() {
        _statusMessage = _speechEnabled
            ? 'Ready to listen...'
            : 'Speech not available';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing speech: $e';
      });
    }
  }

  void _handleError(String errorMsg) {
    setState(() {
      _statusMessage = 'Error: $errorMsg';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $errorMsg'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _updateStatus(String status) {
    setState(() {
      _statusMessage = status;
    });
  }

  void _loadData() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.loadProducts();
      await cartProvider.loadCartItems();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  void _startListening() async {

    if (!_speechEnabled) {
      setState(() {
        _statusMessage = 'Speech not available';
      });
      return;
    }

    try {
      // Clear previous text
      setState(() {
        _recognizedText = '';
        _textController.clear();
      });

      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: 'en_US',
        listenFor: const Duration(seconds: 30),
        cancelOnError: true,
        partialResults: true,
      );

      setState(() {
        _isListening = true;
        _statusMessage = 'Listening... Speak now';
      });
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = 'Error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start listening: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _stopListening() async {
    try {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
        _statusMessage = 'Processing your command...';
      });

      // Process the recognized text if any
      if (_recognizedText.isNotEmpty) {
        _processCommand(_recognizedText);
      }
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = 'Error stopping: $e';
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedText = result.recognizedWords;
      _textController.text = _recognizedText;
    });

    if (result.finalResult) {
      // Automatically process when final result is ready
      _processCommand(_recognizedText);
    }
  }

  void _processCommand(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _statusMessage = 'Processing: "$text"';
    });

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final commandResult = CommandParser.parseCommand(text);

      bool success = false;
      String message = commandResult.message;

      switch (commandResult.action) {
        case 'add':
          success = await cartProvider.addToCart(
              commandResult.productName,
              commandResult.quantity
          );
          if (!success) {
            message = 'Product "${commandResult.productName}" not found';
          }
          break;

        case 'remove':
          success = await cartProvider.removeFromCart(
              commandResult.productName,
              commandResult.quantity
          );
          if (!success) {
            message = 'Product "${commandResult.productName}" not found in cart';
          }
          break;

        case 'show':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          );
          message = 'Opening cart...';
          success = true;
          break;

        default:
          message = 'Could not understand: "$text"';
          break;
      }

      // Show result to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing command: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset after processing
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _textController.clear();
            _recognizedText = '';
            _statusMessage = 'Ready to listen...';
          });
        }
      });
    }
  }

  void _processTextInput() {
    if (_textController.text.isNotEmpty) {
      _processCommand(_textController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('Voice Cart App'),
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                  if (cartProvider.totalItems > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.totalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 48,
                      color: _isListening ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Text Input Card
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Type or speak your command:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            hintText: 'e.g., "add 3 pens", "remove 2 notebooks", "show cart"',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(16),
                          ),
                          style: const TextStyle(fontSize: 18),
                          textAlignVertical: TextAlignVertical.top,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _processTextInput,
                        icon: const Icon(Icons.send),
                        label: const Text('Process Command'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Voice Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _speechEnabled && !_isListening ? _startListening : null,
                  icon: const Icon(Icons.mic),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isListening ? _stopListening : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Instructions Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Commands:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• "Add 3 pens" - Add items to cart'),
                    const Text('• "Remove 2 notebooks" - Remove items'),
                    const Text('• "Show cart" - View cart contents'),
                    const Text('• "Delete all pens" - Remove all of an item'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}