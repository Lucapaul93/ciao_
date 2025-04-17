import 'dart:convert'; // Per jsonEncode e jsonDecode
import 'package:http/http.dart' as http; // Importa il pacchetto http
import '../models/quiz_model.dart'; // Import per il modello Quiz

class ApiService {
  // Implementazione Singleton per garantire che tutte le chiamate usino la stessa istanza
  static final ApiService _instance = ApiService._internal();
  
  // Factory constructor che restituisce l'istanza singleton
  factory ApiService() {
    return _instance;
  }
  
  // Costruttore privato per il singleton
  ApiService._internal();
  
  // URL per la generazione delle storie
  final String _storyUrl = 'https://1-1-rosy.vercel.app/api/generate-story';
  // URL per la generazione dei quiz
  final String _quizUrl = 'https://1-1-rosy.vercel.app/api/generate-quiz';
  // Nuovi URL per le storie interattive
  final String _startInteractiveStoryUrl =
      'https://1-1-rosy.vercel.app/api/start-interactive-story';
  final String _continueStoryUrl =
      'https://1-1-rosy.vercel.app/api/continue-story';

  // Timeout per la chiamata API (60 secondi)
  final Duration _timeout = const Duration(seconds: 60);

  // Client HTTP per supportare la cancellazione delle richieste
  var client = http.Client();
  
  // Funzione per annullare le richieste in corso
  void cancelRequests() {
    client.close();
    client = http.Client(); // Crea un nuovo client per le richieste future
  }

  Future<String> generateStory({
    required String ageRange,
    required String storyLength,
    required String theme,
    required String mainCharacter,
    required String setting,
    required String emotion,
    String? complexTheme,
    String? moral,
    String? childName,
  }) async {
    try {
      print('Invio richiesta API a: $_storyUrl'); // Log per debug
      print(
        'Parametri: ageRange=$ageRange, theme=$theme, character=$mainCharacter',
      ); // Log per debug
      if (childName != null) {
        print('Nome del bambino specificato: $childName'); // Log per debug
      }

      final Map<String, dynamic> requestBody = {
        'ageRange': ageRange,
        'storyLength': storyLength,
        'theme': theme,
        'mainCharacter': mainCharacter,
        'setting': setting,
        'emotion': emotion,
      };

      if (complexTheme != null) {
        requestBody['complexTheme'] = complexTheme;
      }

      if (moral != null) {
        requestBody['moral'] = moral;
      }

      if (childName != null && childName.isNotEmpty) {
        requestBody['childName'] = childName;
      }

      final response = await client
          .post(
            Uri.parse(_storyUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            _timeout,
            onTimeout: () {
              throw Exception(
                'Timeout: la richiesta ha impiegato troppo tempo. Vercel potrebbe essere sovraccarico.',
              );
            },
          );

      print(
        'Risposta ricevuta con status: ${response.statusCode}',
      ); // Log per debug

      if (response.statusCode == 200) {
        // Se il server restituisce una risposta OK (200),
        // decodifica il JSON.
        try {
          final responseBody = jsonDecode(response.body);
          final story = responseBody['story'];
          if (story != null && story is String) {
            return story;
          } else {
            throw Exception(
              'Formato risposta API non valido: manca la storia.',
            );
          }
        } catch (jsonError) {
          print('Errore nella decodifica JSON: $jsonError'); // Log per debug
          print('Corpo risposta: ${response.body}'); // Log per debug
          throw Exception(
            'Impossibile elaborare la risposta del server. Dettagli: $jsonError',
          );
        }
      } else if (response.statusCode >= 500) {
        // Errori server (500+) spesso relativi a problemi con Vercel/server
        throw Exception(
          'Errore del server Vercel (${response.statusCode}). Il servizio potrebbe essere sovraccarico. Riprova tra qualche minuto.',
        );
      } else {
        // Altri errori HTTP
        String errorMessage = 'Errore dal server: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['error'] != null && errorBody['error'] is String) {
            errorMessage += ' - ${errorBody['error']}';
          }
        } catch (e) {
          // Non è riuscito a decodificare il corpo dell'errore, usa il testo grezzo
          if (response.body.isNotEmpty) {
            errorMessage += ' - ${response.body}';
          }
        }
        print('Errore API: $errorMessage'); // Log per debug
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Gestisce errori di rete o altri problemi durante la chiamata
      print('Errore durante la chiamata API: $e'); // Log per debug

      // Personalizza i messaggi di errore per renderli più comprensibili
      String errorMessage;
      if (e.toString().contains('SocketException') ||
          e.toString().contains('network')) {
        errorMessage =
            'Impossibile connettersi al server. Controlla la tua connessione internet.';
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            'La connessione al server è scaduta. Vercel potrebbe essere temporaneamente sovraccarico. Riprova più tardi.';
      } else if (e.toString().contains('Vercel')) {
        // Rilancia errori già formattatati per Vercel
        errorMessage = e.toString().replaceAll('Exception: ', '');
      } else {
        errorMessage =
            'Impossibile generare la storia. Riprova più tardi. Dettagli: $e';
      }

      throw Exception(errorMessage);
    }
  }

  Future<Quiz> generateQuiz(String storyText) async {
    try {
      print('Invio richiesta quiz a: $_quizUrl'); // Log per debug
      print(
        'Testo storia: ${storyText.substring(0, 100)}...',
      ); // Log primi 100 caratteri

      final Map<String, dynamic> requestBody = {
        'storyText': storyText,
        'numQuestions': 3, // Numero fisso di domande per il test
        'numOptions': 3, // Numero fisso di opzioni per domanda
      };

      print('Corpo richiesta: ${jsonEncode(requestBody)}'); // Log per debug

      final response = await client
          .post(
            Uri.parse(_quizUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      print(
        'Risposta quiz ricevuta con status: ${response.statusCode}',
      ); // Log per debug
      print('Corpo risposta: ${response.body}'); // Log per debug

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          if (!data.containsKey('questions') || data['questions'] == null) {
            throw Exception('La risposta non contiene le domande del quiz');
          }
          return Quiz.fromJson(data);
        } catch (jsonError) {
          print(
            'Errore nella decodifica JSON del quiz: $jsonError',
          ); // Log per debug
          throw Exception('Formato risposta quiz non valido: $jsonError');
        }
      } else {
        String errorMessage =
            'Errore nella generazione del quiz: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['error'] != null && errorBody['error'] is String) {
            errorMessage += ' - ${errorBody['error']}';
          }
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage += ' - ${response.body}';
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Errore durante la chiamata API del quiz: $e'); // Log per debug
      throw Exception('Errore nella chiamata API: $e');
    }
  }

  /// Inizia una storia interattiva (a bivi)
  Future<Map<String, dynamic>> startInteractiveStory({
    required String ageRange,
    required String theme,
    required String mainCharacter,
    required String setting,
    required String emotion,
    String? complexTheme,
    String? moral,
    String? childName,
  }) async {
    try {
      print(
        'Invio richiesta API a: $_startInteractiveStoryUrl',
      ); // Log per debug
      print(
        'Parametri: ageRange=$ageRange, theme=$theme, character=$mainCharacter',
      ); // Log per debug
      if (childName != null) {
        print('Nome del bambino specificato: $childName'); // Log per debug
      }

      // Costruiamo il corpo della richiesta
      final Map<String, dynamic> requestBody = {
        'ageRange': ageRange,
        'theme': theme,
        'mainCharacter': mainCharacter,
        'setting': setting,
        'emotion': emotion,
      };

      // Aggiungiamo i parametri opzionali solo se sono presenti
      if (complexTheme != null) {
        requestBody['complexTheme'] = complexTheme;
      }

      if (moral != null) {
        requestBody['moral'] = moral;
      }

      // Aggiungiamo il nome del bambino solo se è presente
      if (childName != null && childName.isNotEmpty) {
        requestBody['childName'] = childName;
      }

      final response = await client
          .post(
            Uri.parse(_startInteractiveStoryUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            _timeout,
            onTimeout: () {
              throw Exception(
                'Timeout: la richiesta ha impiegato troppo tempo. Vercel potrebbe essere sovraccarico.',
              );
            },
          );

      print(
        'Risposta ricevuta con status: ${response.statusCode}',
      ); // Log per debug

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> storyData = jsonDecode(response.body);

          // Validazione di base dei dati
          if (!storyData.containsKey('segment') ||
              !storyData.containsKey('choices') ||
              !storyData.containsKey('is_final')) {
            throw Exception(
              'Formato risposta API non valido per storia interattiva.',
            );
          }

          return storyData;
        } catch (jsonError) {
          print('Errore nella decodifica JSON: $jsonError'); // Log per debug
          print('Corpo risposta: ${response.body}'); // Log per debug
          throw Exception(
            'Impossibile elaborare la risposta del server. Dettagli: $jsonError',
          );
        }
      } else {
        // Gestione errori come nella generateStory
        String errorMessage = 'Errore dal server: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['error'] != null && errorBody['error'] is String) {
            errorMessage += ' - ${errorBody['error']}';
          }
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage += ' - ${response.body}';
          }
        }
        print('Errore API: $errorMessage'); // Log per debug
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Errore generale: $e'); // Log per debug
      rethrow; // Rilancia l'eccezione per gestirla nel UI
    }
  }

  /// Continua una storia interattiva dopo una scelta dell'utente
  Future<Map<String, dynamic>> continueStory({
    required String storyHistory,
    required String chosenOption,
    int? segmentCount,
  }) async {
    try {
      print('Invio richiesta API a: $_continueStoryUrl'); // Log per debug
      print('Opzione scelta: $chosenOption'); // Log per debug
      print(
        'Lunghezza storia: ${storyHistory.length} caratteri',
      ); // Log per debug
      if (segmentCount != null) {
        print('Segmento corrente: $segmentCount'); // Log per debug
      }

      final response = await client
          .post(
            Uri.parse(_continueStoryUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'storyHistory': storyHistory,
              'chosenOption': chosenOption,
              'segmentCount': segmentCount,
            }),
          )
          .timeout(
            _timeout,
            onTimeout: () {
              throw Exception(
                'Timeout: la richiesta ha impiegato troppo tempo. Vercel potrebbe essere sovraccarico.',
              );
            },
          );

      print(
        'Risposta ricevuta con status: ${response.statusCode}',
      ); // Log per debug

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> storyData = jsonDecode(response.body);

          // Validazione di base dei dati
          if (!storyData.containsKey('segment') ||
              !storyData.containsKey('choices') ||
              !storyData.containsKey('is_final')) {
            throw Exception(
              'Formato risposta API non valido per continuazione storia.',
            );
          }

          return storyData;
        } catch (jsonError) {
          print('Errore nella decodifica JSON: $jsonError'); // Log per debug
          print('Corpo risposta: ${response.body}'); // Log per debug
          throw Exception(
            'Impossibile elaborare la risposta del server. Dettagli: $jsonError',
          );
        }
      } else {
        // Gestione errori come nella generateStory
        String errorMessage = 'Errore dal server: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['error'] != null && errorBody['error'] is String) {
            errorMessage += ' - ${errorBody['error']}';
          }
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage += ' - ${response.body}';
          }
        }
        print('Errore API: $errorMessage'); // Log per debug
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Errore generale: $e'); // Log per debug
      rethrow; // Rilancia l'eccezione per gestirla nel UI
    }
  }
}
