import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'story_display_screen.dart'; // Per visualizzare la storia cliccata

class SavedStoriesScreen extends StatefulWidget {
  const SavedStoriesScreen({super.key});

  @override
  State<SavedStoriesScreen> createState() => _SavedStoriesScreenState();
}

class _SavedStoriesScreenState extends State<SavedStoriesScreen> {
  List<String> _savedStories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedStories();
  }

  // Funzione per caricare le storie salvate
  Future<void> _loadSavedStories() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _savedStories = prefs.getStringList('savedStories') ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print("Errore caricamento storie: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossibile caricare le storie salvate: $e')),
        );
      }
    }
  }

  // Funzione per eliminare una storia
  Future<void> _deleteStory(int index) async {
    // Chiedi conferma all'utente
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma Eliminazione'),
          content: const Text('Sei sicuro di voler eliminare questa storia?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Annulla
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Conferma
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        List<String> currentStories = prefs.getStringList('savedStories') ?? [];
        if (index >= 0 && index < currentStories.length) {
          currentStories.removeAt(
            index,
          ); // Rimuovi la storia all'indice specificato
          await prefs.setStringList('savedStories', currentStories);
          // Aggiorna l'interfaccia
          _loadSavedStories(); // Ricarica la lista aggiornata
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Storia eliminata.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante l\'eliminazione: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storie Salvate'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          // Pulsante per ricaricare le storie (utile se si salva da un'altra schermata)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Aggiorna Lista',
            onPressed: _loadSavedStories,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _savedStories.isEmpty
              ? const Center(
                child: Text(
                  'Non hai ancora salvato nessuna storia.\nCrea una storia e premi l\'icona del segnalibro per salvarla!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : RefreshIndicator(
                // Permette di ricaricare trascinando verso il basso
                onRefresh: _loadSavedStories,
                child: ListView.builder(
                  itemCount: _savedStories.length,
                  itemBuilder: (context, index) {
                    final story = _savedStories[index];
                    // Mostra un'anteprima della storia (es. le prime parole)
                    final preview =
                        story.length > 100
                            ? '${story.substring(0, 100)}...'
                            : story;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ), // Numero storia
                      title: Text(
                        preview.split('\n').first,
                      ), // Titolo come prima riga o preview
                      subtitle: Text(
                        'Tocca per leggere, tieni premuto per eliminare',
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[300],
                        ),
                        tooltip: 'Elimina Storia',
                        onPressed: () => _deleteStory(index), // Chiama elimina
                      ),
                      onTap: () {
                        // Naviga alla schermata di visualizzazione con la storia completa
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    StoryDisplayScreen(storyText: story),
                          ),
                        ).then(
                          (_) => _loadSavedStories(),
                        ); // Ricarica quando torni indietro (opzionale)
                      },
                      onLongPress:
                          () => _deleteStory(index), // Elimina con long press
                    );
                  },
                ),
              ),
    );
  }
}
