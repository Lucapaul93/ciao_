// api/generate-story.js

// Usiamo 'node-fetch' versione 2 per compatibilità con Vercel serverless
// Dobbiamo installarlo: npm install node-fetch@2
const fetch = require('node-fetch');

module.exports = async (req, res) => {
    // 1. Sicurezza: Accetta solo richieste POST
    if (req.method !== 'POST') {
        res.setHeader('Allow', ['POST']);
        return res.status(405).json({ error: `Method ${req.method} Not Allowed` });
    }

    // 2. Recupera la chiave API dalle variabili d'ambiente (più sicuro!)
    const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY;
    if (!OPENROUTER_API_KEY) {
        console.error('Errore: OPENROUTER_API_KEY non è impostata nelle variabili d\'ambiente.');
        return res.status(500).json({ error: 'Internal Server Error: API key not configured.' });
    }

    try {
        // 3. Estrai i filtri dal corpo della richiesta inviata da Flutter
        const {
            ageRange,
            storyLength, // Assicurati che storyLength sia estratto correttamente
            theme,
            mainCharacter,
            setting,
            emotion,
            complexTheme,
            moral,
            childName, // Nuovo parametro per il nome del bambino
        } = req.body;

        // Log dei parametri ricevuti per debug
        console.log('Parametri ricevuti:', { 
            ageRange, 
            storyLength, 
            theme, 
            mainCharacter, 
            setting, 
            emotion, 
            complexTheme, 
            moral, 
            childName 
        });

        // ========= ASSICURATI CHE QUESTO BLOCCO SIA PRESENTE =========
        // Definisci il conteggio parole target in base alla lunghezza scelta
        let minWords, maxWords;
        switch (storyLength) {
            case 'breve':
                minWords = 600;
                maxWords = 900;
                break;
            case 'media':
                minWords = 1000;
                maxWords = 1500;
                break;
            case 'lunga':
                minWords = 1600;
                maxWords = 2000;
                break;
            default: // Default a 'breve' se il valore non è riconosciuto
                console.warn(`Valore storyLength non riconosciuto: ${storyLength}. Uso 'breve' come default.`);
                minWords = 600;
                maxWords = 900;
        }

        // --- VALIDAZIONE INPUT (Opzionale ma consigliata) ---
        // Qui potresti aggiungere controlli per assicurarti che i dati ricevuti
        // siano validi (es. ageRange è una stringa attesa, etc.)
        // -----------------------------------------------------

        // 4. Definisci il conteggio parole target in base alla lunghezza scelta
        // --- INIZIO BLOCCO PROMPT (Versione migliorata) ---
        let promptContent = `Sei un eccellente narratore di storie della buonanotte per bambini. Scrivi una storia originale e completa per un bambino nella fascia d'età ${ageRange}.

La storia DEVE avere una lunghezza compresa tra ${minWords} e ${maxWords} parole. Cerca di rispettare il più possibile questo intervallo, assicurandoti che la storia sia completa e coinvolgente.

`;

        // Gestione personalizzata del protagonista in base alla presenza del nome del bambino
        if (childName && childName.trim()) {
            promptContent += `PROTAGONISTA PRINCIPALE:
Il protagonista principale della storia si chiama ${childName}. ${childName} deve essere il vero centro dell'avventura.
${mainCharacter ? `${childName} è un ${mainCharacter} ${mainCharacter.endsWith('a') ? 'coraggiosa' : 'coraggioso'} e fantastico/a.` : ''}
Usa frequentemente il nome "${childName}" durante la narrazione (almeno 8-10 volte), riferendoti al protagonista in modo naturale.
`;
        } else {
            promptContent += `PROTAGONISTA PRINCIPALE:
Il personaggio principale è ${mainCharacter}.
Dalle sue caratteristiche e personalità unica.
`;
        }

        promptContent += `
DETTAGLI PRINCIPALI:
- Tema: ${theme}
- Ambientazione: ${setting}
- Emozione prevalente da suscitare: ${emotion}

${complexTheme ? `TEMA COMPLESSO:
Includi delicatamente questo tema, adattandolo all'età ${ageRange}: ${complexTheme}.\n` : ''}${moral ? `MORALE:
Fai emergere naturalmente questa morale dalla storia, senza dichiararla esplicitamente: ${moral}.\n` : ''}
STRUTTURA:
1. Inizio: Presenta ${childName ? childName : mainCharacter} e l'ambientazione in modo interessante
2. Sviluppo: Descrivi un'avventura o situazione coinvolgente che ${childName ? childName : 'il protagonista'} deve affrontare
3. Conclusione: Termina con una risoluzione positiva e rassicurante, adatta per accompagnare il sonno

STILE:
- Usa un linguaggio semplice, positivo e coinvolgente adatto a bambini di ${ageRange}
- Crea un titolo accattivante per la storia
- Evita elementi spaventosi, tristi o troppo complessi
- Scrivi in paragrafi ben formati (NON usare elenchi puntati o simboli speciali)
- Il testo deve essere pronto per essere letto come una vera storia della buonanotte

Inizia a scrivere la storia qui sotto:
`;
        // --- FINE BLOCCO PROMPT ---

        if (complexTheme) {
            promptContent += `\nIncorpora delicatamente il seguente tema: ${complexTheme}. Adattalo in modo appropriato per l'età ${ageRange}.`;
        }
        if (moral) {
            promptContent += `\nLa storia dovrebbe avere una morale chiara e semplice, adatta all'età ${ageRange}, su: ${moral}. Non dichiarare esplicitamente "la morale è...", ma falla emergere dalla storia.`;
        }

        promptContent += `\nLa storia deve essere coinvolgente, positiva, adatta per la buonanotte e scritta in un linguaggio semplice e comprensibile per l'età indicata. Evita elementi troppo spaventosi o complessi. Concludi la storia in modo rassicurante.`;
        promptContent += `\n\nInizia la storia qui sotto:\n`;

        // 6. Prepara la richiesta per OpenRouter
        const apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
        const requestBody = {
            model: 'deepseek/deepseek-chat-v3-0324:free', // Modello specificato
            messages: [
                {
                    role: 'user',
                    content: promptContent // Il nostro prompt dettagliato
                }
            ],
            temperature: 0.7 // Aggiunto parametro di creatività (0.7 è un buon bilanciamento)
        };

        // 7. Esegui la chiamata API a OpenRouter
        console.log("Invio richiesta a OpenRouter..."); // Log per debug
        const response = await fetch(apiUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${OPENROUTER_API_KEY}`
            },
            body: JSON.stringify(requestBody)
        });

        console.log("Risposta ricevuta da OpenRouter. Status:", response.status); // Log per debug

        // 8. Gestisci la risposta di OpenRouter
        if (!response.ok) {
            const errorBody = await response.text(); // Leggi il corpo dell'errore
            console.error(`Errore da OpenRouter: ${response.status} ${response.statusText}`, errorBody);
            throw new Error(`API Error: ${response.status} ${response.statusText} - ${errorBody}`);
        }

        const data = await response.json();

        // Estrai il testo generato (la struttura della risposta può variare leggermente, controlla la documentazione di OpenRouter se necessario)
        const generatedStory = data.choices && data.choices[0] && data.choices[0].message && data.choices[0].message.content
            ? data.choices[0].message.content.trim()
            : null;

        if (!generatedStory) {
            console.error('Errore: Nessuna storia generata nella risposta di OpenRouter.', data);
            throw new Error('Failed to parse story from API response.');
        }

        console.log("Storia generata con successo."); // Log per debug

        // 9. Invia la storia generata all'app Flutter
        res.status(200).json({ story: generatedStory });

    } catch (error) {
        console.error('Errore durante la generazione della storia:', error);
        // Invia un messaggio di errore generico all'utente per sicurezza
        res.status(500).json({ error: 'Oops! Qualcosa è andato storto durante la creazione della storia. Riprova più tardi.' });
    }
};