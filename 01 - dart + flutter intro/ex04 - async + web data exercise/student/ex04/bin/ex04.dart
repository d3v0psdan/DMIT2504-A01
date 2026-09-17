import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

const HTTP_OK = 200;
const HTTP_NOT_FOUND = 404;
const HTTP_SERVER_ERROR = 500;

class Word {
  final String word;
  final String definition;

  Word({
    required this.word,
    required this.definition,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'],
      definition: json['entries'][0]['senses'][0]['definition'],
    );
  }
}

void printWordWithDefinition(Word wordObject) {
  /* I know this is totally not required for this exercise, but I
    was really annoyed with different words not being aligned correctly!
  */
  print('called');
  final String word = wordObject.word;
  final String definition = wordObject.definition;

  const columnWidth = 14;
  const definitionWidth = 51;

  final paddedWord = word.length >= columnWidth ?
    '${word.substring(0, columnWidth - 1)}' :
    word.padRight(columnWidth);

  print('${'Word'.padRight(columnWidth)}  Definition');
  print('${'-' * columnWidth}  ${'-' * definitionWidth}');
  print('$paddedWord  $definition');
}

Future<void> searchWord(String word) async {
  try {
      final Uri uri =  Uri.parse('https://freedictionaryapi.com/api/v1/entries/en/$word');
      final response = await http.get(uri);
      final statusCode = response.statusCode;

      switch (statusCode) {
        case HTTP_OK:
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          if (jsonResponse.isEmpty) {
            print('The word "$word" was not found in the dictionary. You must be special lol');
            return;
          }

          print('The word "$word" was found in the dictionary!');
          final Word wordObject = Word.fromJson(jsonResponse);
          print(wordObject);
          printWordWithDefinition(wordObject);
          break;
        case HTTP_NOT_FOUND:
          print('The word "$word" was not found in the dictionary. You must be special lol');
          break;
        case HTTP_SERVER_ERROR:
          print('Server error occurred. Please try again later.');
          break;
        default:
          print('Unexpected status code: $statusCode');
      }
  } catch (exception) {
    print('An exception occurred: $exception');
  }

}

void main(List<String> arguments) {
  bool hasInitialized = false;

  while (true) {
    if (!hasInitialized) {
      hasInitialized = true;
      print('Hello good sir or madam, what word would you like to search for?: ');

    } else {
      print('\nWhat other word would you like to search for? (or type /exit to quit): ');
    }

    String? word = stdin.readLineSync();
    if (word == null || word.isEmpty) {
      print('My brotha or sista in christ, you didn\'t enter a word. Please try again.');
      continue;
    } else if (word.toLowerCase() == '/exit') {
      break;
    }

    searchWord(word);
  }

  print('Exiting the program. Peace nerds!');
}
