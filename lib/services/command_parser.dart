import 'package:string_similarity/string_similarity.dart';

class CommandParser {
  static const List<String> addKeywords = [
    'add', 'include', 'put', 'insert', 'place'
  ];

  static const List<String> removeKeywords = [
    'remove', 'delete', 'take', 'eliminate', 'clear'
  ];

  static const List<String> showKeywords = [
    'show', 'display', 'list', 'view', 'cart'
  ];

  static const List<String> productNames = [
    'pen', 'pencil', 'notebook', 'eraser', 'ruler',
    'marker', 'highlighter', 'stapler', 'calculator', 'scissors',
    'glue stick', 'paper clips', 'rubber band', 'folder', 'binder',
    'sticky notes', 'tape', 'correction fluid', 'compass', 'protractor'
  ];

  static const Map<String, List<String>> numberWords = {
    'one': ['1', 'a', 'an'],
    'two': ['2'],
    'three': ['3'],
    'four': ['4'],
    'five': ['5'],
    'six': ['6'],
    'seven': ['7'],
    'eight': ['8'],
    'nine': ['9'],
    'ten': ['10'],
  };

  static CommandResult parseCommand(String text) {
    text = text.toLowerCase().trim();

    // Determine action
    String action = _determineAction(text);

    if (action == 'unknown') {
      return CommandResult(
        action: 'unknown',
        productName: '',
        quantity: 0,
        message: 'Could not understand the command',
      );
    }

    if (action == 'show') {
      return CommandResult(
        action: 'show',
        productName: '',
        quantity: 0,
        message: 'Showing cart',
      );
    }

    // Extract quantity
    int quantity = _extractQuantity(text);

    // Extract product name
    String productName = _extractProductName(text);

    if (productName.isEmpty) {
      return CommandResult(
        action: 'unknown',
        productName: '',
        quantity: 0,
        message: 'Could not identify the product',
      );
    }

    return CommandResult(
      action: action,
      productName: productName,
      quantity: quantity,
      message: _generateMessage(action, productName, quantity),
    );
  }

  static String _determineAction(String text) {
    // Check for show/cart commands first
    for (String keyword in showKeywords) {
      if (text.contains(keyword)) {
        return 'show';
      }
    }

    // Check for add commands
    for (String keyword in addKeywords) {
      if (text.contains(keyword)) {
        return 'add';
      }
    }

    // Check for remove commands
    for (String keyword in removeKeywords) {
      if (text.contains(keyword)) {
        return 'remove';
      }
    }

    return 'unknown';
  }

  static int _extractQuantity(String text) {
    // Look for digits first
    RegExp digitRegex = RegExp(r'\b(\d+)\b');
    Match? match = digitRegex.firstMatch(text);
    if (match != null) {
      return int.parse(match.group(1)!);
    }

    // Look for number words
    List<String> words = text.split(' ');
    for (String word in words) {
      for (String numberWord in numberWords.keys) {
        if (word == numberWord || numberWords[numberWord]!.contains(word)) {
          return int.parse(numberWords.keys.toList().indexOf(numberWord).toString()) + 1;
        }
      }
    }

    // Default quantity
    return 1;
  }

  static String _extractProductName(String text) {
    String bestMatch = '';
    double bestSimilarity = 0.0;

    for (String product in productNames) {
      // Direct substring match
      if (text.contains(product)) {
        return product;
      }

      // Check for plural forms
      String plural = _getPlural(product);
      if (text.contains(plural)) {
        return product;
      }

      // Similarity matching
      List<String> textWords = text.split(' ');
      for (String word in textWords) {
        double similarity = StringSimilarity.compareTwoStrings(word, product);
        if (similarity > bestSimilarity && similarity > 0.6) {
          bestSimilarity = similarity;
          bestMatch = product;
        }
      }
    }

    return bestMatch;
  }

  static String _getPlural(String word) {
    if (word.endsWith('s') || word.endsWith('x') ||
        word.endsWith('ch') || word.endsWith('sh')) {
      return word + 'es';
    } else if (word.endsWith('y')) {
      return word.substring(0, word.length - 1) + 'ies';
    } else {
      return word + 's';
    }
  }

  static String _generateMessage(String action, String productName, int quantity) {
    String capitalizedProduct = productName[0].toUpperCase() + productName.substring(1);

    if (action == 'add') {
      return quantity == 1
          ? '$capitalizedProduct added to cart'
          : '$quantity ${_getPlural(capitalizedProduct)} added to cart';
    } else if (action == 'remove') {
      return quantity == 1
          ? '$capitalizedProduct removed from cart'
          : '$quantity ${_getPlural(capitalizedProduct)} removed from cart';
    }

    return 'Command processed';
  }
}

class CommandResult {
  final String action;
  final String productName;
  final int quantity;
  final String message;

  CommandResult({
    required this.action,
    required this.productName,
    required this.quantity,
    required this.message,
  });

  @override
  String toString() {
    return 'CommandResult{action: $action, productName: $productName, quantity: $quantity, message: $message}';
  }
}