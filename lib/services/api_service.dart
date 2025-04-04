import 'dart:convert'; // Per jsonEncode e jsonDecode
import 'package:http/http.dart' as http; // Importa il pacchetto http

class ApiService {
  // SOSTITUISCI CON IL TUO URL DI DEPLOY VERCEL REALE
  final String _baseUrl = 'https://1-eta-peach.vercel.app/api/generate-story';
  // Esempio: final String _baseUrl = 'https://storydream-backend-1234abcd.vercel.app/api/generate-story';

  // Timeout per la chiamata API (30 secondi)
  final Duration _timeout = const Duration(seconds: 60);

  Future<String> generateStory({
    required String ageRange,
    required String storyLength,
    required String theme,
    required String mainCharacter,
    required String setting,
    required String emotion,
    String? complexTheme, // Opzionale
    String? moral, // Opzionale
  }) async {
    try {
      print('Invio richiesta API a: $_baseUrl'); // Log per debug
      print(
        'Parametri: ageRange=$ageRange, theme=$theme, character=$mainCharacter',
      ); // Log per debug

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'ageRange': ageRange,
              'storyLength': storyLength,
              'theme': theme,
              'mainCharacter': mainCharacter,
              'setting': setting,
              'emotion': emotion,
              'complexTheme': complexTheme, // Verrà inviato solo se non è null
              'moral': moral, // Verrà inviato solo se non è null
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
}
